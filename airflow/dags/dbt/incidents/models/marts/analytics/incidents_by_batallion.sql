with location as (
	select *
	from {{ ref('int_dim_locations') }}
),

incidents as (
	select *
	from {{ ref('int_fact_incidents') }}
),

battalion_stats as (
	select
		l.battalion,
		count(i.id) as incident_count,
		count(case when i.fire_fatalities > 0 or i.civilian_fatalities > 0 then 1 end) as fatal_incidents,
		count(case when i.fire_injuries > 0 or i.civilian_injuries > 0 then 1 end) as injury_incidents,
		sum(i.fire_fatalities + i.civilian_fatalities) as total_fatalities,
		sum(i.fire_injuries + i.civilian_injuries) as total_injuries,
		sum(coalesce(i.estimated_property_loss, 0) + coalesce(i.estimated_contents_loss, 0)) as total_estimated_loss,
		avg(i.suppression_units + i.ems_units + i.other_units) as avg_units_per_incident,
		avg(i.suppression_personnel + i.ems_personnel + i.other_personnel) as avg_personnel_per_incident,
		max(i.number_of_alarms) as max_alarms,
		avg(i.number_of_alarms) as avg_alarms
	from incidents i
	join location l on i.location_id = l.id
	where l.battalion is not null
	group by l.battalion
)

select
	battalion,
	incident_count,
	fatal_incidents,
	injury_incidents,
	total_fatalities,
	total_injuries,
	round(total_estimated_loss::numeric, 2) as total_estimated_loss,
	round(avg_units_per_incident, 1) as avg_units_per_incident,
	round(avg_personnel_per_incident, 1) as avg_personnel_per_incident,
	max_alarms,
	round(avg_alarms, 2) as avg_alarms_per_incident,
	round(total_estimated_loss::numeric / incident_count, 2) as avg_loss_per_incident,
	round((total_fatalities + total_injuries)::numeric / incident_count * 100, 2) as casualty_rate_percent
from battalion_stats
order by incident_count desc
