WITH vw_contentitems AS (
    SELECT * FROM epmain.onecloud_dbo.vw_contentitems
),
pinnacle_tenants AS (
    SELECT * FROM epmain.onecloud_dbo.pinnacle_tenants WHERE _fivetran_deleted = FALSE
),
content_keywords AS (
    SELECT ky.contentid AS content_id,
        ky.keyword
    FROM epmain.onecloud_dbo.content_keywords ky
        INNER JOIN pinnacle_tenants ten
            ON ten.tenantid = ky.tenantid
    WHERE ky._fivetran_deleted = FALSE
        AND (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
)


SELECT ci.id AS content_id,
    CASE
        WHEN ci.itemtype = 'PS_Course' THEN 'Course'
        WHEN ci.itemtype = 'PS_VidArchive' THEN 'Video'
        WHEN ci.itemtype = 'PS_Cheat' THEN 'Document'
        WHEN ci.itemtype = 'PS_Workflow' THEN 'Workflow'
        ELSE NULL
    END AS content_type,
    kw.keyword
FROM vw_contentitems ci
    INNER JOIN pinnacle_tenants ten
        ON ten.tenantid = ci.tenantid
    LEFT JOIN content_keywords kw
        ON kw.content_id = ci.id
WHERE (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
    AND ci.itemtype = 'PS_Course'
        OR ci.itemtype = 'PS_VidArchive'
        OR ci.itemtype = 'PS_Cheat'
        OR ci.itemtype = 'PS_Workflow'



