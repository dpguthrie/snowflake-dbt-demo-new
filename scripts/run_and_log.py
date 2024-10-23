# stdlib
import enum
import logging
import os
import re
import sys

# third party
import requests
from dbtc import dbtCloudClient

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Env Vars
DBT_CLOUD_SERVICE_TOKEN = os.environ["DBT_CLOUD_SERVICE_TOKEN"]
DBT_CLOUD_ACCOUNT_ID = os.environ["DBT_CLOUD_ACCOUNT_ID"]
DBT_CLOUD_ENVIRONMENT_ID = os.environ["DBT_CLOUD_ENVIRONMENT_ID"]
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


NODE_TYPES = ["Model", "Seed", "Snapshot", "Test"]
QUERY = """
query Applied($environmentId: BigInt!, $filter: AppliedResourcesFilter!, $first: Int, $after: String) {
  environment(id: $environmentId) {
    applied {
      resources(filter: $filter, first: $first, after: $after) {
        edges {
          node {
            ... on ModelAppliedStateNode {
              modelExecutionInfo: executionInfo {
                lastRunStatus
                lastRunError
                lastRunId
              }
              uniqueId
              resourceType
            }
            ... on TestAppliedStateNode {
              testExecutionInfo: executionInfo {
                lastRunStatus
                lastRunError
                lastRunId
              }
              uniqueId
              resourceType
            }
            ... on SeedAppliedStateNode {
              seedExecutionInfo: executionInfo {
                lastRunStatus
                lastRunError
                lastRunId
              }
              uniqueId
              resourceType
            }
            ... on SnapshotAppliedStateNode {
              snapshotExecutionInfo: executionInfo {
                lastRunStatus
                lastRunError
                lastRunId
              }
              uniqueId
              resourceType
            }
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


def extract_pr_number(s):
    match = re.search(r"refs/pull/(\d+)/merge", s)
    return int(match.group(1)) if match else None


def get_nodes_with_errors(nodes: list[dict], run_id: int) -> dict:
    def get_execution_info(node) -> tuple[bool, str]:
        resource_type = node.get("resourceType", "").lower()
        execution_info_key = f"{resource_type}ExecutionInfo" if resource_type else None
        is_error = (
            execution_info_key
            and node.get(execution_info_key)
            and node.get(execution_info_key).get("lastRunId") == run_id
            and node.get(execution_info_key).get("lastRunStatus", "").lower()
            in ("error", "fail")
        )
        return is_error, execution_info_key

    all_errors = []
    for node in nodes:
        is_error, execution_info_key = get_execution_info(node)
        if is_error:
            all_errors.append(
                {
                    "resource_type": node["resource_type"],
                    "message": node[execution_info_key]["lastRunError"],
                    "status": node[execution_info_key]["lastRunStatus"],
                    "uniqueId": node["uniqueId"],
                }
            )

    return all_errors


def create_comment(errors: list[dict], run_url: str):
    comment = "## dbt Cloud Job Run Results\n\n"
    comment += f"[View full job run details]({run_url})\n\n"
    comment += f"❌ {len(errors)} resource(s) encountered errors:\n\n"
    for error in errors:
        comment += f"### {error['resource_type']}: `{error['uniqueId']}`\n"
        comment += f"**Status:** `{error['status']}`\n"
        comment += "**Error Message:**\n```\n"
        comment += error["message"]
        comment += "\n```\n\n"
    return comment


def comment_on_pr(payload) -> requests.Response:
    pull_request_id = extract_pr_number(GITHUB_REF)
    session = requests.Session()
    session.headers = {"Authorization": f"Bearer {GITHUB_TOKEN}"}
    url = (
        f"https://api.github.com/repos/{GITHUB_REPO}/issues/{pull_request_id}/comments"
    )
    response = client.post(url, json=payload)
    return response


if __name__ == "__main__":
    # Set up client
    client = dbtCloudClient(host=DBT_CLOUD_HOST, token=DBT_CLOUD_SERVICE_TOKEN)

    # Extract PR Number
    pull_request_id = extract_pr_number(GITHUB_REF)

    # Create schema
    schema_override = f"dbt_cloud_pr_{DBT_CLOUD_JOB_ID}_{pull_request_id}"

    # Create payload to pass to job (modify how you see fit, 'cause' is required)
    payload = {
        "cause": "CI Triggered via Github Action",
        "schema_override": schema_override,
        "git_branch": GITHUB_BRANCH,
        "github_pull_request_id": pull_request_id,
    }

    # Trigger Job, will poll for completion automatically
    run = client.cloud.trigger_autoscaling_ci_job(
        DBT_CLOUD_ACCOUNT_ID, DBT_CLOUD_JOB_ID, payload
    )

    # Data should be a dictionary
    run_data = run.get("data", None)
    if run_data is None:
        logging.error(f"An error occurred, see response:\n{run}")
        sys.exit(1)

    # should contain a status key
    try:
        run_status = run_data["status"]
    except KeyError:
        logging.error(f"Error occurred retrieving job status. See response:\n{run}")
        sys.exit(1)

    # If success, just exit
    if run_status == JobRunStatus.SUCCESS:
        url = run_data["href"]
        logging.info(f"CI Job completed successfully.  View here: {url}")
        sys.exit(0)

    # If error, retrieve errors
    if run_status == JobRunStatus.ERROR:
        run_id = run_data["id"]
        variables = {
            "environmentId": DBT_CLOUD_ENVIRONMENT_ID,
            "filter": {"types": NODE_TYPES},
            "first": 500,
        }
        nodes = client.metadata.query(QUERY, variables, paginated_request_to_list=True)
        error_nodes = get_nodes_with_errors(nodes)
        comment = create_comment(error_nodes)
        payload = {"body": comment}
        response = comment_on_pr(payload)
        if response.ok:
            logger.info("Comment posted to PR")
        else:
            logger.error(f"Error posting comment to PR: {response.text}")
        sys.exit(1)

    # If cancelled, just exit in a failed state
    if run_status == JobRunStatus.CANCELLED:
        logger.error(f"Job cancelled.  See run info:\n{run}")
        sys.exit(1)
