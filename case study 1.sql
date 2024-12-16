use analytics;

select * from job_data;

SET SQL_SAFE_UPDATES = 0;


alter table job_data add column ds_date DATE;

UPDATE job_data SET ds_date = STR_TO_DATE(ds, '%m/%d/%Y');

ALTER TABLE job_data 
DROP COLUMN ds;

ALTER TABLE job_data 
RENAME COLUMN ds_date ds;

/*
Jobs Reviewed Over Time:
Objective: Calculate the number of jobs reviewed per hour for each day in November 2020.
Your Task: Write an SQL query to calculate the number of jobs reviewed per hour for each day in November 2020.
*/

select * from job_data;

SELECT 
    ds AS review_day,
    COUNT(job_id) AS jobs_reviewed,
    (SUM(time_spent) / 3600) AS time_spent_in_hours,
    COUNT(job_id) / (SUM(time_spent) / 3600) AS jobs_reviewed_per_hour
FROM 
    job_data
WHERE 
    ds BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY 
    ds
ORDER BY 
    review_day;





/*
Throughput Analysis:
Objective: Calculate the 7-day rolling average of throughput (number of events per second).
Your Task: Write an SQL query to calculate the 7-day rolling average of throughput. 
Additionally, explain whether you prefer using the daily metric or the 7-day rolling average for throughput, and why.
*/

select * from job_data;

WITH daily_throughput AS (
    SELECT 
        ds AS review_day,
        COUNT(event) AS total_events,
        SUM(time_spent) AS total_time_spent_sec,
        (COUNT(event) / NULLIF(SUM(time_spent), 0)) AS daily_throughput
    FROM 
        job_data
    WHERE 
        ds BETWEEN '2020-11-01' AND '2020-11-30'
    GROUP BY 
        ds
),
rolling_avg_throughput AS (
    SELECT 
        review_day,
        daily_throughput,
        AVG(daily_throughput) OVER (
            ORDER BY review_day 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_throughput_7d
    FROM 
        daily_throughput
)
SELECT 
    review_day,
    daily_throughput,
    rolling_avg_throughput_7d
FROM 
    rolling_avg_throughput
ORDER BY 
    review_day;


/*
Interpretation:
Daily vs. Rolling Average:

The daily throughput varies significantly, as seen with a low of 0.0096 on 2020-11-27 and a peak of 0.0606 on 2020-11-28.
The 7-day rolling average smooths these fluctuations, providing a more stable trend. It starts low at 0.0222 and gradually increases, ending at 0.03505 on 2020-11-30.
Trend Insight:

The rolling average indicates an increasing trend in throughput towards the end of the month, suggesting improved event processing efficiency over time.
Conclusion:
Using a 7-day rolling average is beneficial because it smooths out daily fluctuations and provides a clearer view of throughput trends, helping to identify whether the system is consistently improving or facing bottlenecks.
*/


/*
Language Share Analysis:
Objective: Calculate the percentage share of each language in the last 30 days.
Your Task: Write an SQL query to calculate the percentage share of each language over the last 30 days.

*/

select * from job_data;


SELECT 
    language,
    SUM(time_spent) AS total_time_spent,
    ROUND(
        (SUM(time_spent) / 
        (SELECT SUM(time_spent) 
         FROM job_data 
         WHERE STR_TO_DATE(ds, '%Y-%m-%d') >= '2020-11-01' AND STR_TO_DATE(ds, '%Y-%m-%d') <= '2020-11-30'
        )) * 100, 2
    ) AS language_share_percentage
FROM 
    job_data
WHERE 
    STR_TO_DATE(ds, '%Y-%m-%d') BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY 
    language
ORDER BY 
    language_share_percentage DESC;





    
      

/*
Duplicate Rows Detection:
Objective: Identify duplicate rows in the data.
Your Task: Write an SQL query to display duplicate rows from the job_data table.
*/
select * from job_data;

SELECT 
    actor_id, 
    COUNT(*) AS duplicate_count
FROM 
    job_data
GROUP BY 
    job_id, 
    actor_id, 
    event, 
    language, 
    time_spent, 
    org, 
    ds
HAVING 
    COUNT(*) > 1;
