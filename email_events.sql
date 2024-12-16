use analytics;

create table email_events(
user_id	int,
occurred_at	varchar(100),
action varchar(50),
user_type int
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv"
into table email_events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from email_events;

alter table email_events add column temp_occurred_at datetime;

SET SQL_SAFE_UPDATES = 0;

update email_events set temp_occurred_at = STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i');

SELECT * FROM email_events;

alter table email_events drop column occurred_at;

alter table email_events change column temp_occurred_at occurred_at datetime;