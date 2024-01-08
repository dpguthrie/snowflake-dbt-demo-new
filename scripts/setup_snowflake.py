# stdlib
import os

import snowflake.connector
from titan import Blueprint
from titan.resources import Database, Grant, Role, RoleGrant, User, Warehouse

# connection_params = {
#     "account": os.environ["SNOWFLAKE_ACCOUNT"],
#     "user": os.environ["SNOWFLAKE_USER"],
#     "password": os.environ["SNOWFLAKE_PASSWORD"],
# }

connection_params = {
    "account": "zna84829",
    "user": "DOUG_G",
    "password": "z@ELk9XVwutR_Zuae.",
}

DEFAULT_WAREHOUSE_OPTIONS = {
    "warehouse_size": "XSMALL",
    "auto_suspend": 60,
    "min_cluster_count": 1,
    "max_cluster_count": 1,
}

DEVELOPERS = []


def dbt():
    # Databases
    raw_db = Database(name="RAW_DPG")
    dev_db = Database(name="ANALYTICS_DPG_DEV")
    ci_db = Database(name="ANALYTICS_DPG_CI")
    prod_db = Database(name="ANALYTICS_DPG")

    # Warehouses
    developer_wh = Warehouse(
        name="DEVELOPER_DPG_WH",
        comment="Warehouse used for developer workloads.",
        **DEFAULT_WAREHOUSE_OPTIONS,
    )
    loading_wh = Warehouse(
        name="LOADING_DPG_WH",
        comment="Warehouse used for loading workloads.",
        **DEFAULT_WAREHOUSE_OPTIONS,
    )
    transforming_wh = Warehouse(
        name="TRANSFORMING_DPG_WH",
        comment="Warehouse used for transformation workloads.",
        **DEFAULT_WAREHOUSE_OPTIONS,
    )
    reporting_wh = Warehouse(
        name="REPORTING_DPG_WH",
        comment="Warehouse used for reporting workloads.",
        **DEFAULT_WAREHOUSE_OPTIONS,
    )
    snowpark_optimized_wh = Warehouse(
        name="SNOWPARK_DPG_WH",
        comment="Warehouse used for snowpark workloads.",
        warehouse_type="SNOWPARK-OPTIMIZED",
        **DEFAULT_WAREHOUSE_OPTIONS,
    )

    # Roles
    raw_data_reader_role = Role(
        name="RAW_DATA_READER_ROLE", comment="Able to read raw data."
    )
    raw_data_loader_role = Role(
        name="RAW_DATA_LOADER_ROLE", comment="Able to load raw data into warehouse."
    )
    analyst_role = Role(
        name="ANALYST_ROLE",
        comment="Able to read from prod database.",
    )
    developer_role = Role(
        name="DEVELOPER_ROLE",
        comment=(
            "Able to write to dev database, and read from raw and analytics "
            " databases."
        ),
    )
    transformer_role = Role(
        name="TRANSFORMER_ROLE",
        comment=f"Able to read from and write to {prod_db.name} database.",
    )
    snowflake_internal_reader_role = Role(
        name="SNOWFLAKE_INTERNAL_READER_ROLE",
        comment="Able to read from SNOWFLAKE database",
        owner="ACCOUNTADMIN",
    )

    # Users
    loading_user = User(
        name="LOADING_USER",
        default_warehouse=loading_wh.name,
        default_role=raw_data_loader_role.name,
    )
    reporting_user = User(
        name="REPORTING_USER",
        default_warehouse=reporting_wh.name,
        default_role=analyst_role.name,
    )
    dbt_user = User(
        name="DBT_USER",
        default_warehouse=transforming_wh.name,
        default_role=transformer_role.name,
    )
    snowflake_internal_user = User(
        name="SNOWFLAKE_INTERNAL_USER",
        default_warehouse=reporting_wh.name,
        default_role=snowflake_internal_reader_role.name,
    )

    system_users = [loading_user, reporting_user, dbt_user, snowflake_internal_user]

    developer_users = []
    for developer in DEVELOPERS:
        developer_users.append(
            User(
                name=f"{developer}_USER",
                default_warehouse=developer_wh.name,
                default_role=developer_role.name,
            )
        )

    # Grants
    role_grants = [
        RoleGrant(role=raw_data_reader_role, to_role="SYSADMIN"),
        RoleGrant(role=raw_data_reader_role, to_role=raw_data_loader_role),
        RoleGrant(role=raw_data_reader_role, to_role=developer_role),
        RoleGrant(role=raw_data_reader_role, to_role=transformer_role),
        RoleGrant(role=analyst_role, to_role="SYSADMIN"),
        RoleGrant(role=analyst_role, to_role=developer_role),
        RoleGrant(role=developer_role, to_role="SYSADMIN"),
        RoleGrant(role=analyst_role, to_role=transformer_role),
        RoleGrant(role=transformer_role, to_role=developer_role),
        RoleGrant(role=transformer_role, to_role="SYSADMIN"),
    ]
    user_role_grants = [
        RoleGrant(role=raw_data_loader_role, to_user=loading_user),
        RoleGrant(role=analyst_role, to_user=reporting_user),
        RoleGrant(role=transformer_role, to_user=dbt_user),
        RoleGrant(role=snowflake_internal_reader_role, to_user=snowflake_internal_user),
    ]
    # Grants
    grants = [
        # Raw data reader grants
        Grant(priv="USAGE", on=raw_db, to=raw_data_reader_role),
        # Grant(priv="USAGE", on_all_schemas_in=raw_db, to=raw_data_reader_role),
        # Grant(priv="USAGE", on_all_future_schemas_in=raw_db, to=raw_data_reader_role),
        # Grant(priv="SELECT", on_all_tables_in=raw_db, to=raw_data_reader_role),
        # Grant(priv="SELECT", on_future_tables_in=raw_db, to=raw_data_reader_role),
        # # Raw data loader grants
        # Grant(priv="OWNERSHIP", on=raw_db, to=raw_data_loader_role),
        # Grant(priv="OWNERSHIP", on_all_schemas_in=raw_db, to=raw_data_loader_role),
        # Grant(priv="OWNERSHIP", on_all_tables_in=raw_db, to=raw_data_loader_role),
        # Grant(priv="OWNERSHIP", on_all_views_in=raw_db, to=raw_data_loader_role),
        # Grant(priv="ALL", on_future_schemas_in=raw_db, to=raw_data_loader_role),
        # Grant(priv="ALL", on_future_tables_in=raw_db, to=raw_data_loader_role),
        # Grant(priv="ALL", on_future_views_in=raw_db, to=raw_data_loader_role),
        # Grant(priv="USAGE", on=loading_wh, to=raw_data_loader_role),
        # # Analyst grants
        # Grant(priv="USAGE", on=prod_db, to=analyst_role),
        # Grant(priv="USAGE", on_all_schemas_in=prod_db, to=analyst_role),
        # Grant(priv="SELECT", on_all_tables_in=prod_db, to=analyst_role),
        # Grant(priv="SELECT", on_all_views_in=prod_db, to=analyst_role),
        # Grant(priv="USAGE", on_future_schemas_in=prod_db, to=analyst_role),
        # Grant(priv="SELECT", on_future_tables_in=prod_db, to=analyst_role),
        # Grant(priv="SELECT", on_future_views_in=prod_db, to=analyst_role),
        # Grant(priv="USAGE", on=reporting_wh, to=analyst_role),
        # Grant(priv="USAGE", on=developer_wh, to=analyst_role),
        # # Developer grants
        # ## Developer role has full ownership of dev_db
        # Grant(priv="OWNERSHIP", on=dev_db, to=developer_role),
        # Grant(priv="OWNERSHIP", on_all_schemas_in=dev_db, to=developer_role),
        # Grant(priv="OWNERSHIP", on_all_tables_in=dev_db, to=developer_role),
        # Grant(priv="OWNERSHIP", on_all_views_in=dev_db, to=developer_role),
        # Grant(priv="ALL", on_future_schemas_in=dev_db, to=developer_role),
        # Grant(priv="ALL", on_future_tables_in=dev_db, to=developer_role),
        # Grant(priv="ALL", on_future_views_in=dev_db, to=developer_role),
        # Grant(priv="USAGE", on=ci_db, to=developer_role),
        # ## Developer role also can select from ci_db
        # Grant(priv="USAGE", on_all_schemas_in=ci_db, to=developer_role),
        # Grant(priv="SELECT", on_all_tables_in=ci_db, to=developer_role),
        # Grant(priv="SELECT", on_all_views_in=ci_db, to=developer_role),
        # Grant(priv="USAGE", on_future_schemas_in=ci_db, to=developer_role),
        # Grant(priv="SELECT", on_future_tables_in=ci_db, to=developer_role),
        # Grant(priv="SELECT", on_future_views_in=ci_db, to=developer_role),
        # Grant(priv="USAGE", on=developer_wh, to=developer_role),
        # # Transformer grants (See below, done across both CI and Prod DBs)
        # Grant(priv="USAGE", on=transforming_wh, to=transformer_role),
        # # Snowflake Internal grants
        # Grant(priv="USAGE", on=reporting_wh, to=snowflake_internal_reader_role),
        # Grant(
        #     priv="IMPORTED", on_database="SNOWFLAKE", to=snowflake_internal_reader_role
        # ),
        # Grant(priv="IMPORTED", on_database="SNOWFLAKE", to_role="SYSADMIN"),
    ]

    # for db in [ci_db, prod_db]:
    #     grants.extend(
    #         [
    #             Grant(priv="OWNERSHIP", on=db, to=transformer_role),
    #             Grant(priv="OWNERSHIP", on_all_schemas_in=db, to=transformer_role),
    #             Grant(priv="ALL", on_all_tables_in=db, to=transformer_role),
    #             Grant(priv="ALL", on_all_views_in=db, to=transformer_role),
    #             Grant(priv="ALL", on_future_schemas_in=db, to=transformer_role),
    #             Grant(priv="ALL", on_future_tables_in=db, to=transformer_role),
    #             Grant(priv="ALL", on_future_views_in=db, to=transformer_role),
    #         ]
    #     )

    return (
        raw_db,
        dev_db,
        ci_db,
        prod_db,
        loading_wh,
        transforming_wh,
        reporting_wh,
        developer_wh,
        snowpark_optimized_wh,
        raw_data_loader_role,
        raw_data_reader_role,
        analyst_role,
        developer_role,
        transformer_role,
        *system_users,
        *developer_users,
        *role_grants,
        *user_role_grants,
        *grants,
    )


if __name__ == "__main__":
    bp = Blueprint(name="setup-dbt", account="zna84829")
    # bp = Blueprint(name="setup-dbt", account=os.environ["SNOWFLAKE_ACCOUNT"])
    bp.add(*dbt())
    session = snowflake.connector.connect(**connection_params)
    plan = bp.plan(session)

    print(plan)
    # Update snowflake to match blueprint
    # bp.apply(session, plan)
