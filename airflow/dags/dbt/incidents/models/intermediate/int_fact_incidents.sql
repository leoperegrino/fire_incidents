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
)

select
	id,
	location_id,
	incident_date,
	suppression_units,
	suppression_personnel,
	ems_units,
	ems_personnel,
	other_units,
	other_personnel,
	estimated_property_loss,
	estimated_contents_loss,
	fire_fatalities,
	fire_injuries,
	civilian_fatalities,
	civilian_injuries,
	number_of_alarms,
	floor_of_fire_origin,
	number_of_floors_with_minimum_damage,
	number_of_floors_with_significant_damage,
	number_of_floors_with_heavy_damage,
	number_of_floors_with_extreme_damage,
	number_of_sprinkler_heads_operating,
	data_loaded_at
from source

