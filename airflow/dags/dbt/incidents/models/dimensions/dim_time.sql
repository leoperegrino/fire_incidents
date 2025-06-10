{{ config(materialized='table') }}

with date_spine as (
  {{ dbt_utils.date_spine(
      datepart="day",
      start_date="'2010-01-01'::date",
      end_date="'2015-12-31'::date"
  ) }}
),

time_dimension as (
  select
    date_day::date,
    extract(year from date_day) as year,
    extract(quarter from date_day) as quarter,
    extract(month from date_day) as month,
    extract(day from date_day) as day,
    extract(dow from date_day) as day_of_week,
    extract(doy from date_day) as day_of_year,
    extract(week from date_day) as week_of_year,

    to_char(date_day, 'Month') as month_name,
    to_char(date_day, 'Day') as day_name,

	extract(dow from date_day) in (0, 6) as is_weekend,
	extract(dow from date_day) not in (0, 6) as is_weekday

  from date_spine
)

select *
from time_dimension
