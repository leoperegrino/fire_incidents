with source as (
	select *
	from {{ ref('stg_fire_incidents') }}
),

all_factors as (
	select
		ignition_factor_primary_id as id,
		ignition_factor_primary as factor
	from source
	union
	select
		ignition_factor_secondary_id as id,
		ignition_factor_secondary as factor
	from source
),

parsed as (
	select distinct
		case
			when id ~ '^-?\d+$' then id::integer
			else null
		end as id,
		factor
	from all_factors
)

select
	id,
	factor
from parsed
where id is not null
