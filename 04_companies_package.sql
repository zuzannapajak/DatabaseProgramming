CREATE OR REPLACE PACKAGE companies_pkg AS 
    -- Procedure to add a department
    PROCEDURE add_company(p_name IN companies.name%TYPE, p_nip IN companies.nip%TYPE);

    -- Returns true if company was deleted and false otherwise
    FUNCTION delete_company(p_id IN companies.id%TYPE) RETURN BOOLEAN;

    -- printing all relevant information about a company
    PROCEDURE company_summary(p_company_id INT);

    -- Calculates total revenue generated from a specified company or all companies if p_company_id is null
    FUNCTION calculate_total_revenue(p_company_id companies.id%TYPE) RETURN NUMBER;
    
END companies_pkg;

CREATE OR REPLACE PACKAGE BODY companies_pkg AS 
    -- Procedure to add a company
    PROCEDURE add_company(
        p_name IN companies.name%TYPE,
        p_nip IN companies.nip%TYPE
    ) IS
    BEGIN
        INSERT INTO companies (id, name, nip)
        VALUES (companies_id_seq.NEXTVAL, p_name, p_nip);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END add_company;

    -- Returns true if company was deleted and false otherwise
    FUNCTION delete_company(p_id IN companies.id%TYPE) 
    RETURN BOOLEAN IS
    BEGIN
        DELETE FROM companies WHERE id = p_id;

        -- Check if any row was deleted
        RETURN SQL%ROWCOUNT > 0;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_company;

    -- printing all relevant information about a company
    PROCEDURE company_summary(p_company_id INT)
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

END companies_pkg;
