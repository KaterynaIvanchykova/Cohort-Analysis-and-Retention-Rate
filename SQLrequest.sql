select *
from project.cohort_users_raw cur 
limit 10;
select *
from project.cohort_events_raw cer 
limit 10;

 with user_parsed as (
          select 
          user_id,
          signup_datetime,
          case when replace(replace(split_part(trim(signup_datetime),' ',1),'.','-'),'/','-') ~ '^[0-9]{2}-[0-9]{2}-([0-9]{2}|[0-9]{4})$'
           then to_timestamp(replace(replace(trim(signup_datetime),'.','-'),'/','-'),'DD-MM-YYYY HH24:MI')::timestamp 
           else null
           end as signup_ts,
           promo_signup_flag 
          from project.cohort_users_raw cur
          ), 
          event_parsed as (
               select 
               user_id,
               event_datetime,
               event_type,
               case when replace(replace(split_part(trim(event_datetime),' ',1),'.','-'),'/','-') ~ '^[0-9]{2}-[0-9]{2}-([0-9]{2}|[0-9]{4})$'
               then to_timestamp(replace(replace(trim(event_datetime),'.','-'),'/','-'),'DD-MM-YYYY HH24:MI')::timestamp 
               else null
               end as event_ts
               from project.cohort_events_raw cer 
          ), -- созданы CTE для того что подготовить данные для дальнейшого использования.тут выполнена работа очищение  дат к 
          --единому розделителю удоление не нужных пробелов , а также приведение к единому формату timestamp.
          user_activity as (
              select 
              up.user_id,
              date_trunc('month',up.signup_ts)::date as cohort_month,
              promo_signup_flag,
              date_trunc('month',ep.event_ts):: date as activity_month,
              cast((date_part('year', ep.event_ts)*12 + date_part('month', ep.event_ts))-(date_part('year',up.signup_ts)*12 + date_part('month',up.signup_ts))as int4) as month_offset
              from user_parsed as up 
              join event_parsed as ep 
              on ep.user_id = up.user_id 
              where up.signup_ts is not null
              and ep.event_ts is not null 
              and ep.event_type is not null 
              and ep.event_type <> 'test_event'
        ) -- в этом CTE было найдено cohort_month(месяц когда пользователь зарегистрировался) ,activity_month с помощью вытягивания только года и месяца.
          -- было посчитано month_offset (стаж пользователя,то есть количество месяцев, сколько прошло с момента регистрации пользователя до события этого пользователя )
           --- было сделано фильтрация чтобы убрать (пользователей без даты регистрации,события без дат,события с неопределеным типом события,так же было убрано тестовые события)
           select 
           promo_signup_flag,
           cohort_month,
           month_offset,
           count(distinct user_id) as user_total
           from user_activity as ua
          where ua.activity_month between date '2025-01-01' and date '2025-06-01'
          group by promo_signup_flag, cohort_month,month_offset 
          order by promo_signup_flag, cohort_month,month_offset;
 
     --в финале мы получаем таблицу в которой видем вовлечом ли пользователь с промо или органически(promo_signup_flag)
     -- месяц в котором зарегистрировался пользователь(cohort_month)
     -- стаж пользователя(month_offset)
     --количество уникальных пользователей для этой группы (user_total)
     -- отфильтровали по месяцам активности было взято 6 месяцев(с янворя по июнь) 2025 года
     
