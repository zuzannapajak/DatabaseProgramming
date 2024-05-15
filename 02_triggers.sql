-- after order creation insert appropriate tasks based on the purchased service
CREATE OR REPLACE TRIGGER insert_tasks_after_order
AFTER INSERT ON orders
FOR EACH ROW
DECLARE
    CURSOR service_nodes_cursor IS
        SELECT sn.id, ss.department_id 
        FROM service_nodes sn
        JOIN service_steps ss ON ss.id = sn.service_step_id
        WHERE sn.service_id = :NEW.service_id;

    v_assignee employees.user_id%TYPE;
BEGIN
    FOR node IN service_nodes_cursor LOOP
        -- Select a random employee from the department
        SELECT user_id INTO v_assignee
        FROM (
            SELECT user_id
            FROM employees
            WHERE department_id = node.department_id
            ORDER BY DBMS_RANDOM.VALUE
        )
        WHERE ROWNUM = 1;

        -- Insert the task
        INSERT INTO tasks (
             id, service_node_id, status, order_id, assignee
        ) VALUES (
            tasks_id_seq.NEXTVAL,
            node.id,
            'to_do',
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


-- check if service nodes that depend on each other are from the same service
CREATE OR REPLACE TRIGGER validate_service_id
BEFORE INSERT OR UPDATE ON service_node_dependencies
FOR EACH ROW
DECLARE
    v_service_id_dependent   service_nodes.service_id%TYPE;
    v_service_id_dependency  service_nodes.service_id%TYPE;
BEGIN
    -- Fetch service_id for dependent_node_id
    SELECT service_id INTO v_service_id_dependent
    FROM service_nodes
    WHERE id = :NEW.dependent_node_id;

    -- Fetch service_id for dependency_node_id
    SELECT service_id INTO v_service_id_dependency
    FROM service_nodes
    WHERE id = :NEW.dependency_node_id;

    -- Compare the service_ids
    IF v_service_id_dependent != v_service_id_dependency THEN
        RAISE_APPLICATION_ERROR(-20001, 'Dependent node and dependency node must belong to the same service');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'One of the nodes does not exist');
END;

