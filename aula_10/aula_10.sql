-- CRIAR TABELA
CREATE TABLE EXEMPLO (
ID SERIAL PRIMARY KEY, NOME VARCHAR(50)
);
-- INSERIR DADOS
INSERT INTO EXEMPLO (NOME)
VALUES ('A'),('B'),('C');

SELECT *
FROM EXEMPLO

SET
TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN;

SELECT NOME, COUNT(NOME)
FROM EXEMPLO
GROUP BY NOME;

SELECT *
FROM EXEMPLO;

COMMIT;

BEGIN;

INSERT INTO EXEMPLO (NOME)
VALUES ('A');

COMMIT;

SET
TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN;

SELECT *
FROM EXEMPLO;
-- CONFIGURAÇÃO PARA SERIALIZABLE
SET
TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN;

SELECT *
FROM EXEMPLO;
-- VOLTAR PRO T1
INSERT INTO EXEMPLO (NOME)
VALUES ('A');

COMMIT;
-- VOLTAR PRO T2
INSERT INTO EXEMPLO (NOME)
VALUES ('A');

COMMIT;