WITH daily_activity AS (

SELECT 

user_id,
DATE_TRUNC('day', Day_analyzed) AS day

FROM Activity

GROUP BY 1, 2
)

SELECT 

gs.all_days AS day,
COUNT(DISTINCT last_week_activity.user_id) AS current_users

FROM 
generate_series(
    '2024-01-01'::date,
    '2024-02-19'::date,
    '1 day'::interval
) AS gs(all_days)

LEFT JOIN daily_activity ad ON gs.all_days = ad.day

LEFT JOIN daily_activity last_week_activity 
    ON ad.user_id = last_week_activity.user_id
    AND last_week_activity.day >= gs.all_days - INTERVAL '7 days'
    AND last_week_activity.day < gs.all_days

GROUP BY 1