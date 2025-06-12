# dbt Fire Incidents Project

This dbt project transforms raw fire incident data into analytics-ready
dimensional models using the medallion architecture pattern.

## Project Structure

**Staging Layer** (Bronze): Raw data cleaning and standardization

- `stg_fire_incidents.sql`: Base staging model with data type conversions

**Intermediate Layer** (Silver): Dimensional model preparation

- `int_dim_*`: Dimension tables for time, location, actions, factors, situations
- `int_fact_incidents.sql`: Fact table with foreign key relationships

**Marts Layer** (Gold): Business-ready analytics models

- `core/`: Clean dimensional tables for general analysis
- `analytics/`: Pre-aggregated tables for specific business questions

## Key Models

**Core Models**:

- `incidents`: Main fact table with dimensional relationships
- `locations`, `actions`, `time`: Clean dimension tables

**Analytics Models**:

- `incidents_by_batallion`: Resource allocation metrics
- `monthly_incidents`: Temporal trend analysis
- `neighborhood_risk`: Geographic risk assessment
- `seasonal_patterns`: Quarterly and seasonal insights

## Data Architecture

The project implements a star schema with proper foreign key relationships and
surrogate keys generated using dbt_utils.

## Manual Execution

```bash
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
cd incidents
export \
    POSTGRES_HOST=localhost \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres \
    POSTGRES_PORT=5432 \
    POSTGRES_DB=warehouse \
    POSTGRES_SCHEMA=incidents
dbt build
```

## Dependencies

- dbt-postgres
- dbt-utils for surrogate keys and date spine generation
- dbt-constraints for primary key enforcement
