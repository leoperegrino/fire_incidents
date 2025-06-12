with location as (
	select *
	from {{ ref('int_dim_locations') }}
),

incidents as (
	select *
	from {{ ref('int_fact_incidents') }}
),

neighborhood_risk AS (
	select
		l.neighborhood_district,
		count(i.id) as incident_count,
		count(case when i.fire_fatalities > 0 or i.civilian_fatalities > 0 then 1 end) as fatal_incidents,
		sum(i.fire_fatalities + i.civilian_fatalities) as total_fatalities,
		sum(i.fire_injuries + i.civilian_injuries) as total_injuries,
		sum(coalesce(i.estimated_property_loss, 0) + coalesce(i.estimated_contents_loss, 0)) as total_estimated_loss,
		avg(i.number_of_alarms) as avg_severity_score
	from incidents i
	join location l on i.location_id = l.id
	where l.neighborhood_district is not null
	group by l.neighborhood_district
)
select
	neighborhood_district,
	incident_count,
	fatal_incidents,
	total_fatalities,
	total_injuries,
	round(total_estimated_loss::numeric, 2) as total_estimated_loss,
	round(avg_severity_score, 2) as avg_severity_score,
	round(total_estimated_loss::numeric / incident_count, 2) as avg_loss_per_incident,
	round((total_fatalities + total_injuries)::numeric / incident_count * 100, 2) as casualty_rate_percent,
	row_number() over (order by incident_count desc) as incident_rank,
	row_number() over (order by (total_fatalities + total_injuries)::numeric / incident_count desc) as casualty_rank
from neighborhood_risk
order by incident_count desc
