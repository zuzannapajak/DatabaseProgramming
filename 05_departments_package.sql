CREATE OR REPLACE PACKAGE departments AS
   -- Procedure to add a department
   PROCEDURE add_department(p_name IN departments.name%TYPE);

   -- Returns true if department was deleted and false otherwise
   FUNCTION delete_department(p_id IN departments.id%TYPE) RETURN BOOLEAN;

   -- Updating employee salaries based on department's performance rating
   PROCEDURE update_department_salaries(p_department_id IN employees.department_id%TYPE, p_rating IN VARCHAR2);

   -- Sums salaries for employees in a specified department or for all employees if p_department_id is null
    FUNCTION sum_salaries(p_department_id departments.id%TYPE) RETURN NUMBER;

   -- Returns average salary for employees in a specified department or for all employees if p_department_id is null
   FUNCTION get_avg_salary(p_department_id departments.id%TYPE) RETURN NUMBER;

END departments;

CREATE OR REPLACE PACKAGE BODY departments AS
   -- Procedure to add a department
   PROCEDURE add_department(p_name IN departments.name%TYPE) IS
   BEGIN
      INSERT INTO departments (id, name) VALUES (departments_id_seq.NEXTVAL, p_name);
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE;
   END add_department;

   -- Returns true if department was deleted and false otherwise
   FUNCTION delete_department(p_id IN departments.id%TYPE) 
	RETURN BOOLEAN IS
   BEGIN
      DELETE FROM departments WHERE id = p_id;
		
		-- Check if any row was deleted
      RETURN SQL%ROWCOUNT > 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE;
   END delete_department;

   -- Updating employee salaries based on department's performance rating
   PROCEDURE update_department_salaries(
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

END departments;
