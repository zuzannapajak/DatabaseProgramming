-- Query 1: List all users with their associated departments
SELECT u.first_name, u.last_name, d.name AS department_name
FROM users u
JOIN employees e ON u.id = e.user_id
JOIN departments d ON e.department_id = d.id;

-- Query 2: Find the total number of employees in each department
SELECT d.name, COUNT(e.user_id) AS employee_count
FROM departments d
JOIN employees e ON d.id = e.department_id
GROUP BY d.name;

-- Query 3: Get details of all tasks that are in 'to_do' status for a specific department
SELECT t.*, d.name AS department_name
FROM tasks t
JOIN service_nodes sn ON t.service_node_id = sn.id
JOIN service_steps ss ON sn.service_step_id = ss.id
JOIN departments d ON ss.department_id = d.id
WHERE t.status = 'to_do' AND d.id = 5;

-- Query 4: Display the average salary of employees in each department
SELECT d.name AS department_name, AVG(e.salary) AS average_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.name;

-- Query 5: List all services with their total number of steps
SELECT s.name, COUNT(sn.id) AS total_steps
FROM services s
JOIN service_nodes sn ON s.id = sn.service_id
GROUP BY s.name;

-- Query 6: Show all companies with their latest order date
SELECT c.name, MAX(o.created_at) AS latest_order_date
FROM companies c
LEFT JOIN orders o ON c.id = o.company_id
GROUP BY c.name;

-- Query 7: Retrieve all tasks for a specific order including service step details
SELECT t.*, ss.name AS step_name, ss.description
FROM tasks t
JOIN service_nodes sn ON t.service_node_id = sn.id
JOIN service_steps ss ON sn.service_step_id = ss.id
WHERE t.order_id = 1;

-- Query 8: Count of orders per company sorted by the total number of orders descending
SELECT c.name, COUNT(o.id) AS order_count
FROM companies c
LEFT JOIN orders o ON c.id = o.company_id
GROUP BY c.name
ORDER BY order_count DESC;

-- Query 9: List all active service node dependencies for a particular service
SELECT s.name AS service_name, ssd.dependent_node_id, ssd.dependency_node_id
FROM service_nodes sn
JOIN services s ON sn.service_id = s.id
JOIN service_node_dependencies ssd ON sn.id = ssd.dependent_node_id
WHERE s.id = 1;

-- Query 10: List employees who are assigned tasks but have not completed any
SELECT u.first_name, u.last_name
FROM users u
JOIN tasks t ON u.id = t.assignee
GROUP BY u.first_name, u.last_name
HAVING SUM(CASE WHEN t.status = 'done' THEN 1 ELSE 0 END) = 0;

-- Query 11: List users with the count of tasks 'to_do' and 'done'
SELECT u.first_name, u.last_name,
       COUNT(CASE WHEN t.status = 'to_do' THEN 1 END) AS tasks_to_do,
       COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS tasks_done
FROM users u
LEFT JOIN tasks t ON u.id = t.assignee
GROUP BY u.first_name, u.last_name;

-- Query 12: List all departments with their total salary expenditure
SELECT d.name AS department_name, SUM(e.salary) AS total_salary_expenditure
FROM departments d
JOIN employees e ON d.id = e.department_id
GROUP BY d.name;

-- Query 13: Find all users who are assigned tasks in the 'in_progress' status
SELECT u.first_name, u.last_name, t.id AS task_id, t.status
FROM users u
JOIN tasks t ON u.id = t.assignee
WHERE t.status = 'in_progress';

-- Query 14: Get the total number of services offered by each company
SELECT c.name AS company_name, COUNT(s.id) AS total_services
FROM companies c
JOIN orders o ON c.id = o.company_id
JOIN services s ON o.service_id = s.id
GROUP BY c.name;

-- Query 15: List all tasks along with the names of the services they are part of
SELECT t.id AS task_id, t.status, s.name AS service_name
FROM tasks t
JOIN service_nodes sn ON t.service_node_id = sn.id
JOIN services s ON sn.service_id = s.id;

-- Query 16: Find the total revenue generated from orders for each company
SELECT c.name AS company_name, SUM(s.price) AS total_revenue
FROM companies c
JOIN orders o ON c.id = o.company_id
JOIN services s ON o.service_id = s.id
GROUP BY c.name;
