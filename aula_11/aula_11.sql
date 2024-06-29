DROP TABLE IF EXISTS CARS, ENGINES;

CREATE TABLE CARS (
 MANUFACTURER VARCHAR(64), MODEL VARCHAR(64), COUNTRY VARCHAR(64), ENGINE_NAME VARCHAR(64), YEAR INT
);

CREATE TABLE ENGINES (
 NAME VARCHAR(64), HORSE_POWER INT
);

INSERT INTO CARS
VALUES 
 ('BMW', 'M4', 'GERMANY', 'S58B30T0-353', 2021),('BMW', 'M4', 'GERMANY', 'S58B30T0-375', 2021),('CHEVROLET', 'CORVETTE', 'USA', 'LT6', 2023),('CHEVROLET', 'CORVETTE', 'USA', 'LT2', 2023),('AUDI', 'R8', 'GERMANY', 'DOHC FSI V10-5.2-456', 2019),('MCLAREN', 'GT', 'UK', 'M840TE', 2019),('MERCEDES', 'AMG C 63 S E', 'GERMANY', 'M139L', 2023);

INSERT INTO ENGINES
VALUES 
 ('S58B30T0-353', 473),('S58B30T0-375', 510),('LT6', 670),('LT2', 495),('DOHC FSI V10-5.2-456', 612),('M840TE', 612),('M139L', 469);

SELECT CARS.MANUFACTURER, CARS.MODEL, CARS.COUNTRY, CARS.YEAR, MAX(ENGINES.HORSE_POWER) AS MAXIMUM_HORSE_POWER
FROM CARS
JOIN ENGINES ON
CARS.ENGINE_NAME = ENGINES.NAME
WHERE CARS.YEAR > 2015
AND CARS.COUNTRY = 'GERMANY'
GROUP BY CARS.MANUFACTURER, CARS.MODEL, CARS.COUNTRY, CARS.YEAR
HAVING MAX(ENGINES.HORSE_POWER)> 200
ORDER BY MAXIMUM_HORSE_POWER DESC
LIMIT 2

SELECT CARS.MANUFACTURER, CARS.MODEL, CARS.ENGINE_NAME, ENGINES.HORSE_POWER
FROM CARS
JOIN ENGINES ON
CARS.ENGINE_NAME = ENGINES.NAME
LIMIT 2;