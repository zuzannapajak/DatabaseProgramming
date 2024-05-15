FUNCTION sumSalaries(IN department_id VARCHAR(100))
RETURN DECIMAL(10, 2)
BEGIN
	DECLARE totalSal DECIMAL(10, 2);
    IF department_id IS NOT NULL THEN
        SELECT SUM(salary) INTO totalSal FROM employees WHERE employees.department_id = department_id;
    ELSE
        SELECT SUM(salary) INTO totalSal FROM employees;
    END IF;
RETURN totalSal;
END;


CREATE FUNCTION calculateAverageSalary(IN department_id VARCHAR(100))
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE avgSalary DECIMAL(10, 2);
    
    IF department_id IS NOT NULL THEN
        SELECT AVG(salary) INTO avgSalary FROM employees WHERE employees.department_id = department_id;
    ELSE
        SELECT AVG(salary) INTO avgSalary FROM employees;
    END IF;

    RETURN avgSalary;
END;



CREATE OR REPLACE FUNCTION calculate_total_cost(company_id IN INT, start_date IN DATE, end_date IN DATE) RETURN NUMBER IS
    total_cost NUMBER(10, 2) := 0;
    order_record orders%ROWTYPE;
    service_record services%ROWTYPE;
    CURSOR order_cursor IS
        SELECT * FROM orders
        WHERE company_id = company_id AND created_at BETWEEN start_date AND end_date;
BEGIN
    OPEN order_cursor;
    LOOP
        FETCH order_cursor INTO order_record;
        EXIT WHEN order_cursor%NOTFOUND;
        
        SELECT * INTO service_record FROM services WHERE id = order_record.service_id;
        total_cost := total_cost + service_record.price;
    END LOOP;
    CLOSE order_cursor;

    RETURN total_cost;
END;



CREATE OR REPLACE FUNCTION calculate_avg_completion_time(department_id IN INT) RETURN NUMBER IS
    total_time NUMBER(10, 2) := 0;
    task_count NUMBER(10) := 0;
    task_record tasks%ROWTYPE;
    employee_record employees%ROWTYPE;
    CURSOR task_cursor IS
        SELECT t.* FROM tasks t
        JOIN employees e ON t.assignee = e.id
        WHERE e.department_id = department_id AND t.status = 'done';
BEGIN
    OPEN task_cursor;
    LOOP
        FETCH task_cursor INTO task_record;
        EXIT WHEN task_cursor%NOTFOUND;

        SELECT * INTO employee_record FROM employees WHERE id = task_record.assignee;
        
        IF task_record.status_changed_at IS NOT NULL THEN
            total_time := total_time + (task_record.status_changed_at - task_record.created_at);
            task_count := task_count + 1;
        END IF;
    END LOOP;
    CLOSE task_cursor;

    IF task_count > 0 THEN
        RETURN total_time / task_count;
    ELSE
        RETURN NULL;
    END IF;
END;





