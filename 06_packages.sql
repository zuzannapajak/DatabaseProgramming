-- Create the package dept_pkg specification
CREATE PACKAGE dept_pkg AS  -- specification (visible part)
   -- Procedure to add a department
   PROCEDURE add_department(p_id IN INT, p_name IN VARCHAR2);

   -- Procedure to delete a department
   PROCEDURE delete_department(p_id IN INT);
END dept_pkg;
/

-- Create the package dept_pkg body
CREATE PACKAGE BODY dept_pkg AS  -- body (hidden part)
   -- Procedure to add a department
   PROCEDURE add_department(p_id IN INT, p_name IN VARCHAR2) IS
   BEGIN
      INSERT INTO departments (id, name) VALUES (p_id, p_name);
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
   END add_department;

   -- Procedure to delete a department
   PROCEDURE delete_department(p_id IN INT) IS
   BEGIN
      DELETE FROM departments WHERE id = p_id;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
   END delete_department;
END dept_pkg;
/

-- Create the package company_pkg specification
CREATE OR REPLACE PACKAGE company_pkg AS
    -- Function to insert a new company
    FUNCTION insert_company(p_id INT, p_name VARCHAR2, p_nip INT) RETURN VARCHAR2;

    -- Function to update an existing company
    FUNCTION update_company(p_id INT, p_name VARCHAR2, p_nip INT) RETURN VARCHAR2;

    -- Function to delete a company
    FUNCTION delete_company(p_id INT) RETURN VARCHAR2;
END company_pkg;
/

-- Create the package company_pkg body
CREATE OR REPLACE PACKAGE BODY company_pkg AS
    -- Function to insert a new company
    FUNCTION insert_company(p_id INT, p_name VARCHAR2, p_nip INT) RETURN VARCHAR2 IS
    BEGIN
        INSERT INTO companies (id, name, nip) VALUES (p_id, p_name, p_nip);
        RETURN 'Company inserted successfully.';
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END insert_company;

    -- Function to update an existing company
    FUNCTION update_company(p_id INT, p_name VARCHAR2, p_nip INT) RETURN VARCHAR2 IS
    BEGIN
        UPDATE companies SET name = p_name, nip = p_nip WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RETURN 'No company with the provided ID found.';
        ELSE
            RETURN 'Company updated successfully.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END update_company;

    -- Function to delete a company
    FUNCTION delete_company(p_id INT) RETURN VARCHAR2 IS
    BEGIN
        DELETE FROM companies WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RETURN 'No company with the provided ID found.';
        ELSE
            RETURN 'Company deleted successfully.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END delete_company;
END company_pkg;
/
