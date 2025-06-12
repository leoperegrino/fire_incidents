# San Francisco Fire Incidents Data Pipeline

A modern data engineering pipeline analyzing San Francisco Fire Department
incident data using the medallion architecture pattern. This project implements
a complete ELT (Extract, Load, Transform) workflow with CDC, automated
orchestration, dimensional modeling, and data quality testing.

## Project Structure

```
├── airflow/                    # Orchestration layer
│   ├── dags/dbt/incidents/     # dbt project with dimensional models
│   ├── dbt_dag.py              # Main pipeline DAG
│   └── docker-compose.yaml     # Airflow deployment
├── postgres/                   # Data warehouse setup
│   ├── init/                   # Database schema initialization
│   └── docker-compose.yaml     # Postgres deployment
└── docker-compose.yaml         # Full stack deployment
```

### cosmos UI

![./assets/cosmos.png](cosmos)

### Airflow UI

![./assets/airflow.png](airflow)

### Schema

![./assets/relationships.png](relationships)

![./assets/schema.png](schema)

For detailed component documentation:

- **[Airflow](./airflow/README.md)**
- **[Postgres](./postgres/README.md)**
- **[dbt](./airflow/dags/dbt/README.md)**


## Architecture Overview

This pipeline follows modern data engineering best practices with a **medallion
architecture** built on:

- **Data Source**: [SF Fire Incidents API](https://data.sfgov.org/Public-Safety/Fire-Incidents/wr8u-xric/about_data) (~706K records, 66 columns)
- **Orchestration**: Apache Airflow with Astronomer Cosmos for dbt integration
- **Data Warehouse**: PostgreSQL with dimensional star schema
- **Transformation**: dbt with layered models (staging → intermediate → marts)
- **Infrastructure**: Fully containerized with Docker Compose

```
SF Fire API → Airflow (Extract/Load) → PostgreSQL (Bronze) → dbt (Transform) → Analytics Models (Gold)
```

## Features

- **Incremental Processing**: Daily CDC-based updates with conflict resolution
- **Dimensional Modeling**: Star schema with time, location, action, and factor dimensions
- **Data Quality**: Comprehensive dbt tests for data validation and constraints
- **Observability**: Full pipeline visibility through Airflow UI with dbt lineage
- **Reproducibility**: One-command deployment with Docker Compose
- **Production-Ready**: Error handling, retries, and transaction safety

## Insights

This pipeline provides marts to answer questions:

- **Resource Allocation**: Which battalions handle the most incidents?

```SQL
SELECT
    battalion,
    incident_count,
    avg_personnel_per_incident,
    casualty_rate_percent
FROM incidents_analytics.incidents_by_batallion
ORDER BY incident_count DESC
LIMIT 10;
```

- **Seasonal peaks**

```SQL
SELECT
    quarter,
    month_name,
    incident_count,
    avg_units_required,
    total_loss
FROM incidents_analytics.seasonal_patterns
ORDER BY incident_count DESC;
```

- **High-risk neighborhoods**:

```SQL
SELECT
    neighborhood_district,
    incident_count,
    casualty_rate_percent,
    avg_loss_per_incident,
    incident_rank
FROM incidents_analytics.neighborhood_risk
WHERE incident_rank <= 10
ORDER BY casualty_rate_percent DESC;
```


- **Incident severity**:

```SQL
SELECT
    month_name,
    incident_count,
    fatal_incidents,
    total_personnel_deployed,
    (fatal_incidents::numeric / incident_count * 100) as fatality_rate_percent
FROM incidents_analytics.monthly_incidents
ORDER BY fatality_rate_percent DESC;
```

## Quick Start


```bash
git clone https://github.com/leoperegrino/fire_incidents
cd fire-incidents-pipeline

# Airflow configuration
cat <<EOF > ./airflow/.env
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

# PostgreSQL configuration
cat <<EOF > ./postgres/.env
POSTGRES_DB=warehouse
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
EOF

docker compose up -d --build
```

**Run Pipeline**

- **Airflow UI**: http://localhost:8080 (airflow/airflow)
- Trigger the `dbt_dag` in Airflow UI
- First run extracts all historical data (~10-15 minutes)
- Subsequent runs process only new/updated records


