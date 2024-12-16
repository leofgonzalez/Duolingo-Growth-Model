with first_activation as (
SELECT

User_ID,
MIN(date_trunc('day',Day_analyzed)) as first_activation

FROM Activity

group by 1

)

SELECT 

gs.all_days as day,
count(distinct user_id) as new_users

FROM

generate_series
('2023-01-01'::date,
current_date,
'1 day'::interval) as gs(all_days)

LEFT JOIN first_activation ON gs.all_days = first_activation.first_activation

group by 1