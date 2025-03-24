WITH user_state_transitions AS (

SELECT
    
user_id,
day_analyzed AS current_activity_day,
LAG(day_analyzed) OVER (PARTITION BY user_id ORDER BY day_analyzed) AS previous_activity_day,
LEAD(day_analyzed) OVER (PARTITION BY user_id ORDER BY day_analyzed) AS next_activity_day,
DATE_PART('day', day_analyzed - LAG(day_analyzed) OVER (PARTITION BY user_id ORDER BY day_analyzed)) AS days_since_last_activity
    
FROM Activity
),

daily_metrics AS (

SELECT

day_analyzed,
    
COUNT(DISTINCT CASE WHEN days_since_last_activity BETWEEN 8 AND 29 
THEN user_id
END) AS reactivated_users,

COUNT(DISTINCT 
CASE WHEN DATE_PART('day', day_analyzed - previous_activity_day) BETWEEN 7 AND 29
AND previous_activity_day = day_analyzed - INTERVAL '1 day'
THEN user_id 
END) AS at_risk_mau_previous_day

FROM user_state_transitions
GROUP BY 1
)

SELECT

dm.day_analyzed AS day,
dm.reactivated_users,
dm.at_risk_mau_previous_day,

CASE WHEN dm.at_risk_mau_previous_day > 0 
THEN (dm.reactivated_users::FLOAT / dm.at_risk_mau_previous_day) ELSE NULL
END AS reactivation_rate

FROM daily_metrics dm
WHERE dm.day_analyzed BETWEEN '2023-03-01' AND '2023-07-31'
ORDER BY 1
