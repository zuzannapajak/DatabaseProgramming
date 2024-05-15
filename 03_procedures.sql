-- Adding a new user with role-based email validation
CREATE OR REPLACE PROCEDURE add_user(
    p_role IN users.role%TYPE,
    p_first_name IN users.role%TYPE,
    p_last_name IN users.role%TYPE,
    p_email IN users.role%TYPE,
    p_phone_number IN users.role%TYPE
) IS
    email_count INT;
    invalid_role EXCEPTION;
    invalid_email EXCEPTION;
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
        RAISE invalid_email;
    END IF;

    -- Insert the new user
    INSERT INTO users (id, role, first_name, last_name, email, phone_number)
    VALUES (users_id_seq.NEXTVAL, p_role, p_first_name, p_last_name, p_email, p_phone_number);
    
    COMMIT;
EXCEPTION
    WHEN invalid_role THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid role specified.');
    WHEN invalid_email THEN
        RAISE_APPLICATION_ERROR(-20001, 'User with this email already exists.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END add_user;


-- Updating employee salaries based on department's performance rating
CREATE OR REPLACE PROCEDURE update_department_salaries(
    p_department_id IN employees.department_id%TYPE,
    p_rating IN VARCHAR2
) IS
    CURSOR emp_cursor IS
        SELECT user_id, salary FROM employees WHERE department_id = p_department_id;
    
    v_employee_id INT;
    v_current_salary NUMBER(10, 2);
    v_new_salary NUMBER(10, 2);
    v_bonus NUMBER(3, 2);
    
    invalid_rating EXCEPTION;
    
    bonus_a CONSTANT NUMBER := 0.10;
    bonus_b CONSTANT NUMBER := 0.07;
    bonus_c CONSTANT NUMBER := 0.05;
    bonus_d CONSTANT NUMBER := 0.02;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_employee_id, v_current_salary;
        EXIT WHEN emp_cursor%NOTFOUND;
        
        -- Determine bonus rate based on rating using a CASE statement
        v_bonus := CASE p_rating
            WHEN 'A' THEN bonus_a
            WHEN 'B' THEN bonus_b
            WHEN 'C' THEN bonus_c
            WHEN 'D' THEN bonus_d
            ELSE NULL  -- Assigning NULL to trigger the invalid_rating exception
        END;

        -- Check if the bonus calculation was successful
        IF v_bonus IS NULL THEN
            RAISE invalid_rating;
        END IF;
        
        -- Calculate new salary
        v_new_salary := v_current_salary * (1 + v_bonus);

        -- Update the employee's salary
        UPDATE employees SET salary = v_new_salary WHERE user_id = v_employee_id;
    END LOOP;
    CLOSE emp_cursor;
    
    COMMIT;
EXCEPTION
    WHEN invalid_rating THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid rating value. Allowed values are: A, B, C, D.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END update_department_salaries;


-- printing all relevant information about a company
CREATE OR REPLACE PROCEDURE company_summary(p_company_id INT)
IS
    v_company_name companies.name%TYPE;

    CURSOR company_users_cur IS
        SELECT u.id, u.first_name, u.last_name, cu.role
        FROM users u
        JOIN company_users cu ON u.id = cu.user_id
        WHERE cu.company_id = p_company_id;

    CURSOR company_orders_cur IS
        SELECT o.id, o.created_at, s.name AS service_name
        FROM orders o
        JOIN services s ON o.service_id = s.id
        WHERE o.company_id = p_company_id;

    v_user_id users.id%TYPE;
    v_first_name users.first_name%TYPE;
    v_last_name users.last_name%TYPE;
    v_role company_users.role%TYPE;
    v_order_id orders.id%TYPE;
    v_order_date orders.created_at%TYPE;
    v_service_ordered services.name%TYPE;
BEGIN
    SELECT name INTO v_company_name
    FROM companies
    WHERE id = p_company_id;

    DBMS_OUTPUT.PUT_LINE('Company Name: ' || v_company_name);

    DBMS_OUTPUT.PUT_LINE('Employees:');
    -- Retrieve and display company users
    OPEN company_users_cur;
    LOOP
        FETCH company_users_cur INTO v_user_id, v_first_name, v_last_name, v_role;
        EXIT WHEN company_users_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('User ID: ' || v_user_id || ' Name: ' || v_first_name || ' ' || v_last_name || ' Role: ' || v_role);
    END LOOP;
    CLOSE company_users_cur;

    DBMS_OUTPUT.PUT_LINE('Orders:');
    -- Retrieve and display orders
    OPEN company_orders_cur;
    LOOP
        FETCH company_orders_cur INTO v_order_id, v_order_date, v_service_ordered;
        EXIT WHEN company_orders_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Order ID: ' || v_order_id || ' Date: ' || TO_CHAR(v_order_date, 'DD-MON-YYYY') || ' Service: ' || v_service_ordered);
    END LOOP;
    CLOSE company_orders_cur;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found for this company.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
        ROLLBACK;
END company_summary;
