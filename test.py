# stdlib

import snowflake.connector
from titan import Blueprint
from titan.resources import Database

connection_params = {
    "account": "zna84829",
    "user": "DOUG_G",
    "password": "z@ELk9XVwutR_Zuae.",
}


def dbt():
    database = Database(name="DBT_DPG")
    return [database]


bp = Blueprint(name="setup-dbt")
# bp = Blueprint(name="setup-dbt", account=os.environ["SNOWFLAKE_ACCOUNT"])
bp.add(*dbt())
session = snowflake.connector.connect(**connection_params)
plan = bp.plan(session)

print(plan)
# Update snowflake to match blueprint
# bp.apply(session, plan)
