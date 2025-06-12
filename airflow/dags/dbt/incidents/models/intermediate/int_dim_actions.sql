with source as (
	select *
	from {{ ref('stg_fire_incidents') }}
),

all_actions as (
	select
		action_taken_primary_id as id,
		action_taken_primary as action
	from source
	union
	select
		action_taken_secondary_id as id,
		action_taken_secondary as action
	from source
	union
	select
		action_taken_other_id as id,
		action_taken_other as action
	from source
),

parsed as (
	select distinct
		case
			when id ~ '^-?\d+$' then id::integer
			else null
		end as id,
		action
	from all_actions
)

select
	id,
	action
from parsed
where id is not null
