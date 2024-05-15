-- Create the package dept_pkg specification
CREATE OR REPLACE PACKAGE dept_pkg AS  -- specification (visible part)
   -- Procedure to add a department
   PROCEDURE add_department(p_name IN departments.name%TYPE);

   -- Procedure to delete a department
   PROCEDURE delete_department(p_id IN departments.id%TYPE);
END dept_pkg;

-- Create the package dept_pkg body
CREATE OR REPLACE PACKAGE BODY dept_pkg AS  -- body (hidden part)
   -- Procedure to add a department
   PROCEDURE add_department(p_name IN departments.name%TYPE) IS
   BEGIN
      INSERT INTO departments (id, name) VALUES (departments_id_seq.NEXTVAL, p_name);
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
   END add_department;

   -- Procedure to delete a department
   PROCEDURE delete_department(p_id IN departments.id%TYPE) IS
   BEGIN
      DELETE FROM departments WHERE id = p_id;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
   END delete_department;
END dept_pkg;
