set search_path to gaps_islands;

alter table logs_data 
rename column "Login date" to login_date;

update logs_data ld 
set login_date =
case
	when login_date ~ '^(0[1-9]|1[0-9]|2[0-9]|3[0-1])/(0[1-9]|1[0-2]|[0-9])/[0-9]{4}$'then to_date(login_date, 'DD/MM/YYYY')--DD/MM/YYYY
	when login_date ~ '^(0[1-9]|1[0-2]|[0-9])/(0[1-9]|1[0-9]|2[0-9]|3[0-1])/[0-9]{4}$'then to_date(login_date, 'MM/DD/YYYY')--MM/DD/YY
	when login_date ~ '^[0-9]{4}/(0[1-9]|1[0-2]|[0-9])/(0[1-9]|1[0-9]|2[0-9]|3[0-1])$'then to_date(login_date, 'YYYY/MM/DD')--YYYY/MM/DD
	when login_date ~ '^[0-9]{4}/(0[1-9]|1[0-9]|2[0-9]|3[0-1])/(0[1-9]|1[0-2]|[0-9])$'then to_date(login_date, 'YYYY/DD/MM')--YYYY/DD/MM
	else null
end;

select * from logs_data ld where new_login_date is null;
--We have confirmed the integrity of the dates


--delete from logs_data where new_login_date is null;

--delete the makeshift column
alter table logs_data 
drop column if exists new_login_date;


/*
 * ****** Phase Two****
 * ***Gaps and Islands Phase***
 * 
 * Find the longest consecutive daily streak for each user
 * 
 * */

alter table logs_data  
rename column "Client _ID" to client_id;

--This standard helps accept other designs of data eg'YYYY,DD,MM'
SET datestyle = 'ISO, MDY';

alter table logs_data 
alter column login_date type date
using login_date::date;

with grouped_logs as (
select 
	client_id, 
	login_date, 
	lag(login_date)over(partition by client_id order by login_date) prev_login_date,
	row_number()over(partition by client_id)row_num
from logs_data
),
anchored as (
select 
	client_id, 
	login_date, 
	prev_login_date,
	(login_date - interval '1 day'*row_num) as anchor
from grouped_logs
)--in the next querry you will be counting the anchor
select
	client_id,
	count(*) as Streak_of_days
from anchored
group by client_id, anchor 
order by client_id ;

/*
 * To explain logically, we count the anchors because,
 * if the dates add by one meanig a consecutive day login,
 * the anchor remains the same, so if we count the anchors, it counts tha entry as two
 * hence the streak
 * */




select * from logs_data ld ;

