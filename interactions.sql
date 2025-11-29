WITH lp_course_enrollment AS (
    SELECT * FROM epmain.onecloud_dbo.lp_course_enrollment WHERE _fivetran_deleted = FALSE
),
lp_courses AS (
    SELECT * FROM epmain.onecloud_dbo.lp_courses WHERE _fivetran_deleted = FALSE
),
pinnacle_tenants AS (
    SELECT * FROM epmain.onecloud_dbo.pinnacle_tenants WHERE _fivetran_deleted = FALSE
),
sy_histories AS (
    SELECT * FROM epmain.onecloud_dbo.sy_histories WHERE _fivetran_deleted = FALSE
),
vw_contentitems AS (
    SELECT * FROM epmain.onecloud_dbo.vw_contentitems
),
combined_interactions AS (
    SELECT enr.enrollid AS interaction_id,
        CASE
            WHEN enr.completed_date IS NULL THEN CAST(enr.assigned_date AS DATE)
            ELSE CAST(enr.completed_date AS DATE)
        END AS interaction_date,
        CASE
            WHEN enr.completed_date IS NULL THEN 'Course Enrollment'
            ELSE 'Course Completion'
        END AS interaction_type,
        enr.tenantid AS tenant_id,
        enr.assigned_to_userid AS user_id,
        enr.courseid AS content_id
    FROM lp_course_enrollment enr
        INNER JOIN lp_courses cor
            ON cor.courseid = enr.courseid
        INNER JOIN pinnacle_tenants ten
            ON ten.tenantid = cor.tenantid
    WHERE enr.is_dropped = FALSE
        AND (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
        AND enr.assigned_date >= CAST('2021-01-01' AS DATE)
    
        UNION ALL
    
    SELECT sh.histid AS interaction_id,
        CAST(sh.hist_date AS DATE) AS interaction_date,
        CASE
            WHEN sh.hist_type = 'PS_Cheat' THEN 'Document Opened'
            WHEN sh.hist_type = 'PS_VidArchive' THEN 'Video Watched'
            WHEN sh.hist_type = 'PS_Workflow' THEN 'Workflow Opened'
            ELSE NULL
        END AS interaction_type,
        sh.tenantid AS tenant_id,
        sh.userid AS user_id,
        sh.linkid AS content_id
    FROM sy_histories sh
        INNER JOIN vw_contentitems ci
            ON ci.id = sh.linkid
        INNER JOIN pinnacle_tenants ten
            ON ten.tenantid = ci.tenantid
    WHERE (sh.hist_type = 'PS_Cheat'
            OR sh.hist_type = 'PS_VidArchive'
            OR sh.hist_type = 'PS_Workflow')
        AND (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
        AND sh.hist_date >= CAST('2021-01-01' AS DATE)
)

SELECT *
FROM combined_interactions ci
ORDER BY ci.interaction_date DESC