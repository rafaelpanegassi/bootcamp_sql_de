-- 03. QUAL É O VALOR TOTAL QUE CADA CLIENTE JÁ PAGOU ATÉ AGORA?

DROP VIEW VIEW_TOTAL_REVENUES_PER_CUSTOMER;

CREATE VIEW VIEW_TOTAL_REVENUES_PER_CUSTOMER AS
SELECT CUSTOMERS.COMPANY_NAME, SUM(ORDER_DETAILS.UNIT_PRICE * ORDER_DETAILS.QUANTITY * (1.0 - ORDER_DETAILS.DISCOUNT)) AS TOTAL
FROM CUSTOMERS
INNER JOIN
ORDERS ON
CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID
INNER JOIN
ORDER_DETAILS ON
ORDER_DETAILS.ORDER_ID = ORDERS.ORDER_ID
GROUP BY
CUSTOMERS.COMPANY_NAME
ORDER BY
TOTAL DESC;

SELECT *
FROM VIEW_TOTAL_REVENUES_PER_CUSTOMER;