WITH key_risk_dates AS (
    SELECT
        day_analyzed,
        user_id,
        CASE 
            WHEN DATE_PART('day', LEAST(current_date, (LEAD(day_analyzed) OVER (PARTITION BY user_id ORDER BY day_analyzed))) - day_analyzed) > 1 THEN day_analyzed + INTERVAL '1 day' 
        END AS enter_at_risk_wau,
        CASE 
            WHEN DATE_PART('day', LEAST(current_date, (LEAD(day_analyzed) OVER (PARTITION BY user_id ORDER BY day_analyzed))) - day_analyzed) >= 7 THEN day_analyzed + INTERVAL '7 days' 
        END AS enter_at_risk_mau,
        CASE 
            WHEN DATE_PART('day', LEAST(current_date, (LEAD(day_analyzed) OVER (PARTITION BY user_id ORDER BY day_analyzed))) - day_analyzed) >= 30 THEN day_analyzed + INTERVAL '30 days' 
        END AS enter_dormant
    FROM 
        Activity
    GROUP BY 1, 2
),

current_reactivated_ressurected AS (
    SELECT
        day_analyzed AS day,
        COUNT(DISTINCT user_id) FILTER (WHERE days_between_activations > 0 AND days_between_activations <= 7) AS current_users,
        COUNT(DISTINCT user_id) FILTER (WHERE days_between_activations > 7 AND days_between_activations <= 29) AS reactivated_users,
        COUNT(DISTINCT user_id) FILTER (WHERE days_between_activations >= 30) AS ressurected_users
    FROM (
        SELECT
            day_analyzed,
            user_id,
            DATE_PART('day', day_analyzed - LAG(day_analyzed) OVER (PARTITION BY user_id ORDER BY day_analyzed)) AS days_between_activations
        FROM 
            Activity
        GROUP BY 1, 2, 3
    ) days_between_activations
    GROUP BY 1
)

SELECT
    gs.all_days AS day,
    crr.reactivated_users,
    k.enter_at_risk_mau,
    (crr.reactivated_users::FLOAT / NULLIF(k.enter_at_risk_mau, 0)) AS reactivation_rate
FROM
    generate_series('2023-01-01'::date, current_date, '1 day'::interval) AS gs(all_days)
LEFT JOIN current_reactivated_ressurected crr ON crr.day = gs.all_days
LEFT JOIN (
    SELECT
        enter_at_risk_mau AS mau_day,
        COUNT(*) AS enter_at_risk_mau
    FROM key_risk_dates
    GROUP BY 1
) k ON k.mau_day = gs.all_days - INTERVAL '1 day';