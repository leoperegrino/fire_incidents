with source as (
	select *
	from {{ ref('int_dim_locations') }}
)

select *
from source
