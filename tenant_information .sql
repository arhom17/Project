SELECT ten.tenant_id, cust.industry, cust.segment
FROM internal_reporting.core.customers cust
    INNER JOIN internal_reporting.core.tenants ten
        ON ten.pinnacle_id = cust.pinnacle_id