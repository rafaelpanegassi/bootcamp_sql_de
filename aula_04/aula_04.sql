/*FAÇA A CLASSIFICAÇÃO DOS PRODUTOS MAIS VENVIDOS USANDO USANDO RANK(), DENSE_RANK() E ROW_NUMBER()
ESSA QUESTÃO TEM 2 IMPLEMENTAÇÕES, VEJA UMA QUE UTILIZA SUBQUERY E UMA QUE NÃO UTILIZA
TABELAS UTILIZADASFROM ORDER_DETAILS O JOIN PRODUCTS P ON P.PRODUCT_ID = O.PRODUCT_ID*/

-- CONSULTANDO AS INFORMAÇÕES:

SELECT *
FROM ORDER_DETAILS A
JOIN PRODUCTS B ON
A.PRODUCT_ID = B.PRODUCT_ID;

-- CONSTRUINDO A PRIMEIRA VISÃO COM SUBQUERY:

SELECT PRODUCT_ID,QTD,ROW_NUMBER () OVER( ORDER BY QTD DESC) ROWN,
RANK () OVER( ORDER BY QTD DESC) RNK,
DENSE_RANK () OVER( ORDER BY QTD DESC) DRNK FROM (
SELECT A.PRODUCT_ID, SUM(QUANTITY) QTD
FROM ORDER_DETAILS A
JOIN PRODUCTS B ON
A.PRODUCT_ID = B.PRODUCT_ID
GROUP BY A.PRODUCT_ID);


SELECT B.PRODUCT_ID, (QUANTITY) QTD, 
ROW_NUMBER() OVER (ORDER BY (QUANTITY) DESC) AS ROWN, 
RANK() OVER (ORDER BY (QUANTITY) DESC) AS RNK, 
DENSE_RANK() OVER (ORDER BY (QUANTITY) DESC) AS DRNK
FROM ORDER_DETAILS A
JOIN 
  PRODUCTS B ON
A.PRODUCT_ID = B.PRODUCT_ID;

/*LISTAR FUNCIONÁRIOS DIVIDINDO-OS EM 3 GRUPOS USANDO NTILE FROM EMPLOYEES*/

SELECT FIRST_NAME, LAST_NAME, TITLE, NTILE(3) OVER (
ORDER BY FIRST_NAME) AS GROUP_NUMBER
FROM EMPLOYEES;


/*ORDENANDO OS CUSTOS DE ENVIO PAGOS PELOS CLIENTES DE ACORDO 
COM SUAS DATAS DE PEDIDO, MOSTRANDO O CUSTO ANTERIOR E O CUSTO POSTERIOR USANDO LAG E LEAD
FROM ORDERS JOIN SHIPPERS ON SHIPPERS.SHIPPER_ID = ORDERS.SHIP_VIA*/

SELECT CUSTOMER_ID,ORDER_DATE, B.COMPANY_NAME AS SHIPPER_NAME, 
LAG(FREIGHT) OVER (PARTITION BY CUSTOMER_IDORDER BY ORDER_DATE DESC) AS PREVIOUS_ORDER_FREIGHT, 
FREIGHT AS ORDER_FREIGHT, 
LEAD(FREIGHT) OVER (PARTITION BY CUSTOMER_IDORDER BY ORDER_DATE DESC) AS NEXT_ORDER_FREIGHT
FROM ORDERS A
JOIN SHIPPERS B ON
A.SHIP_VIA = B.SHIPPER_ID;



-- DESAFIO EXTRA: QUESTÃO INTREVISTA GOOGLE
-- HTTPS://MEDIUM.COM/@AGGARWALAKSHIMA/INTERVIEW-QUESTION-ASKED-BY-GOOGLE-AND-DIFFERENCE-AMONG-ROW-NUMBER-RANK-AND-DENSE-RANK-4CA08F888486#:~:TEXT=ROW_NUMBER()%20ALWAYS%20PROVIDES%20UNIQUE,A%20CONTINUOUS%20SEQUENCE%20OF%20RANKS.
-- HTTPS://PLATFORM.STRATASCRATCH.COM/CODING/10351-ACTIVITY-RANK?CODE_TYPE=3
-- HTTPS://WWW.YOUTUBE.COM/WATCH?V=DB-QDLP8U3O

SELECT FROM_USER, COUNT(FROM_USER) AS TOTAL_EMAILS, ROW_NUMBER()
OVER (
ORDER BY COUNT(FROM_USER) DESC, FROM_USER) ACTIVITY_RANK
FROM GOOGLE_GMAIL_EMAILS
GROUP BY FROM_USER;