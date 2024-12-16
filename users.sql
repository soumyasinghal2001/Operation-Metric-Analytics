create database analytics;
use analytics;


create table users(
user_id int,
created_at varchar(100),
company_id int,
language varchar(50),
activated_at varchar(100),
state varchar(50));

select * from users;

show variables like 'secure_file_priv';

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv"
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

alter table users add column temp_created_at datetime;

SET SQL_SAFE_UPDATES = 0;

update users set temp_created_at = STR_TO_DATE(created_at, '%d-%m-%Y %H:%i');

SELECT * FROM users;

alter table users drop column created_at;

alter table users change column temp_created_at created_at datetime;



alter table users add column temp_activated_at datetime;

update users set temp_activated_at = STR_TO_DATE(activated_at, '%d-%m-%Y %H:%i');

alter table users drop column activated_at;

alter table users change column temp_activated_at activated_at datetime;

SELECT * FROM users;



