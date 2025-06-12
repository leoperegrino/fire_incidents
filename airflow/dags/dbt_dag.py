import logging
import os
from datetime import datetime
from datetime import timedelta
from pathlib import Path

import pandas as pd
import psycopg2.extensions
import psycopg2.extras
from cosmos import DbtDag, ProfileConfig, ProjectConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping
from sodapy import Socrata

from airflow.decorators import task
from airflow.models.variable import Variable
from airflow.providers.postgres.hooks.postgres import PostgresHook

logger = logging.getLogger(__name__)

# so the point column can be inserted as jsonb
psycopg2.extensions.register_adapter(dict, psycopg2.extras.Json)


DEFAULT_DBT_ROOT_PATH = Path(__file__).parent / "dbt"
DBT_ROOT_PATH = Path(os.getenv("DBT_ROOT_PATH", DEFAULT_DBT_ROOT_PATH))


profile_config = ProfileConfig(
    profile_name="default",
    target_name="dev",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id="incidents",
        profile_args={"schema": "incidents"},
    ),
)

with DbtDag(
    project_config=ProjectConfig(
        DBT_ROOT_PATH / "incidents",
    ),
    profile_config=profile_config,
    operator_args={
        "install_deps": True,
        "full_refresh": True,
    },

    # normal dag parameters
    schedule_interval="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    dag_id="fire_incident_elt",
    default_args={"retries": 0},
    max_active_runs=1,
) as dag:

    @task(task_id='extract_and_load',
        retries=3,
        retry_delay=timedelta(minutes=5),
    )
    def extract_load() -> None:
        """Extract only latest data and load it safely with UPSERT behaviour
        """
        latest = Variable.get('latest_data', default_var=None)
        client = Socrata("data.sfgov.org", None)

        if latest:
            logger.info("Pulling all data newer than %s", latest)
            where = f'data_loaded_at > "{latest}"'
            results = client.get("wr8u-xric", where=where)
        else:
            logger.info("It seems this is the extraction first run. Pulling all data")
            results = client.get_all("wr8u-xric")

        df = pd.DataFrame.from_records(results)

        if df.empty:
            logger.info("Returned dataframe is empty. The database is up to date.")
            return

        new_latest = df.data_loaded_at.map(datetime.fromisoformat).max()

        target_hook = PostgresHook('incidents')

        # fix wrong cast 'NaN'::float when using `insert_rows`
        df.replace({float('nan'): None}, inplace=True)

        target_hook.insert_rows(
            'incidents',
            df.values,
            target_fields=tuple(df.columns),
            replace=True,
            replace_index=('id',),
            commit_every=50000,
            executemany=True,
            fast_executemany=True,
        )

        Variable.set('latest_data', new_latest.isoformat())

        logger.info("Successfully loaded %s records to incidents table", len(df))


    el = extract_load()
    el >> dag.tasks_map['model.incidents.stg_fire_incidents']  # pyright: ignore[reportUnusedExpression]
