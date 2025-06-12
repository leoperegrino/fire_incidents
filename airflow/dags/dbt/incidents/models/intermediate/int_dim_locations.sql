with source as (
	select
		*,
		{{ dbt_utils.generate_surrogate_key([
			'address',
			'city',
			'zipcode',
			'battalion',
			'station_area',
			'box',
			'supervisor_district',
			'neighborhood_district',
			'latitude',
			'longitude'
		]) }} as location_id
	from {{ ref('stg_fire_incidents') }}
),

location as (
	select distinct
		location_id as id,
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
