-- Create the package my_functions specification
CREATE OR REPLACE PACKAGE my_functions AS 
    -- Sums salaries for employees in a specified department or for all employees if p_department_id is null
    FUNCTION sum_salaries(p_department_id departments.id%TYPE) RETURN NUMBER;

    -- Returns average salary for employees in a specified department or for all employees if p_department_id is null
    FUNCTION get_avg_salary(p_department_id departments.id%TYPE) RETURN NUMBER;

    -- Calculates total revenue generated from a specified company or all companies if p_company_id is null
    FUNCTION calculate_total_revenue(p_company_id companies.id%TYPE) RETURN NUMBER;
    
    -- Calculates average completion time for tasks for a given department or all tasks if p_department_id is null
    FUNCTION calculate_avg_completion_time(p_department_id IN departments.id%TYPE) RETURN NUMBER;
END my_functions;

-- Create the package my_functions body
CREATE OR REPLACE PACKAGE BODY my_functions AS 

    -- Sums salaries for employees in a specified department or for all employees if p_department_id is null
    FUNCTION sum_salaries(p_department_id departments.id%TYPE)
    RETURN NUMBER IS
        total_sal NUMBER;
    BEGIN
        IF p_department_id IS NOT NULL THEN
            SELECT NVL(SUM(salary), 0) INTO total_sal FROM employees WHERE department_id = p_department_id;
        ELSE
            SELECT NVL(SUM(salary), 0) INTO total_sal FROM employees;
        END IF;

        RETURN total_sal;
    END;


    -- Returns average salary for employees in a specified department or for all employees if p_department_id is null
    FUNCTION get_avg_salary(p_department_id departments.id%TYPE)
    RETURN NUMBER IS
        avg_sal NUMBER;
    BEGIN
        IF p_department_id IS NOT NULL THEN
            SELECT NVL(AVG(salary), 0) INTO avg_sal FROM employees WHERE department_id = p_department_id;
        ELSE
            SELECT NVL(AVG(salary), 0) INTO avg_sal FROM employees;
        END IF;

        RETURN avg_sal;
    END;


    -- Calculates total revenue generated from a specified company or all companies if p_company_id is null
    FUNCTION calculate_total_revenue(p_company_id companies.id%TYPE)
    RETURN NUMBER
    IS
        v_total_revenue NUMBER(10,2) := 0;
    BEGIN
        -- Calculate the total revenue from orders where all tasks are 'done'
        SELECT SUM(s.price)
        INTO v_total_revenue
        FROM services s
        JOIN orders o ON s.id = o.service_id
        WHERE (p_company_id IS NULL OR o.company_id = p_company_id)
        AND NOT EXISTS (
            SELECT 1 FROM tasks t
            WHERE t.order_id = o.id AND t.status <> 'done'
        );

        -- Return the total revenue; returns 0 if no suitable orders are found
        RETURN NVL(v_total_revenue, 0);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);
    END calculate_total_revenue;


    -- Calculates average completion time for tasks for a given department or all tasks if p_department_id is null
    FUNCTION calculate_avg_completion_time(p_department_id IN departments.id%TYPE) 
    RETURN NUMBER IS
        total_time NUMBER(10, 2) := 0;
        task_count INT := 0;
        task_record tasks%ROWTYPE;
        completion_time INTERVAL DAY TO SECOND;

        CURSOR task_cursor IS
            SELECT t.*
            FROM tasks t
            JOIN service_nodes sn ON sn.id = t.service_node_id
            JOIN service_steps ss ON ss.id = sn.service_step_id
            WHERE (p_department_id IS NULL OR ss.department_id = p_department_id) 
            AND t.status = 'done'
            AND t.status_changed_at IS NOT NULL
            AND t.created_at IS NOT NULL;
    BEGIN
        OPEN task_cursor;
        LOOP
            FETCH task_cursor INTO task_record;
            EXIT WHEN task_cursor%NOTFOUND;

            -- Calculate time difference in minutes
            completion_time := task_record.status_changed_at - task_record.created_at;
            total_time := total_time + EXTRACT(DAY FROM completion_time) * 1440 + EXTRACT(HOUR FROM completion_time) * 60 + EXTRACT(MINUTE FROM completion_time);

            task_count := task_count + 1;
        END LOOP;
        CLOSE task_cursor;

        IF task_count > 0 THEN
            RETURN total_time / task_count;
        ELSE
            RETURN NULL;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'An error occurred while calculating average completion time: ' || SQLERRM);
    END calculate_avg_completion_time;

END my_functions;
