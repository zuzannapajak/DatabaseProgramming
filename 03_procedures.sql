-- Adding a new user with role-based email validation
CREATE OR REPLACE PROCEDURE AddUser(
    p_role IN VARCHAR2,
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone_number IN VARCHAR2
) IS
    email_count INT;
    invalid_role EXCEPTION;
BEGIN
    -- Validate role
    IF p_role NOT IN ('admin', 'basic') THEN
        RAISE invalid_role;
    END IF;

    -- Validate email uniqueness
    SELECT COUNT(*)
    INTO email_count
    FROM users
    WHERE email = p_email;

    IF email_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Email already exists.');
    END IF;

    -- Insert the new user
    INSERT INTO users (id, role, first_name, last_name, email, phone_number)
    VALUES (users_seq.NEXTVAL, p_role, p_first_name, p_last_name, p_email, p_phone_number);
    
    COMMIT;
EXCEPTION
    WHEN invalid_role THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid role specified.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END AddUser;
/
-- AddUser procedure end

-- Updating employee salaries based on performance rating
CREATE OR REPLACE PROCEDURE UpdateEmployeeSalaries(
    p_department_id IN INT,
    p_rating IN VARCHAR2
) IS
    CURSOR emp_cursor IS
        SELECT id, salary FROM employees WHERE department_id = p_department_id;
    
    v_employee_id INT;
    v_current_salary NUMBER(10, 2);
    v_new_salary NUMBER(10, 2);
    salary_increase EXCEPTION;
    
    performance_bonus CONSTANT NUMBER := 0.10;
    default_bonus CONSTANT NUMBER := 0.05;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_employee_id, v_current_salary;
        EXIT WHEN emp_cursor%NOTFOUND;
        
        -- Determine new salary based on rating
        IF p_rating = 'A' THEN
            v_new_salary := v_current_salary * (1 + performance_bonus);
        ELSE
            v_new_salary := v_current_salary * (1 + default_bonus);
        END IF;
        
        IF v_new_salary < v_current_salary THEN
            RAISE salary_increase;
        END IF;

        -- Update salary
        UPDATE employees SET salary = v_new_salary WHERE id = v_employee_id;
    END LOOP;
    CLOSE emp_cursor;
    
    COMMIT;
EXCEPTION
    WHEN salary_increase THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error in calculating new salary.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END UpdateEmployeeSalaries;
/
-- UpdateEmployeeSalaries procedure end

-- Retrieving all tasks for a given service and status
CREATE OR REPLACE PROCEDURE RetrieveTasks(
    p_service_id IN INT,
    p_status IN VARCHAR2,
    p_tasks OUT SYS_REFCURSOR
) IS
BEGIN
    -- Open the cursor for the output parameter
    OPEN p_tasks FOR
        SELECT t.id, t.service_step_id, t.status, t.status_changed_at, t.order_id, t.assignee, t.input_data
        FROM tasks t
        JOIN orders o ON t.order_id = o.id
        WHERE o.service_id = p_service_id
          AND t.status = p_status;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error retrieving tasks.');
END RetrieveTasks;
/
-- RetrieveTasks procedure end
