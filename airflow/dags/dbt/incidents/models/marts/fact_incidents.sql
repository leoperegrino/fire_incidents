with source as (
	select *
	from {{ ref('stg_fire_incidents') }}
)
{% if is_incremental() %}
,
latest_data as (
	select
		coalesce(max(data_loaded_at),'1900-01-01'::timestamp) as latest
	from {{ this }} 
)
{% endif %}

select
	id,
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

{% if is_incremental() %}

	where data_loaded_at >= (select latest from latest_data)

{% endif %}
