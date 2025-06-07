with source as (
	select *
	from {{ ref('stg_fire_incidents') }}
),

all_situations as (
	select
		primary_situation_id as id,
		primary_situation as situation
	from source
),

parsed as (
	select distinct
		case
			when id ~ '^-?\d+$' then id::integer
			else null
		end as id,
		situation
	from all_situations
)

select
	id,
	situation
from parsed
where id is not null
