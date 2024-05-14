-- sequences

CREATE SEQUENCE users_id_seq;

CREATE OR REPLACE TRIGGER users_on_insert
  BEFORE INSERT ON users
  FOR EACH ROW
BEGIN
  SELECT users_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

CREATE SEQUENCE departments_id_seq;

CREATE OR REPLACE TRIGGER departments_on_insert
  BEFORE INSERT ON departments
  FOR EACH ROW
BEGIN
  SELECT departments_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

CREATE SEQUENCE companies_id_seq;

CREATE OR REPLACE TRIGGER companies_on_insert
  BEFORE INSERT ON companies
  FOR EACH ROW
BEGIN
  SELECT companies_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

CREATE SEQUENCE services_id_seq;

CREATE OR REPLACE TRIGGER services_on_insert
  BEFORE INSERT ON services
  FOR EACH ROW
BEGIN
  SELECT services_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

CREATE SEQUENCE service_steps_id_seq;

CREATE OR REPLACE TRIGGER service_steps_on_insert
  BEFORE INSERT ON service_steps
  FOR EACH ROW
BEGIN
  SELECT service_steps_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

CREATE SEQUENCE tasks_id_seq;

CREATE OR REPLACE TRIGGER tasks_on_insert
  BEFORE INSERT ON tasks
  FOR EACH ROW
BEGIN
  SELECT tasks_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

CREATE SEQUENCE orders_id_seq;

CREATE OR REPLACE TRIGGER orders_on_insert
  BEFORE INSERT ON orders
  FOR EACH ROW
BEGIN
  SELECT orders_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

-- after order creation insert appropriate tasks based on the purchased service

CREATE OR REPLACE TRIGGER insert_tasks_after_order
AFTER INSERT ON orders
FOR EACH ROW
DECLARE
    CURSOR service_steps_cursor IS
        SELECT id, department_id 
        FROM service_steps 
        WHERE service_id = :NEW.service_id;

    v_assignee employees.id%TYPE;
BEGIN
    FOR step IN service_steps_cursor LOOP
        -- Select a random employee from the department
        SELECT id INTO v_assignee
        FROM (
            SELECT id
            FROM employees
            WHERE department_id = step.department_id
            ORDER BY DBMS_RANDOM.VALUE
        )
        WHERE ROWNUM = 1;

        -- Insert the task
        INSERT INTO tasks (
            id, service_step_id, status, order_id, assignee
        ) VALUES (
            tasks_seq.NEXTVAL,
            step.id,
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM service_step_dependencies
                    WHERE service_step_id = v_service_step_id
                ) THEN 'blocked'
                ELSE 'to_do'
            END, -- Status based on dependencies
            :NEW.id,
            v_assignee
        );
    END LOOP;
END;

-- update status_changed_at whenever status changes in tasks table

CREATE OR REPLACE TRIGGER update_status_changed_at
BEFORE UPDATE ON tasks
FOR EACH ROW
BEGIN
    IF :NEW.status != :OLD.status THEN
        :NEW.status_changed_at := SYSTIMESTAMP;
    END IF;
END;
