SELECT PRODUCT_ID, SUM((((QUANTITY)::DOUBLE PRECISION * UNIT_PRICE) * ((1)::DOUBLE PRECISION - DISCOUNT))) AS SOLD_VALUE, RANK() OVER (
ORDER BY (SUM((((QUANTITY)::DOUBLE PRECISION * UNIT_PRICE) * ((1)::DOUBLE PRECISION - DISCOUNT)))) DESC) AS RANK
FROM ORDER_DETAILS DET
GROUP BY PRODUCT_ID