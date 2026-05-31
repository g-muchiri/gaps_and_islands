create schema if not exists gaps_islands;

set search_path to gaps_islands;

--alter table gaps_and_islands_data  rename to  gaps_and_islands;

select * from gaps_and_islands;

alter table gaps_and_islands 
add constraint primarizing primary key (employee_id);

alter table gaps_and_islands 
add column new_date varchar(100);

/*
 * cleaning the date is not a one size fits all type of math
 * Loong below, one has to understand the formats in which the date sit
 * so as to know how to clean them
 * */

update gaps_and_islands
set new_date =
case
	--when start_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then to_date(start_date, 'YYYY-MM-DD')
	--when start_date ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' then to_date(start_date, 'YYYY/MM/DD')
	when start_date ~ '^[0-9]{1}/(1[3-9]|[2][0-9]|[3][0-1])/[0-9]{4}$' then to_date(start_date, 'MM-DD-YYYY')
	when start_date ~ '^[0-9]{2}/(1[3-9]|[2][0-9]|[3][0-1])/[0-9]{4}$' then to_date(start_date, 'MM/DD/YYYY')
	when start_date ~ '^[0-9]{1}/[0-9]{1}/[0-9]{4}$' then to_date(start_date, 'MM/DD/YYYY')
	when start_date ~ '^[0-9]{1}/[0-9]{2}/[0-9]{4}$' then to_date(start_date, 'MM/DD/YYYY')
	when start_date ~ '^[0-9]{2}/[0-9]{1}/[0-9]{4}$' then to_date(start_date, 'MM/DD/YYYY')
	when start_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' then to_date(start_date, 'MM/DD/YYYY')
	--when start_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' then to_date(start_date, 'DD-MM-YYYY')
	--when start_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{2}$' then to_date(start_date, 'DD-MM-YY')
	else null
end;

update gaps_and_islands 
set start_date = new_date;

alter table gaps_and_islands 
alter column start_date type date
using start_date::date;

update gaps_and_islands
set new_date =
case
	--when start_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then to_date(start_date, 'YYYY-MM-DD')
	--when start_date ~ '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' then to_date(start_date, 'YYYY/MM/DD')
	when end_date ~ '^[0-9]{1}/(1[3-9]|[2][0-9]|[3][0-1])/[0-9]{4}$' then to_date(end_date, 'MM-DD-YYYY')
	when end_date ~ '^[0-9]{2}/(1[3-9]|[2][0-9]|[3][0-1])/[0-9]{4}$' then to_date(end_date, 'MM/DD/YYYY')
	when end_date ~ '^[0-9]{1}/[0-9]{1}/[0-9]{4}$' then to_date(end_date, 'MM/DD/YYYY')
	when end_date ~ '^[0-9]{1}/[0-9]{2}/[0-9]{4}$' then to_date(end_date, 'MM/DD/YYYY')
	when end_date ~ '^[0-9]{2}/[0-9]{1}/[0-9]{4}$' then to_date(end_date, 'MM/DD/YYYY')
	when end_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' then to_date(end_date, 'MM/DD/YYYY')
	--when start_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' then to_date(start_date, 'DD-MM-YYYY')
	--when start_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{2}$' then to_date(start_date, 'DD-MM-YY')
	else null
end;

update gaps_and_islands
set end_date = new_date;

alter table gaps_and_islands 
drop column new_date;

alter table gaps_and_islands 
alter column end_date type date
using end_date:: date;

--Check department data
select distinct department from gaps_and_islands;
--Confirmed, the data is clean

--Check employee_status
select distinct employee_status from gaps_and_islands;
-- confirmed the employee status is okey

/* After data cleaning, we proceed to chec for integrity issues
 * 
 * 1. Do we have an employee who is working in two places concurrently?
 * 2. Do we have end dates older than starting dates?
 * 
 */

--Do we have an employee workingin 2 places concurrenly,
--This was ruled out by primary key since there are no duplicates in employee_id

--lets see if there are starting dates older than end dates

select * from gaps_and_islands where end_date >start_date;

-- delete those rows
delete from gaps_and_islands 
where end_date < start_date;

--If our data had a sense of mutiple employees switching departments over the years
--how we'd have captured s this was

select 
employee_id, 
start_date, 
lag(start_date)over(partition by employee_id  order by start_date) as next_role_start_date
from gaps_and_islands;

/*The Querry above just proved further that if we have a question of continuity, 
 * it will shift from continous state of employee status to operations continuity
 * 
 * The Operations department wants to audit its historical staffing footprint. 
 * They want to know the continuous "islands" of time where the department had 
 * active data entries, and where the "gaps" are 
 * (periods of time where no operations records started or existed)
 * 
 * */

--Looking at the data we have made a conclusion that there was no single streak
--lets try to prove it
with ranked_hires as(
	select 
		employee_id, 
		start_date, 
		row_number()over(order by start_date desc) as ranker
	from gaps_and_islands
),
anchored as (
	select 
		employee_id, 
		start_date, 
		(start_date - interval '1 day'*ranker) as streak
	from ranked_hires 
)
select * from anchored where streak >1;

with ranked_hires as(
	select 
		employee_id, 
		start_date, 
		row_number()over(order by start_date desc) as ranker
	from gaps_and_islands
)
select employee_id, start_date, (start_date - interval '1 day'*ranker) as streak
	from ranked_hires;

select * from gaps_and_islands order by end_date desc;
