# San Francisco Fire Incidents Data Pipeline

A modern data engineering pipeline analyzing San Francisco Fire Department
incident data using the medallion architecture pattern. This project implements
a complete ELT (Extract, Load, Transform) workflow with CDC, automated
orchestration, dimensional modeling, and data quality testing.

## Architecture Overview

This pipeline follows modern data engineering best practices with a **medallion
architecture** built on:

- **Data Source**: [SF Fire Incidents API](https://data.sfgov.org/Public-Safety/Fire-Incidents/wr8u-xric/about_data) (~706K records, 66 columns)
- **Orchestration**: Apache Airflow with Astronomer Cosmos for dbt integration
- **Data Warehouse**: PostgreSQL with dimensional star schema
- **Transformation**: dbt with layered models (staging → intermediate → marts)
- **Infrastructure**: Fully containerized with Docker Compose

### Data Flow

```
SF Fire API → Airflow (Extract/Load) → PostgreSQL (Bronze) → dbt (Transform) → Analytics Models (Gold)
```

## Key Features

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

- **Temporal Patterns**: When do incidents peak throughout the day/week/year?

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

- **Geographic Hotspots**: Where are high-risk neighborhoods for different incident types?

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


- **Response Optimization**: What factors correlate with incident severity?

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

1. **Clone and Setup Environment**

```bash
git clone https://github.com/leoperegrino/fire_incidents
cd fire-incidents-pipeline
   ```

2. **Configure Environment Variables**

```bash
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
```

3. **Deploy Pipeline**

```bash
docker compose up -d --build
```

4. **Access Services**

- **Airflow UI**: http://localhost:8080 (airflow/airflow)
- **Database**: localhost:5432 (postgres/postgres)

5. **Run Pipeline**

- Trigger the `dbt_dag` in Airflow UI
- First run extracts all historical data (~10-15 minutes)
- Subsequent runs process only new/updated records

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

## Documentation

For detailed component documentation:

- **[Airflow Setup & DAG Configuration](./airflow/README.md)**
- **[PostgreSQL Schema & Database Design](./postgres/README.md)**
- **[dbt Models & Transformations](./airflow/dags/dbt/incidents/README.md)**

## Technical Highlights

- **API Integration**: SODA 2.1 API with sodapy library for efficient data extraction
- **Change Data Capture**: Incremental processing using timestamp-based CDC
- **Conflict Resolution**: Upsert operations with `ON CONFLICT` handling
- **Data Modeling**: Star schema with proper foreign key relationships
- **Testing**: Comprehensive data quality tests at each transformation layer
- **Monitoring**: Structured logging and Airflow task monitoring

## Data Pipeline Metrics

- **Source Records**: 706K+ fire incidents (growing daily)
- **Processing Time**: ~15 minutes initial load, <5 minutes incremental
- **Data Freshness**: Daily updates matching source system
- **Quality Gates**: 15+ dbt tests ensuring data integrity
