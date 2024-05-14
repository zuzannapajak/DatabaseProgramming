-- 1. List all users with their roles and department names (if they are employees)
SELECT u.id, u.role, u.first_name, u.last_name, d.name AS department_name
FROM users u
LEFT JOIN employees e ON u.id = e.id
LEFT JOIN departments d ON e.department_id = d.id;

-- 2. List all employees with their company name and role in the company
SELECT u.id, u.first_name, u.last_name, c.name AS company_name, cu.role AS company_role
FROM users u
JOIN employees e ON u.id = e.id
JOIN company_users cu ON u.id = cu.user_id
JOIN companies c ON cu.company_id = c.id;

-- 3. List all services with their steps and the departments responsible for each step
SELECT s.name AS service_name, ss.name AS step_name, d.name AS department_name
FROM services s
JOIN service_steps ss ON s.id = ss.service_id
JOIN departments d ON ss.department_id = d.id;

-- 4. List all orders with the company name, service name, and number of tasks associated with the order
SELECT o.id AS order_id, c.name AS company_name, s.name AS service_name, COUNT(t.id) AS task_count
FROM orders o
JOIN companies c ON o.company_id = c.id
JOIN services s ON o.service_id = s.id
LEFT JOIN tasks t ON o.id = t.order_id
GROUP BY o.id, c.name, s.name;

-- 5. List tasks with their current status and the name of the employee assigned, only for tasks that are not 'done'
SELECT t.id AS task_id, t.status, u.first_name, u.last_name
FROM tasks t
JOIN users u ON t.assignee = u.id
WHERE t.status != 'done';

-- 6. List all tasks grouped by status and count how many tasks are in each status
SELECT t.status, COUNT(t.id) AS task_count
FROM tasks t
GROUP BY t.status;

-- 7. List all services with their total number of steps and total number of dependencies
SELECT s.name AS service_name, COUNT(ss.id) AS step_count, COUNT(ssd.service_step_id) AS dependency_count
FROM services s
LEFT JOIN service_steps ss ON s.id = ss.service_id
LEFT JOIN service_step_dependencies ssd ON ss.id = ssd.service_step_id
GROUP BY s.name;

-- 8. List employees and their total salary by department
SELECT d.name AS department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.name;

-- 9. List all orders with their associated tasks and task dependencies
SELECT o.id AS order_id, t.id AS task_id, td.dependent_task_id
FROM orders o
JOIN tasks t ON o.id = t.order_id
LEFT JOIN task_dependencies td ON t.id = td.task_id
WHERE td.dependent_task_id IS NOT NULL;

-- 10. List companies and the number of employees (users) associated with each
SELECT c.name AS company_name, COUNT(cu.user_id) AS user_count
FROM companies c
JOIN company_users cu ON c.id = cu.company_id
GROUP BY c.name;
