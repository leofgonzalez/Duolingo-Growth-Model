WITH daily_activity AS (
    SELECT 
        user_id,
        DATE_TRUNC('day', created_at) AS day
    FROM donations
    GROUP BY 1, 2
)

SELECT 
    gs.all_days AS day,
    COUNT(DISTINCT ad.user_id) AS number_of_reactivated_users
FROM 
    generate_series(
        '2023-01-01'::date,
        '2023-12-31'::date,
        '1 day'::interval
    ) AS gs(all_days)

LEFT JOIN daily_activity ad ON gs.all_days = ad.day

LEFT JOIN daily_activity last_week_activity 
    ON ad.user_id = last_week_activity.user_id
    AND last_week_activity.day >= gs.all_days - INTERVAL '7 days'
    AND last_week_activity.day < gs.all_days

LEFT JOIN daily_activity last_month_activity 
    ON ad.user_id = last_month_activity.user_id
    AND last_month_activity.day >= gs.all_days - INTERVAL '29 days'
    AND last_month_activity.day < gs.all_days
    AND last_month_activity.day NOT BETWEEN gs.all_days - INTERVAL '7 days' AND gs.all_days

WHERE last_week_activity.user_id IS NULL -- Guarantee the user has not been active in the last week.
GROUP BY 1;
