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


ERROR_STATUSES = {
    "error": {
        "resource": "model",
        "plural": "error",
        "icon": ":x:",
    },
    "fail": {
        "resource": "test",
        "plural": "failure",
        "icon": ":x:",
    },
    "warn": {
        "resource": "test",
        "plural": "warning",
        "icon": ":warning: ",
    },
}


def extract_pr_number(s):
    match = re.search(r"refs/pull/(\d+)/merge", s)
    return int(match.group(1)) if match else None


def get_results_with_errors(run_results: list[dict]) -> dict:
    all_errors = {status: [] for status in ERROR_STATUSES.keys()}
    for result in run_results:
        if result.get("status", None) in ERROR_STATUSES.keys():
            all_errors[result["status"]].append(
                {
                    "resource_type": result["unique_id"].split(".")[0],
                    "message": result["message"],
                    "status": result["status"],
                    "uniqueId": result["unique_id"],
                }
            )

    return all_errors


def create_comment(all_errors: dict[str, list], run_url: str):
    comment = "## dbt Cloud Job Run Results\n\n"
    comment += f"[View full job run details]({run_url})\n\n"
    for error_type, error_list in all_errors.items():
        icon = ERROR_STATUSES[error_type]['icon']
        resource = ERROR_STATUSES[error_type]['resource']
        plural = ERROR_STATUSES[error_type]['plural']
        comment += f"{icon} {len(error_list)} {resource}(s) encountered {plural}s:\n\n"
        for error in error_list:
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
    response = session.post(url, json=payload)
    return response


if __name__ == "__main__":
    # Set up client
    client = dbtCloudClient(host=DBT_CLOUD_HOST)

    # Extract PR Number
    pull_request_id = extract_pr_number(GITHUB_REF)

    # Create schema
    schema_override = f"dbt_cloud_pr_{DBT_CLOUD_JOB_ID}_{pull_request_id}"

    # Create payload to pass to job
    # https://docs.getdbt.com/docs/deploy/ci-jobs#trigger-a-ci-job-with-the-api
    payload = {
        "cause": "CI Triggered via Github Action",
        "schema_override": schema_override,
        "git_branch": GITHUB_BRANCH,
        "github_pull_request_id": pull_request_id,
    }

    # Trigger Job, poll until completion
    run = client.cloud.trigger_job(
        DBT_CLOUD_ACCOUNT_ID,
        DBT_CLOUD_JOB_ID,
        payload,
        should_poll=True,
    )

    # Data should be a dictionary
    run_data = run.get("data", None)
    if run_data is None:
        logging.error(f"An error occurred, see response:\n{run}")
        sys.exit(1)

    # run_data should contain a status key
    try:
        run_status = run_data["status"]
    except KeyError:
        logging.error(f"Error occurred retrieving job status. See response:\n{run}")
        sys.exit(1)

    # Extract url
    url = run_data["href"]

    # Get run results
    run_id = run_data["id"]
    run_results_response = client.cloud.get_run_artifact(
        DBT_CLOUD_ACCOUNT_ID, run_id, "run_results.json"
    )
    try:
        run_results = run_results_response["results"]
    except KeyError:
        logger.error(
            f"Problem retrieving logs after run.  Please view the run on dbt Cloud: {url}"
        )
        sys.exit(1)

    error_nodes = get_results_with_errors(run_results)
    logger.info(error_nodes)
    if any(errors for errors in error_nodes.values()):
        comment = create_comment(error_nodes, url)
        payload = {"body": comment}
        response = comment_on_pr(payload)
        if not response.ok:
            logger.error(f"Error posting comment to PR: {response.text}")
            logger.error(f"See errors below:\n {comment}")
            
    if run_status in (JobRunStatus.ERROR, JobRunStatus.CANCELLED):
        sys.exit(1)
        
    sys.exit(0)
