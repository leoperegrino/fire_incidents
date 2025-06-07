with source as (
	select *
	from {{ ref('stg_fire_incidents') }}
),

location as (
	select distinct
		id,
		address,
		city,
		zipcode,
		battalion,
		station_area,
		box,
		supervisor_district,
		neighborhood_district,
		latitude,
		longitude
	from source
)

select *
from location
