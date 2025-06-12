# Airflow Configuration

This directory contains the Airflow orchestration setup for the Fire Incidents data pipeline.

## Overview

The pipeline consists of two main components:
- **Extract/Load Task**: Pulls data from SF Fire API and loads to PostgreSQL
- **dbt Models**: Transforms raw data into analytics-ready dimensional models

## DAG Structure

The `fire_incident_elt` DAG runs daily and includes:

1. **extract_and_load**: Incremental data extraction from Socrata API
2. **dbt models**: Automated transformation pipeline using Cosmos

## Key Features

**Incremental Processing**: Only pulls new/updated records using CDC timestamp
**Conflict Resolution**: Upserts data using PostgreSQL ON CONFLICT handling
**Error Handling**: Built-in retries and transaction safety
**dbt Integration**: Cosmos library provides native dbt orchestration

## Configuration

The DAG requires these environment variables:

- `AIRFLOW_CONN_INCIDENTS`: PostgreSQL connection string

```bash
# Airflow configuration
cat <<EOF > .env
_AIRFLOW_WWW_USER_USERNAME="airflow"
_AIRFLOW_WWW_USER_PASSWORD="airflow"
AIRFLOW_CONN_INCIDENTS='{
   "conn_type": "postgres",
   "login": "postgres",
   "password": "postgres",
   "schema": "warehouse",
   "host": "incidents-incidents_db-1",
   "port": 5432,
   "extra": {"options": "-c search_path=raw"}
}'
EOF
```

## Data Flow

```
SF Fire API -> extract_load() -> PostgreSQL (raw) -> dbt models -> Analytics tables
```

## Monitoring

- Pipeline runs daily at midnight
- First run pulls all historical data (~15 minutes)
- Subsequent runs process only new records (<5 minutes)
- Airflow Variable `latest_data` tracks CDC watermark

## Files

- `dbt_dag.py`: Main pipeline DAG with extract/load and dbt orchestration
- `dbt/incidents/`: Complete dbt project with dimensional models
- `requirements.txt`: Python dependencies for the Dockerfile

## Running

The DAG automatically starts after Airflow deployment. Monitor progress in the
Airflow UI at localhost:8080.
