## Aula 09 - Triggers (Gatilhos) e Projeto Prático II

Papars recomendados https://github.com/rxin/db-readings?tab=readme-ov-file

## O que sâo Triggers?

#### 1. O que são Triggers

* **Definição**: Triggers são procedimentos armazenados, que são automaticamente executados ou disparados quando eventos específicos ocorrem em uma tabela ou visão.
* **Funcionamento**: Eles são executados em resposta a eventos como INSERT, UPDATE ou DELETE.

#### 2. Por que usamos Triggers em projetos

* **Automatização de tarefas**: Para realizar ações automáticas que são necessárias após modificações na base de dados, como manutenção de logs ou atualização de tabelas relacionadas.
* **Integridade de dados**: Garantir a consistência e a validação de dados ao aplicar regras de negócio diretamente no banco de dados.

#### 3. Origem e finalidade da criação dos Triggers

* **História**: Os triggers foram criados para oferecer uma maneira de responder automaticamente a eventos de modificação em bancos de dados, permitindo a execução de procedimentos de forma automática e transparente.
* **Problemas resolvidos**: Antes dos triggers, muitas dessas tarefas precisavam ser controladas manualmente no código da aplicação, o que poderia levar a erros e inconsistências.

1. **Tabela Funcionario**:
    
    * Armazena os dados dos funcionários, incluindo ID, nome, salário e data de contratação.
2. **Tabela Funcionario_Auditoria**:
    
    * Armazena o histórico de alterações dos salários dos funcionários, incluindo o salário antigo, o novo salário e a data da modificação.

```sql
-- Criação da tabela Funcionario
CREATE TABLE Funcionario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    salario DECIMAL(10, 2),
    dtcontratacao DATE
);

-- Criação da tabela Funcionario_Auditoria
CREATE TABLE Funcionario_Auditoria (
    id INT,
    salario_antigo DECIMAL(10, 2),
    novo_salario DECIMAL(10, 2),
    data_de_modificacao_do_salario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id) REFERENCES Funcionario(id)
);

-- Inserção de dados na tabela Funcionario
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Maria', 5000.00, '2021-06-01');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('João', 4500.00, '2021-07-15');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Ana', 4000.00, '2022-01-10');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Pedro', 5500.00, '2022-03-20');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Lucas', 4700.00, '2022-05-25');
```

### Criação do Trigger

O trigger `trg_salario_modificado` será disparado após uma atualização no salário na tabela `Funcionario`. Ele registrará os detalhes da modificação na tabela `Funcionario_Auditoria`.

```sql
-- Criação do Trigger para auditoria de alterações de salário
CREATE OR REPLACE FUNCTION registrar_auditoria_salario() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Funcionario_Auditoria (id, salario_antigo, novo_salario)
    VALUES (OLD.id, OLD.salario, NEW.salario);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_salario_modificado
AFTER UPDATE OF salario ON Funcionario
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_salario();
```

Esse exemplo cria uma infraestrutura completa para monitorar as alterações de salário, garantindo que qualquer ajuste seja devidamente registrado, oferecendo uma trilha de auditoria clara e útil para análises futuras.

Para verificar se o trigger está funcionando corretamente, podemos realizar um comando `UPDATE` no salário de um dos funcionários e, em seguida, consultar a tabela `Funcionario_Auditoria` para ver se a alteração foi registrada conforme esperado. Vamos fazer isso com o funcionário cujo nome é "Ana".

### Comando de Atualização do Salário

```sql
-- Atualiza o salário da Ana
UPDATE Funcionario SET salario = 4300.00 WHERE nome = 'Ana';
```

### Consulta à Tabela de Auditoria

Após realizar a atualização, podemos verificar a tabela `Funcionario_Auditoria` para garantir que o registro da mudança de salário foi feito.

```sql
-- Consulta à tabela Funcionario_Auditoria para verificar as mudanças
SELECT * FROM Funcionario_Auditoria WHERE id = (SELECT id FROM Funcionario WHERE nome = 'Ana');
```

Este comando SQL irá retornar os registros da tabela de auditoria que correspondem ao funcionário "Ana". Você deve ver uma linha com o salário antigo (4000.00), o novo salário (4300.00) e a data/hora da modificação, indicando que o trigger operou conforme o esperado.

## Exemplo com desafio de Estoque

Neste exercício, você irá implementar um sistema simples de gestão de estoque para uma loja que vende camisetas como Basica, Dados e Verao. A loja precisa garantir que as vendas sejam registradas apenas se houver estoque suficiente para atender os pedidos. Você será responsável por criar um trigger no banco de dados que previna a inserção de vendas que excedam a quantidade disponível dos produtos.

```sql
-- Criação da tabela Produto
CREATE TABLE Produto (
    cod_prod INT PRIMARY KEY,
    descricao VARCHAR(50) UNIQUE,
    qtde_disponivel INT NOT NULL DEFAULT 0
);

-- Inserção de produtos
INSERT INTO Produto VALUES (1, 'Basica', 10);
INSERT INTO Produto VALUES (2, 'Dados', 5);
INSERT INTO Produto VALUES (3, 'Verao', 15);

-- Criação da tabela RegistroVendas
CREATE TABLE RegistroVendas (
    cod_venda SERIAL PRIMARY KEY,
    cod_prod INT,
    qtde_vendida INT,
    FOREIGN KEY (cod_prod) REFERENCES Produto(cod_prod) ON DELETE CASCADE
);
```

```sql
-- Criação de um TRIGGER
CREATE OR REPLACE FUNCTION verifica_estoque() RETURNS TRIGGER AS $$
DECLARE
    qted_atual INTEGER;
BEGIN
    SELECT qtde_disponivel INTO qted_atual
    FROM Produto WHERE cod_prod = NEW.cod_prod;
    IF qted_atual < NEW.qtde_vendida THEN
        RAISE EXCEPTION 'Quantidade indisponivel em estoque'
    ELSE
        UPDATE Produto SET qtde_disponivel = qtde_disponivel - NEW.qtde_vendida
        WHERE cod_prod = NEW.cod_prod;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verifica_estoque 
BEFORE INSERT ON RegistroVendas
FOR EACH ROW 
EXECUTE FUNCTION verifica_estoque();
```
    
```sql
-- Tentativa de venda de 5 unidades de Basico (deve ser bem-sucedida, pois há 10 unidades disponíveis)
INSERT INTO RegistroVendas (cod_prod, qtde_vendida) VALUES (1, 5);

-- Tentativa de venda de 6 unidades de Dados (deve ser bem-sucedida, pois há 5 unidades disponíveis e a quantidade vendida não excede o estoque)
INSERT INTO RegistroVendas (cod_prod, qtde_vendida) VALUES (2, 5);

-- Tentativa de venda de 16 unidades de Versao (deve falhar, pois só há 15 unidades disponíveis)
INSERT INTO RegistroVendas (cod_prod, qtde_vendida) VALUES (3, 16);
```

## Extra

**Objetivo: Exemplificar o Uso de Materialized Views, Triggers e Stored Procedures em um Contexto de Business Intelligence**

Este repositório tem como objetivo apresentar relatórios avançados construídos em SQL, demonstrando a aplicação prática de conceitos fundamentais de Business Intelligence (BI). As análises disponibilizadas aqui são projetadas para serem aplicadas em empresas de todos os tamanhos, ajudando-as a se tornarem mais analíticas e orientadas por dados.

**Como Funciona:**

1. **Materialized Views:** As Materialized Views são utilizadas para pré-calcular e armazenar resultados de consultas complexas. Neste cenário, as Materialized Views são empregadas para melhorar o desempenho de consultas frequentes e fornecer acesso rápido a dados agregados essenciais para análises.
    
2. **Triggers:** Triggers são mecanismos que permitem a execução automática de ações em resposta a eventos específicos no banco de dados. Neste contexto, as Triggers são empregadas para garantir a integridade dos dados e aplicar lógica de negócios, como validações e atualizações automáticas.
    
3. **Stored Procedures:** Stored Procedures são conjuntos de instruções SQL pré-compiladas e armazenadas no banco de dados. Elas podem ser chamadas repetidamente para executar tarefas complexas de forma eficiente e consistente. Neste caso, as Stored Procedures são utilizadas para automatizar processos de ETL (Extração, Transformação e Carregamento) e realizar operações avançadas de manipulação de dados.

**Benefícios:**

* **Extração de Insights Valiosos:** Os relatórios avançados disponibilizados neste repositório permitem que as organizações extraiam insights valiosos de seus dados, proporcionando uma compreensão mais profunda de seus processos e desempenho.
* **Apoio à Tomada de Decisões Estratégicas:** Com acesso a análises detalhadas e atualizadas, as empresas podem tomar decisões estratégicas mais informadas e direcionadas, impulsionando o crescimento e a eficiência operacional.]

**Caso Materialized View:**

Este conjunto de comandos SQL define uma ETL (Extração, Transformação e Carregamento) para gerar um relatório de vendas acumuladas mensais. A ETL consiste em uma visualização materializada chamada `sales_accumulated_monthly_mv` e duas triggers que garantem que a visualização seja atualizada sempre que houver alterações nas tabelas `order_details` e `orders`.

1. **Visualização Materializada (`sales_accumulated_monthly_mv`):** Esta visualização materializada calcula a soma acumulada das vendas mensais. Ela extrai o ano e o mês da data do pedido e calcula a soma das vendas para cada mês. Os resultados são agrupados por ano e mês.
    
2. **Trigger para Atualização da Visualização (`trg_refresh_sales_accumulated_monthly_mv_order_details` e `trg_refresh_sales_accumulated_monthly_mv_orders`):** Duas triggers foram criadas para garantir que a visualização materializada seja atualizada sempre que houver alterações nas tabelas `order_details` e `orders`. Quando ocorrerem inserções, atualizações ou exclusões nessas tabelas, as triggers acionarão a função `refresh_sales_accumulated_monthly_mv`, que atualizará a visualização materializada.

**Caso Stored Procedured:**


Este conjunto de comandos SQL visa monitorar e atualizar alterações nos títulos dos funcionários na tabela `employees` e registrar essas mudanças na tabela `employees_auditoria`.

1. **Tabela de Auditoria de Funcionários (`employees_auditoria`):** Uma tabela foi criada para registrar as mudanças nos títulos dos funcionários. Ela possui os seguintes campos:
    
    * `employee_id`: O ID do funcionário afetado.
    * `nome_anterior`: O título anterior do funcionário.
    * `nome_novo`: O novo título do funcionário.
    * `data_modificacao`: A data e hora da modificação (com o valor padrão definido como o momento atual).
2. **Trigger para Auditoria de Títulos (`trg_auditoria_titulo`):** Uma trigger foi criada para ser acionada após a atualização do título na tabela `employees`. Esta trigger chama uma função que registra a mudança na tabela `employees_auditoria`.
    
3. **Procedimento para Atualização de Título (`atualizar_titulo_employee`):** Uma stored procedure foi criada para facilitar a atualização do título de um funcionário. Ela aceita o ID do funcionário e o novo título como parâmetros e executa uma atualização na tabela `employees`.

**Conclusão:**

Este repositório oferece uma oportunidade única para empresas de todos os setores aproveitarem o poder do Business Intelligence por meio de relatórios avançados em SQL. Ao adotar essas práticas, as organizações podem transformar dados em insights acionáveis, impulsionando o sucesso e a inovação em um ambiente competitivo.




Conteúdo original está neste [Repositório Oficial](https://github.com/lvgalvao/data-engineering-roadmap/tree/main/Bootcamp%20-%20SQL%20e%20Analytics/Aula-09).
