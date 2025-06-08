# Airflow

## dbt_dag

- uses cosmos library from astronomer to interpret DBTs project as a DAG
- grants observability to your dbt run in airflow, instead of just using a BashOperator to call
- provides better configuration and customization through airflow's features

### `extract_load` task

- retrieves all data in the remote server and stores in postgres
- handles cdc automatically
- handles repeated indexes through parameters `replace` and `replace_index` from `PostgresHook.insert_row`
- if needed, is possible to delete the `latest_data` airflow variable so it pulls all data
- has @daily schedule as is with the remote server
