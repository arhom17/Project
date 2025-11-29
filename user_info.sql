WITH pinnacle_users AS (
    SELECT * FROM epmain.onecloud_dbo.pinnacle_users WHERE _fivetran_deleted = FALSE
),
sy_user_properties_values AS (
    SELECT * FROM epmain.onecloud_dbo.sy_user_properties_values WHERE _fivetran_deleted = FALSE
),
sy_user_properties AS (
    SELECT * FROM epmain.onecloud_dbo.sy_user_properties WHERE _fivetran_deleted = FALSE
)

SELECT pu.userid,
    upv.str_val AS job_title
FROM pinnacle_users pu
    INNER JOIN sy_user_properties_values upv
        ON upv.userid = pu.userid
    INNER JOIN sy_user_properties up
        ON up.userpropertyid = upv.userpropertyid
WHERE up.name ILIKE '%Job%'