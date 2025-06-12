with source as (
	select *
	from {{ ref('int_dim_time') }}
)

select *
from source
