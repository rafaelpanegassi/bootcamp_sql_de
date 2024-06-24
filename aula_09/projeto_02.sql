CREATE TABLE employees_auditoria (
    employee_id INT,
    nome_anterior VARCHAR(100),
    nome_novo VARCHAR(100),
    data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION registrar_auditoria_titulo()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employees_auditoria (employee_id, nome_anterior, nome_novo)
    VALUES (NEW.employee_id, OLD.title, NEW.title);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_titulo
AFTER UPDATE OF title ON employees
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_titulo();


CREATE OR REPLACE PROCEDURE atualizar_titulo_employee(
    p_employee_id INT,
    p_new_title VARCHAR(100)
)
AS $$
BEGIN
    UPDATE employees
    SET title = p_new_title
    WHERE employee_id = p_employee_id;
END;
$$ LANGUAGE plpgsql;

CALL atualizar_titulo_employee(1, 'Estagiario');