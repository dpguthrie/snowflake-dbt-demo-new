#!/usr/bin/env python
import os

import yaml

if __name__ == "__main__":
    dbt_cloud_config = {
        "version": 1,
        "context": {
            "active-project": os.environ["DBT_CLOUD_PROJECT_ID"],
            "active-host": os.environ["DBT_CLOUD_HOST"],
        },
        "projects": [
            {
                "project-name": os.environ["DBT_CLOUD_PROJECT_NAME"],
                "project-id": os.environ["DBT_CLOUD_PROJECT_ID"],
                "account-name": os.environ["DBT_CLOUD_ACCOUNT_NAME"],
                "account-id": os.environ["DBT_CLOUD_ACCOUNT_ID"],
                "account-host": os.environ["DBT_CLOUD_HOST"],
                "token-name": "gh-action-pre-commit",
                "token-value": os.environ["DBT_CLOUD_API_KEY"],
            }
        ],
    }

    print(yaml.dump(dbt_cloud_config))
