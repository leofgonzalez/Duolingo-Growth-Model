with current_reactivated_ressurected as(

select

day_analyzed as day,

count(distinct user_id) filter 
(where days_between_activations > 0 and days_between_activations <= 7) 
as current_users,

count(distinct user_id) filter 
(where days_between_activations > 7 and days_between_activations <= 29) 
as reactivated_users,

count(distinct user_id) filter 
(where days_between_activations >= 30) 
as ressurected_users

FROM (

select

day_analyzed,
user_id,

DATE_PART('day', day_analyzed - LAG(day_analyzed) 
OVER (partition by user_id order by day_analyzed)) 
as days_between_activations

from Activity

group by 1,2,3
) days_between_activations

group by 1
)

SELECT

gs.all_days as day,
current_users,
reactivated_users,
ressurected_users

FROM
generate_series
('2023-01-01'::date,
current_date,
'1 day'::interval) as gs(all_days)

LEFT JOIN current_reactivated_ressurected crr on
crr.day = gs.all_days