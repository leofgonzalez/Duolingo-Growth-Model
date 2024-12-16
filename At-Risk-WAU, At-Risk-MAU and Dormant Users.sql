with key_risk_dates as (

select

day_analyzed,
user_id,

CASE WHEN DATE_PART('day', LEAST(current_date,(LEAD(day_analyzed) 
OVER (PARTITION BY user_id ORDER BY day_analyzed))) - day_analyzed) > 1 
THEN day_analyzed + INTERVAL '1 day' END 
as enter_at_risk_wau,

CASE WHEN DATE_PART('day', LEAST(current_date,(LEAD(day_analyzed)
OVER (PARTITION BY user_id ORDER BY day_analyzed))) - day_analyzed) >= 7 
THEN day_analyzed + INTERVAL '7 days' END 
as enter_at_risk_mau,

CASE WHEN DATE_PART('day', LEAST(current_date,(LEAD(day_analyzed)
OVER (PARTITION BY user_id ORDER BY day_analyzed))) - day_analyzed) >= 30 
THEN day_analyzed + INTERVAL '30 days' END 
as enter_dormant

from Activity

group by 1,2
)

select

gs.all_days as day,
enter_wau.qt as enter_at_risk_wau,
enter_mau.qt as enter_at_risk_mau,
enter_dormant.qt as enter_dormant

from generate_series
('2020-01-01'::date,
current_date,
'1 day'::interval) as gs(all_days)

left join (SELECT enter_at_risk_wau, COUNT(*) as qt 
FROM key_risk_dates group by 1) enter_wau
ON enter_wau.enter_at_risk_wau = gs.all_days

left join (SELECT enter_at_risk_mau, COUNT(*) as qt
FROM key_risk_dates group by 1) enter_mau 
ON enter_mau.enter_at_risk_mau = gs.all_days

left join (SELECT enter_dormant, COUNT(*) as qt
FROM key_risk_dates group by 1) enter_dormant 
ON enter_dormant.enter_dormant = gs.all_days