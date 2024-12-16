create table events(
user_id	int,
occurred_at	varchar(100),
event_type varchar(50),
event_name	varchar(50),
location varchar(50),	
device varchar(50),
user_type int
);


load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv"
into table events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;



alter table events add column temp_occurred_at datetime;

SET SQL_SAFE_UPDATES = 0;

update events set temp_occurred_at = STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i');

SELECT * FROM events;

alter table events drop column occurred_at;

alter table events change column temp_occurred_at occurred_at datetime;

