with time as (
	select *
	from {{ ref('int_dim_time') }}
),

incidents as (
	select *
	from {{ ref('int_fact_incidents') }}
)

select
	t.year,
	t.month,
	t.month_name,
	count(i.id) as incident_count,
	count(case when i.fire_fatalities > 0 or i.civilian_fatalities > 0 then 1 end) as fatal_incidents,
	count(case when i.fire_injuries > 0 or i.civilian_injuries > 0 then 1 end) as injury_incidents,
	sum(i.suppression_units + i.ems_units + i.other_units) as total_units_deployed,
	sum(i.suppression_personnel + i.ems_personnel + i.other_personnel) as total_personnel_deployed,
	sum(coalesce(i.estimated_property_loss, 0) + coalesce(i.estimated_contents_loss, 0)) as total_estimated_loss
from incidents i
join time t on i.incident_date = t.date_day
group by t.year, t.month, t.month_name
order by t.year, t.month
