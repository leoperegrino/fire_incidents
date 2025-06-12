{{
	config(
		materialized='incremental',
		unique_key='id',
		on_schema_change='append_new_columns'
	)
}}

with source as (
	select *
	from {{ ref('int_fact_incidents') }}
)

select *
from source

{% if is_incremental() %}

  where data_loaded_at >= (select coalesce(max(data_loaded_at), '1900-01-01') from {{ this }})

{% endif %}
