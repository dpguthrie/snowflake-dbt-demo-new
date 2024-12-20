# stdlib
import enum
import json
import logging
import os
import re
import subprocess
import sys
from dataclasses import dataclass

# third party
from dbtc import dbtCloudClient
from sqlglot import parse_one, diff
from sqlglot.expressions import Column


logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@dataclass
class Node:
    unique_id: str
    target_code: str
    source_code: str | None = None


class JobRunStatus(enum.IntEnum):
    QUEUED = 1
    STARTING = 2
    RUNNING = 3
    SUCCESS = 10
    ERROR = 20
    CANCELLED = 30


# Env Vars
DBT_CLOUD_SERVICE_TOKEN = os.environ["DBT_CLOUD_SERVICE_TOKEN"]
DBT_CLOUD_ACCOUNT_ID = os.environ["DBT_CLOUD_ACCOUNT_ID"]
DBT_CLOUD_JOB_ID = os.environ["DBT_CLOUD_JOB_ID"]
DBT_CLOUD_HOST = os.getenv("DBT_CLOUD_HOST", "cloud.getdbt.com")
GITHUB_TOKEN = os.environ["GITHUB_TOKEN"]
GITHUB_BRANCH = os.environ["GITHUB_HEAD_REF"]
GITHUB_REPO = os.environ["GITHUB_REPOSITORY"]
GITHUB_REF = os.environ["GITHUB_REF"]


dbtc_client = dbtCloudClient(host=DBT_CLOUD_HOST)
    
    
def get_dev_nodes() -> dict[str, Node]:
    with open("target/run_results.json") as rr:
        run_results_json = json.load(rr)
        
    run_results = {}
    for result in run_results_json["results"]:
        unique_id = result["unique_id"]
        relation_name = result["relation_name"]
        if relation_name is not None:
            logger.info(f"Retrieved compiled code for {unique_id}")
            run_results[unique_id] = Node(
                unique_id=unique_id,
                target_code=result["compiled_code"],
            )
    
    return run_results


def add_deferring_node_code(
    nodes: dict[str, Node], environment_id: int
) -> list[Node]:
     
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
        "environmentId": environment_id,
        "filter": {"uniqueIds": [node.unique_id for node in nodes.values()]}
    }
    
    logger.info("Querying discovery API for compiled code...")
    
    deferring_env_nodes = dbtc_client.metadata.query(
        query, variables, paginated_request_to_list=True
    )
    
    for deferring_env_node in deferring_env_nodes:
        unique_id = deferring_env_node["node"]["uniqueId"]
        if unique_id in nodes:
            nodes[unique_id].source_code = deferring_env_node["node"]["compiledCode"]
    
    # Assumption: Anything net new (e.g. nothing in the deferred env) shouldn't have
    # anything excluded, so we're not using it beyond this point.
    return {k: v for k, v in nodes.items() if v.source_code}


def trigger_job(steps_override: list[str] = None) -> None:
    
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
    
    if steps_override is not None:
        payload["steps_override"] = steps_override
    
    run = dbtc_client.cloud.trigger_job(
        DBT_CLOUD_ACCOUNT_ID, DBT_CLOUD_JOB_ID, payload, should_poll=True
    )
    
    run_status = run["status"]
    if run_status in (JobRunStatus.ERROR, JobRunStatus.CANCELLED):
        sys.exit(1)
        
    sys.exit(0)

    
class NodeDiff:
    
    COLUMN_QUERY = """
    query Column($environmentId: BigInt!, $nodeUniqueId: String!, $filters: ColumnLineageFilter) {
        column(environmentId: $environmentId) {
            lineage(nodeUniqueId: $nodeUniqueId, filters: $filters) {
                nodeUniqueId
                relationship
            }
        }
    }
    """
    
    def __init__(self, node: Node, environment_id: int):
        self.node = node
        self.environment_id = environment_id
        self.source = parse_one(node.source_code)
        self.target = parse_one(node.target_code)
        self.changes = diff(self.source, self.target, delta_only=True)
        self.downstream_models = set()

        # Only returning column changes now
        for change in self.changes:
            if hasattr(change, "expression"):
                expression = change.expression
                while True:
                    column = expression.find(Column)
                    if column is not None:
                        self.downstream_models.update(
                            self._get_downstream_models_from_column(column.name)
                        )
                        break
                    elif expression.depth < 1:
                        break
                    expression = expression.parent
                
    
    def _get_downstream_models_from_column(self, column_name: str) -> list[str]:
        variables = {
            "environmentId": self.environment_id,
            "nodeUniqueId": self.node.unique_id,
            "filters": {"columnName": column_name.upper()}
        }
        results = dbtc_client.metadata.query(self.COLUMN_QUERY, variables)
        try:
            lineage = results["data"]["column"]["lineage"]
        except Exception as e:
            logger.error(
                f"Error occurred retrieving column lineage for {column_name}"
                f"in {self.node.unique_id}:\n{e}"
            )
            return []
        
        downstream_models = list()
        for node in lineage:
            if node["relationship"] == "child":
                downstream_models.append(node["nodeUniqueId"])
                
        return downstream_models
    

if __name__ == "__main__":
    
    current_env = os.environ.copy()
    
    logger.info("Compiling modified models...")

    cmd = ["dbt", "compile", "--select", "state:modified"]
    result = subprocess.run(cmd, capture_output=True, text=True, env=current_env)

    logger.info("Retrieving compiled code...")

    nodes = get_dev_nodes()

    logger.info("Retrieving modified and downstream models...")

    # Understand all modified and anything downstream by using `dbt ls`
    cmd = ["dbt", "ls", "--resource-type", "model", "--select", "state:modified+", "--output", "json"]
    result = subprocess.run(cmd, capture_output=True, text=True, env=current_env)
    lines = result.stdout.split("\n")
    all_unique_ids = set()
    for line in lines:
        json_str = line[line.find('{'):line.rfind('}')+1]
        try:
            data = json.loads(json_str)
            all_unique_ids.add(data["unique_id"])
        except ValueError:
            continue
        
    # Remove the modified models from this set because they should not be excluded
    for key in nodes.keys():
        all_unique_ids.discard(key)
        
    # If nothing exists in all_unique_ids, nothing is downstream, nothing to exclude
    if not all_unique_ids:
        
        logger.info("Nothing downstream exists, triggering as normal...")
        
        trigger_job()
        
    logger.info("Retrieving CI Job, determining deferring environment...")

    # Retrieve the CI job so we can get the deferring environment_id
    ci_job = dbtc_client.cloud.get_job(DBT_CLOUD_ACCOUNT_ID, DBT_CLOUD_JOB_ID)

    environment_id: int = None
    if (
        "data" in ci_job
        and isinstance(ci_job["data"], dict)
        and ci_job["data"].get("deferring_environment_id", None) is not None
    ):
        environment_id = ci_job["data"]["deferring_environment_id"]
        
    if environment_id is None:
        raise Exception(
            "Unable to get the CI job's deferring environment ID. See response below:\n"
            f"{ci_job}"
        )

    logger.info("Adding compiled code from deferred environment...")
    nodes = add_deferring_node_code(nodes, environment_id)

    diffs = []
    for node in nodes.values():
        diffs.append(NodeDiff(node, environment_id))
        
    all_downstream_models = set().union(*[node_diff.downstream_models for node_diff in diffs])
    excluded_models = all_unique_ids - all_downstream_models
    if not excluded_models:
        
        logger.info("No models downstream to exclude, triggering as normal...")
        
        trigger_job()
    
    excluded_models_str = " ".join([e.split(".")[-1] for e in excluded_models])    
    logger.info("Downstream models are not impacted by column changes...")
    logger.info(f"Excluding the following: {excluded_models_str}")
    
    steps_override = [
        f"dbt build -s state:modified+ --exclude {excluded_models_str}"
    ]
    
    run = trigger_job(steps_override)
