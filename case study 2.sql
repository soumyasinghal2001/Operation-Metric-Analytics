use analytics;

/*Case Study 2: Investigating Metric Spike
You will be working with three tables:

users: Contains one row per user, with descriptive information about that user’s account.
events: Contains one row per event, where an event is an action that a user has taken (e.g., login, messaging, search).
email_events: Contains events specific to the sending of emails.
Tasks:
users*/
SELECT * FROM users;
SELECT * FROM events;
SELECT * FROM email_events;

/*
Weekly User Engagement:
Objective: Measure the activeness of users on a weekly basis.
Your Task: Write an SQL query to calculate the weekly user engagement.

*/
SELECT
   YEARWEEK(created_at, 1) AS year_week,
   COUNT(*) AS active_users
FROM 
   users   
GROUP BY 
   YEARWEEK(created_at, 1)
ORDER BY 
   year_week;

WITH weekly_data AS (
    SELECT 
        YEARWEEK(created_at, 1) AS year_week,
        COUNT(DISTINCT user_id) AS new_users,
        COUNT(DISTINCT CASE WHEN activated_at IS NOT NULL THEN user_id END) AS activated_users
    FROM 
        users
    GROUP BY 
        YEARWEEK(created_at, 1)
)

SELECT 
    wd.year_week,
    wd.new_users,
    wd.activated_users,
    (SELECT SUM(new_users) 
     FROM weekly_data wd2 
     WHERE wd2.year_week <= wd.year_week) AS total_users
FROM 
    weekly_data wd
ORDER BY 
    wd.year_week;



/*
User Growth Analysis:
Objective: Analyze the growth of users over time for a product.
Your Task: Write an SQL query to calculate the user growth for the product.
*/
SELECT 
    YEARWEEK(created_at, 1) AS year_week,
    COUNT(user_id) AS new_users,
    SUM(COUNT(user_id)) OVER (ORDER BY YEARWEEK(created_at, 1)) AS cumulative_users
FROM 
    users
GROUP BY 
    YEARWEEK(created_at, 1)
ORDER BY 
    year_week;



/*
Weekly Retention Analysis:
Objective: Analyze the retention of users on a weekly basis after signing up for a product.
Your Task: Write an SQL query to calculate the weekly retention of users based on their sign-up cohort.
*/

SELECT * FROM events;
SELECT DISTINCT event_name       /*complete_signup*/
FROM events;

WITH user_cohorts AS (
    -- Step 1: Get the first sign-up event (earliest event) for each user
    SELECT
        user_id,
        MIN(occurred_at) AS first_signup_date
    FROM
        events
    WHERE
        event_type = 'signup_flow' -- Filter for sign-up events (if available in the data)
    GROUP BY
        user_id
),
user_activity AS (
    -- Step 2: Get the week number of the first sign-up and the week of every user activity
    SELECT
        e.user_id,
        EXTRACT(WEEK FROM e.occurred_at) AS activity_week,
        EXTRACT(YEAR FROM e.occurred_at) AS activity_year,
        uc.first_signup_date,
        EXTRACT(WEEK FROM uc.first_signup_date) AS signup_week,
        EXTRACT(YEAR FROM uc.first_signup_date) AS signup_year
    FROM
        events e
    JOIN
        user_cohorts uc
    ON e.user_id = uc.user_id
    WHERE
        e.event_type = 'engagement' -- Track user activities after sign-up (engagements)
),
weekly_retention AS (
    -- Step 3: Calculate the weekly retention
    SELECT
        ua.signup_year,
        ua.signup_week,
        ua.activity_year,
        ua.activity_week,
        COUNT(DISTINCT ua.user_id) AS retained_users
    FROM
        user_activity ua
    WHERE
        (ua.activity_year > ua.signup_year) OR
        (ua.activity_year = ua.signup_year AND ua.activity_week >= ua.signup_week) -- Ensure only activity after or within the signup week is considered
    GROUP BY
        ua.signup_year,
        ua.signup_week,
        ua.activity_year,
        ua.activity_week
)
-- Step 4: Display the retention for each cohort (week of sign-up)
SELECT
    signup_year,
    signup_week,
    activity_year,
    activity_week,
    retained_users
FROM
    weekly_retention
ORDER BY
    signup_year, signup_week, activity_year, activity_week;









/*Weekly Engagement Per Device:
Objective: Measure the activeness of users on a weekly basis per device.
Your Task: Write an SQL query to calculate the weekly engagement per device.
*/
SELECT * FROM events;

SELECT 
    EXTRACT(YEAR FROM occurred_at) AS year,
    EXTRACT(WEEK FROM occurred_at) AS week,
    device,
    COUNT(DISTINCT user_id) AS engaged_users
FROM 
    events
GROUP BY 
    year, week, device
ORDER BY 
    year, week, device;



/*Email Engagement Analysis:
Objective: Analyze how users are engaging with the email service.
Your Task: Write an SQL query to calculate the email engagement metrics.
*/

select * from email_events;

SELECT 
    user_id,
    action,
    sum(user_type) as count_engagement
FROM 
    email_events
GROUP BY 
    user_id, action;

