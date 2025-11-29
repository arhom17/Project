WITH vw_contentitems AS (
    SELECT * FROM epmain.onecloud_dbo.vw_contentitems
),
pinnacle_tenants AS (
    SELECT * FROM epmain.onecloud_dbo.pinnacle_tenants WHERE _fivetran_deleted = FALSE
),
vw_product_content_usage AS (
    SELECT * FROM epmain.onecloud_dbo.vw_product_content_usage
),
content_products AS (
    SELECT * FROM epmain.onecloud_dbo.content_products WHERE _fivetran_deleted = FALSE
),
content_product_versions AS (
    SELECT * FROM epmain.onecloud_dbo.content_product_versions WHERE _fivetran_deleted = FALSE
)

SELECT ci.id AS content_id,
    CASE
        WHEN ci.itemtype = 'PS_Course' THEN 'Course'
        WHEN ci.itemtype = 'PS_VidArchive' THEN 'Video'
        WHEN ci.itemtype = 'PS_Cheat' THEN 'Document'
        WHEN ci.itemtype = 'PS_Workflow' THEN 'Workflow'
        ELSE NULL
    END AS content_type,
    cp.name AS topic,
    cpv.name AS suptopic,
    CASE
        WHEN cpv.name IS NULL THEN cp.name
        WHEN cp.name = cpv.name THEN cp.name
        ELSE CONCAT(cp.name, ' ', cpv.name) 
    END AS topic_subtopic
FROM vw_contentitems ci
    INNER JOIN pinnacle_tenants ten
        ON ten.tenantid = ci.tenantid
    LEFT JOIN vw_product_content_usage pcu
        ON pcu.contentid = ci.id
    LEFT JOIN content_products cp
        ON cp.content_productid = pcu.content_productid
    LEFT JOIN content_product_versions cpv
        ON cpv.content_verid = pcu.content_verid
WHERE (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
    AND ci.itemtype = 'PS_Course'
        OR ci.itemtype = 'PS_VidArchive'
        OR ci.itemtype = 'PS_Cheat'
        OR ci.itemtype = 'PS_Workflow'


