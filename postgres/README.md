# Postgres

## Overview

PostgreSQL database for storing incidents data. Creates the
raw schema and incidents table automatically on startup.
Use the main docker-compose.yaml in the project root to start the full stack.
Starting this PostgreSQL service alone will not allow proper communication with
Airflow unless you connect the different docker networks.


## Setup

1. Create `.env` file:

```bash
cat <<EOF > .env
POSTGRES_DB=warehouse
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
EOF
```

2. Start database:

```bash
docker compose up -d
```

## Initialization

The `init/01-create.sql` script runs automatically on first startup to:
- Create the `raw` schema
- Create the `incidents` table with proper data types
- Set up primary key for conflict resolution during data loads
