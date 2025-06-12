with incidents as (
	select *
	from {{ ref('int_fact_incidents') }}
),

time as (
	select *
	from {{ ref('int_dim_time') }}
),

seasonal_patterns as (
	select
		t.quarter,
		t.month,
		t.month_name,
		t.is_weekend,
		count(i.id) as incident_count,
		avg(i.suppression_units + i.ems_units + i.other_units) as avg_units_required,
		sum(coalesce(i.estimated_property_loss, 0) + coalesce(i.estimated_contents_loss, 0)) as total_loss,
		count(case when i.fire_fatalities > 0 or i.civilian_fatalities > 0 then 1 end) as fatal_incidents
	from incidents i
	join time t on i.incident_date = t.date_day
	group by t.quarter, t.month, t.month_name, t.is_weekend
)

select
	quarter,
	month_name,
	case when is_weekend then 'weekend' else 'weekday' end as day_type,
	incident_count,
	round(avg_units_required, 1) as avg_units_required,
	round(total_loss::numeric, 2) as total_loss,
	fatal_incidents,
	round(total_loss::numeric / incident_count, 2) as avg_loss_per_incident
from seasonal_patterns
order by quarter, month, is_weekend
