# stdlib
import enum
import json
import logging
import os
import pathlib
import re
import subprocess
import sys
from dataclasses import dataclass

# third party
import yaml
from dbtc import dbtCloudClient
from sqlglot import diff, parse_one
from sqlglot.diff import Insert, Move, Remove, Update
from sqlglot.expressions import Column

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


# Env Vars
DBT_CLOUD_SERVICE_TOKEN = os.environ["DBT_CLOUD_SERVICE_TOKEN"]
DBT_CLOUD_ACCOUNT_ID = os.environ["DBT_CLOUD_ACCOUNT_ID"]
DBT_CLOUD_JOB_ID = os.environ["DBT_CLOUD_JOB_ID"]
DBT_CLOUD_HOST = os.getenv("DBT_CLOUD_HOST", "cloud.getdbt.com")
GITHUB_TOKEN = os.environ["GITHUB_TOKEN"]
GITHUB_BRANCH = os.environ["GITHUB_HEAD_REF"]
GITHUB_REPO = os.environ["GITHUB_REPOSITORY"]
GITHUB_REF = os.environ["GITHUB_REF"]


class JobRunStatus(enum.IntEnum):
    QUEUED = 1
    STARTING = 2
    RUNNING = 3
    SUCCESS = 10
    ERROR = 20
    CANCELLED = 30


def trigger_job(
    dbtc_client: dbtCloudClient, *, excluded_nodes: list[str] = None
) -> None:
    def extract_pr_number(s):
        match = re.search(r"refs/pull/(\d+)/merge", s)
        return int(match.group(1)) if match else None

    # Extract PR Number
    pull_request_id = extract_pr_number(GITHUB_REF)

    # Create schema
    schema_override = f"dbt_cloud_pr_{DBT_CLOUD_JOB_ID}_{pull_request_id}"

    # Create payload to pass to job
    # https://docs.getdbt.com/docs/deploy/ci-jobs#trigger-a-ci-job-with-the-api
    payload = {
        "cause": "Column-aware CI",
        "schema_override": schema_override,
        "git_branch": GITHUB_BRANCH,
        "github_pull_request_id": pull_request_id,
    }

    if excluded_nodes is not None:
        excluded_nodes_str = " ".join(excluded_nodes)
        steps_override = [
            f"dbt build -s state:modified+ --exclude {excluded_nodes_str}"
        ]
        payload["steps_override"] = steps_override

    return dbtc_client.cloud.trigger_job(
        DBT_CLOUD_ACCOUNT_ID, DBT_CLOUD_JOB_ID, payload, should_poll=True
    )


@dataclass
class Node:
    unique_id: str
    target_code: str
    source_code: str | None = None

    @property
    def valid_changes(self):
        def is_valid_change(change: Insert | Move | Remove | Update) -> bool:
            return change.__class__ not in [Move]

        source = parse_one(self.source_code)
        target = parse_one(self.target_code)
        changes = diff(source, target, delta_only=True)
        return [change for change in changes if is_valid_change(change)]


class Config:
    DEFAULT_HOST = "cloud.getdbt.com"

    def __init__(self):
        self._set_dbt_cloud_env_vars()
        self.dbtc_client = self._initialize_dbtc_client()

        if "DBT_CLOUD_ENVIRONMENT_ID" not in os.environ:
            self._set_deferring_environment_id()

        self._create_dbt_cloud_profile()

    def _initialize_dbtc_client(self) -> dbtCloudClient:
        logger.info(
            f"Your dbt Cloud host is: {self.dbt_cloud_host}. Configure with env var "
            "`DBT_CLOUD_HOST`."
        )
        return dbtCloudClient(host=getattr(self, "dbt_cloud_host", "cloud.getdbt.com"))

    def _set_dbt_cloud_env_vars(self) -> None:
        for env_var in os.environ:
            if env_var.startswith("DBT_CLOUD_"):
                name = env_var.lower()
                value = os.environ[env_var]
                setattr(self, name, value)

    def _set_deferring_environment_id(self):
        try:
            ci_job = self.dbtc_client.cloud.get_job(
                self.dbt_cloud_account_id, self.dbt_cloud_job_id
            )
        except Exception as e:
            raise Exception(
                "An error occurred making a request to dbt Cloud." f"See error: {e}"
            )
        try:
            self.dbt_cloud_environment_id = ci_job["data"]["deferring_environment_id"]
        except Exception as e:
            raise Exception(
                "An error occurred retrieving your job's deferring environment ID. "
                f"Response from API:\n{ci_job}.\nError:\n{e}"
            )

    def _create_dbt_cloud_profile(self) -> None:
        dbt_cloud_config = {
            "version": 1,
            "context": {
                "active-project": self.dbt_cloud_project_id,
                "active-host": self.dbt_cloud_host,
            },
            "projects": [
                {
                    "project-name": self.dbt_cloud_project_name,
                    "project-id": self.dbt_cloud_project_id,
                    # "account-name": self.dbt_cloud_account_name,
                    # "account-id": self.dbt_cloud_account_id,
                    "account-host": self.dbt_cloud_host,
                    "token-name": self.dbt_cloud_token_name,
                    "token-value": self.dbt_cloud_token_value,  # dbt_cloud_token_value
                }
            ],
        }

        dbt_dir = pathlib.Path.home() / ".dbt"
        dbt_dir.mkdir(parents=True, exist_ok=True)

        config_path = dbt_dir / "dbt_cloud.yml"
        with open(config_path, "w") as f:
            yaml.dump(dbt_cloud_config, f)


class NodeManager:
    def __init__(self, config: Config):
        self._config = config
        self.dbtc_client = self._config.dbtc_client
        self.environment_id = self._config.dbt_cloud_environment_id
        self._node_dict: dict[str, Node] = {}
        self._all_unique_ids: set[str] = set()
        self._all_impacted_unique_ids: set[str] = set()
        self._set_nodes()

    @property
    def node_unique_ids(self) -> list[str]:
        return list(self._node_dict.keys())

    @property
    def nodes(self) -> list[Node]:
        return list(self._node_dict.values())

    def _set_nodes(self) -> None:
        self._get_target_code()
        if self.nodes:
            self._get_source_code()

        self._node_dict = {k: v for k, v in self._node_dict.items() if v.source_code}

    def _get_impacted_unique_ids_for_node_changes(
        self, changes: list[Insert | Move | Remove | Update]
    ):
        impacted_unique_ids = set()
        for change in changes:
            if self._is_tracked_change(change) and hasattr(change, "expression"):
                expression = change.expression
                while True:
                    column = expression.find(Column)
                    if column is not None:
                        impacted_unique_ids.update(
                            self._get_downstream_nodes_from_column(column.name)
                        )
                        break
                    elif expression.depth < 1:
                        break
                    expression = expression.parent

        return impacted_unique_ids

    def _get_target_code(self):
        cmd = ["dbt", "compile", "-s", "state:modifie,resource_type:model"]

        logger.info("Compiling code for any modified nodes...")

        _ = subprocess.run(cmd)

        # This will generate a run_results.json file, among other things, which will
        # contain the compiled code for each node

        with open("target/run_results.json") as rr:
            run_results_json = json.load(rr)

        for result in run_results_json.get("results", []):
            relation_name = result["relation_name"]
            if relation_name is not None:
                unique_id = result["unique_id"]
                self._node_dict[unique_id] = Node(
                    unique_id=unique_id, target_code=result["compiled_code"]
                )
                logger.info(f"Retrieved compiled code for {unique_id}")

    def _get_source_code(self) -> None:
        query = """
        query Environment($environmentId: BigInt!, $filter: ModelAppliedFilter, $first: Int, $after: String) {
            environment(id: $environmentId) {
                applied {
                    models(filter: $filter, first: $first, after: $after) {
                        edges {
                            node {
                                compiledCode
                                uniqueId
                            }
                        }
                        pageInfo {
                            endCursor
                            hasNextPage
                            hasPreviousPage
                            startCursor
                        }
                        totalCount
                    }
                }
            }
        }
        """

        variables = {
            "first": 500,
            "after": None,
            "environmentId": self.dbt_cloud_environment_id,
            "filter": {"uniqueIds": self.node_unique_ids},
        }

        logger.info("Querying discovery API for compiled code...")

        deferring_env_nodes = self.dbtc_client.metadata.query(
            query, variables, paginated_request_to_list=True
        )

        for deferring_env_node in deferring_env_nodes:
            unique_id = deferring_env_node["node"]["uniqueId"]
            if unique_id in self.node_unique_ids:
                self._node_dict[unique_id].source_code = deferring_env_node["node"][
                    "compiledCode"
                ]

    def _get_all_unique_ids(self) -> set[str]:
        """Get all downstream unique IDs using dbt ls"""
        cmd = [
            "dbt",
            "ls",
            "--resource-type",
            "model",
            "--select",
            "state:modified+",
            "--output",
            "json",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)

        self._all_unique_ids = set()
        for line in result.stdout.split("\n"):
            json_str = line[line.find("{") : line.rfind("}") + 1]
            try:
                data = json.loads(json_str)
                unique_id = data["unique_id"]

                # Only include if it's a downstream node
                if unique_id not in self.node_unique_ids:
                    self._all_unique_ids.add(data["unique_id"])
            except ValueError:
                continue

    def _get_downstream_nodes_from_column(
        self, node: Node, column_name: str
    ) -> set[str]:
        query = """
        query Column($environmentId: BigInt!, $nodeUniqueId: String!, $filters: ColumnLineageFilter) {
            column(environmentId: $environmentId) {
                lineage(nodeUniqueId: $nodeUniqueId, filters: $filters) {
                    nodeUniqueId
                    relationship
                }
            }
        }
        """
        variables = {
            "environmentId": self.environment_id,
            "nodeUniqueId": node.unique_id,
            # HACK - Snowflake returns column names as uppercase, so that's what we have
            "filters": {"columnName": column_name.upper()},
        }
        results = self.dbtc_client.metadata.query(query, variables)
        try:
            lineage = results["data"]["column"]["lineage"]
        except Exception as e:
            logger.error(
                f"Error occurred retrieving column lineage for {column_name}"
                f"in {node.unique_id}:\n{e}"
            )
            return set()

        downstream_nodes = set()
        for node in lineage:
            if node["relationship"] == "child":
                downstream_nodes.add(node["nodeUniqueId"])

        return downstream_nodes

    def get_excluded_nodes(self) -> list[str]:
        if not self.nodes:
            return list()

        self._get_all_unique_ids()

        if not self._all_unique_ids:
            return list()

        for node in self.nodes:
            if node.valid_changes:
                self._all_impacted_unique_ids.update(
                    self._get_impacted_unique_ids_for_node(node.valid_changes)
                )

        excluded_nodes = self._all_unique_ids - self._all_impacted_unique_ids
        return [em.split(".")[-1] for em in excluded_nodes]


if __name__ == "__main__":
    config = Config()
    node_manager = NodeManager(config)
    excluded_nodes = node_manager.get_excluded_nodes()
    run = trigger_job(config.dbtc_client, excluded_nodes)
    run_status = run["status"]
    if run_status in (JobRunStatus.ERROR, JobRunStatus.CANCELLED):
        sys.exit(1)

    sys.exit(0)
