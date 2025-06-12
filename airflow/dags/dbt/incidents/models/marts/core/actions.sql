with source as (
	select *
	from {{ ref('int_dim_actions') }}
)

select *
from source
