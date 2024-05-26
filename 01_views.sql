CREATE OR REPLACE VIEW task_dependencies AS
SELECT
    t1.id AS dependent_task_id,
    t2.id AS dependency_task_id
FROM tasks t1
JOIN service_node_dependencies snd ON snd.dependent_node_id = t1.service_node_id
JOIN tasks t2 ON t2.service_node_id = snd.dependency_node_id AND t2.order_id = t1.order_id;

-- helper function to check wheter a task is blocked
CREATE OR REPLACE FUNCTION is_task_blocked(p_task_id IN tasks.id%TYPE) RETURN INT AS
    v_exists INT; 
BEGIN
    SELECT CASE 
               WHEN COUNT(*) > 0 THEN 1 
               ELSE 0 
           END INTO v_exists
    FROM task_dependencies td
    JOIN tasks t ON t.id = td.dependency_task_id
    WHERE td.dependent_task_id = p_task_id AND t.status != 'done';

    RETURN v_exists;
END;

CREATE OR REPLACE VIEW tasks_joined AS
SELECT
    t.*,
    ss.name,
    ss.description,
    s.name AS service_name,
    u.email AS assignee_email,
    c.id AS company_id,
    c.name AS company_name,
    is_task_blocked(t.id) AS is_blocked
FROM tasks t
JOIN service_nodes sn ON sn.id = t.service_node_id
JOIN service_steps ss ON ss.id = sn.service_step_id
JOIN services s ON s.id = sn.service_id
JOIN users u ON t.assignee = u.id
JOIN orders o ON o.id = t.order_id
JOIN companies c ON c.id = o.company_id;

CREATE OR REPLACE VIEW employees_joined AS
SELECT
    e.*,
    u.role,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    d.name as department_name
FROM employees e
JOIN users u on u.id = e.user_id
JOIN departments d on d.id = e.department_id;
