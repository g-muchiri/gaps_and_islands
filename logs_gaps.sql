set search_path to gaps_islands;

alter table logs_data 
rename column "Login date" to login_date;

update logs_data ld 
set new_login_date =
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

select * from logs_data ld ;
