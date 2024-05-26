INSERT INTO users (id, role, first_name, last_name, email, phone_number) VALUES
(1, 'admin', 'John', 'Doe', 'john.doe@example.com', '1234567890'),
(2, 'admin', 'Jessica', 'Garcia', 'jessica.garcia@example.com', '5678901234'),
(3, 'admin', 'Christopher', 'Lopez', 'christopher.lopez@example.com', '6543210987'),
(4, 'basic', 'Susan', 'Hall', 'susan.hall@example.com', '9876543210'),
(5, 'basic', 'Sarah', 'Taylor', 'sarah.taylor@example.com', '3216549870'),
(6, 'basic', 'Jane', 'Smith', 'jane.smith@example.com', '0987654321'),
(7, 'basic', 'Michael', 'Johnson', 'michael.johnson@example.com', '5551234567'),
(8, 'basic', 'Emily', 'Brown', 'emily.brown@example.com', '9879543210'),
(9, 'basic', 'Daniel', 'Martinez', 'daniel.martinez@example.com', '4567890123'),
(10, 'basic', 'Christopher', 'Anderson', 'christopher.anderson@example.com', '7890123456'),
(11, 'basic', 'Amanda', 'Thomas', 'amanda.thomas@example.com', '6583210987'),
(12, 'basic', 'Matthew', 'Hernandez', 'matthew.hernandez@example.com', '2345678901'),
(13, 'basic', 'David', 'Young', 'david.young@example.com', '2109876543'),
(14, 'basic', 'Ashley', 'King', 'ashley.king@example.com', '8765432109'),
(15, 'basic', 'James', 'Lee', 'james.lee@example.com', '4321098765'),
(16, 'basic', 'Jennifer', 'Walker', 'jennifer.walker@example.com', '9012345678'),
(17, 'basic', 'Mary', 'Perez', 'mary.perez@example.com', '1234527890'),
(18, 'basic', 'Robert', 'Wright', 'robert.wright@example.com', '8901234567'),
(19, 'basic', 'Linda', 'Scott', 'linda.scott@example.com', '3456789012'),
(20, 'basic', 'John', 'Adams', 'john.adams@example.com', '6789012345');

INSERT INTO departments (id, name) VALUES
(1, 'Marketing'),
(2, 'Finance'),
(3, 'Human Resources'),
(4, 'Engineering'),
(5, 'Sales');

INSERT INTO companies (id, name, nip) VALUES
(1, 'ABC Corporation', 1234567890),
(2, 'XYZ Ltd.', 9876543212),
(3, 'DEF Industries', 4567891234),
(4, 'GHI Enterprises', 3789123456);

INSERT INTO employees (user_id, department_id, salary) VALUES
(1, 1, 60000.00),
(2, 2, 75000.00),
(3, 3, 55000.00),
(4, 4, 80000.00),
(5, 5, 70000.00),
(6, 5, 69000.00);

INSERT INTO company_users (user_id, company_id, role) VALUES
(7, 1, 'owner'),
(8, 1, 'admin'),
(9, 1, 'basic'),
(10, 2, 'owner'),
(11, 2, 'admin'),
(12, 2, 'basic'),
(13, 2, 'basic'),
(14, 3, 'owner'),
(15, 3, 'basic'),
(16, 3, 'basic'),
(17, 3, 'basic'),
(18, 1, 'owner'),
(19, 1, 'admin'),
(20, 1, 'admin');

-- common service_steps

INSERT INTO service_steps (id, name, description, department_id, input_definition) VALUES
(1, 'Schedule a sales meeting', null, 5, null),
(2, 'Issue an Invoice', null, 2, '{"invoice": {"type": "file"}}');

-- Website Development service

INSERT INTO services (id, name, description, price) VALUES
(1, 'Website Development', 'Comprehensive website development service including design, development, and deployment.', 10000.00);

INSERT INTO service_steps (id, name, description, department_id, input_definition) VALUES
(3, 'Design Consultation', 'Discuss design preferences and requirements with the client.', 5, '{"preferences": {"type": "text", "description": "Client preferences and requirements"}}'),
(4, 'Wireframing', 'Create wireframes based on the design consultation.', 4, '{"wireframes": {"type": "image", "description": "Wireframes"}}'),
(5, 'Frontend Development', 'Develop the frontend of the website based on the wireframes.', 4, '{"code": {"type": "code", "description": "Frontend code"}}'),
(6, 'Backend Development', 'Develop the backend functionalities of the website.', 4, '{"code": {"type": "code", "description": "Backend code"}}'),
(7, 'Testing and Quality Assurance', 'Test the website thoroughly to ensure functionality and quality.', 3, '{"test_results": {"type": "text", "description": "Test results and feedback"}}'),
(8, 'Deployment and Launch', 'Deploy the website to the client server and launch it.', 4, null);

INSERT INTO service_nodes (id, service_id, service_step_id) VALUES 
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(4, 1, 4),
(5, 1, 5),
(6, 1, 6),
(7, 1, 7),
(8, 1, 8);

INSERT INTO service_node_dependencies (dependent_node_id, dependency_node_id) VALUES
(3, 1),
(4, 3),
(5, 4),
(6, 3),
(7, 5),
(7, 6),
(8, 7),
(2, 8);

-- Social Media Management service

INSERT INTO services (id, name, description, price) VALUES
(2, 'Social Media Management', 'Social media management service including content creation, scheduling, and analytics.', 2000.00);

INSERT INTO service_steps (id, name, description, department_id, input_definition) VALUES
(9, 'Client Onboarding', 'Onboard the client and gather necessary account access.', 1, '{"login": {"type": "text"}, "password": {"type": "text"}}'),
(10, 'Content Creation', 'Create engaging content for social media platforms.', 5, null),
(11, 'Scheduling', 'Schedule posts on various social media platforms.', 5, null),
(12, 'Analytics and Reporting', 'Analyze social media performance and generate reports.', 2, '{"spreadsheet_link": {"type": "text", "description": "Analytics report"}}');

INSERT INTO service_nodes (id, service_id, service_step_id) VALUES 
(9, 2, 1),
(10, 2, 2),
(11, 2, 9),
(12, 2, 10),
(13, 2, 11),
(14, 2, 12);

INSERT INTO service_node_dependencies (dependent_node_id, dependency_node_id) VALUES
(11, 9),
(12, 11),
(13, 12),
(14, 13),
(10, 14);

-- Search Engine Optimization (SEO) service

INSERT INTO services (id, name, description, price) VALUES
(3, 'Search Engine Optimization (SEO)', 'Search engine optimization service to improve website visibility and search rankings.', 3000.00);

INSERT INTO service_steps (id, name, description, department_id, input_definition) VALUES
(13, 'Website Audit', 'Conduct a comprehensive audit of the client website for SEO improvements.', 4, '{"report": {"type": "file", "description": "Audit report"}}'),
(14, 'Keyword Research', 'Research and identify relevant keywords for the client industry.', 1, '{"keyword_list":{"type": "file", "description": "Keyword list"}}'),
(15, 'On-Page Optimization', 'Optimize website content and structure for improved search rankings.', 4, null),
(16, 'Off-Page Optimization', 'Implement strategies to improve website authority and backlinks.', 4, null);

INSERT INTO service_nodes (id, service_id, service_step_id) VALUES 
(15, 3, 1),
(16, 3, 2),
(17, 3, 13),
(18, 3, 14),
(19, 3, 15),
(20, 3, 16);

INSERT INTO service_node_dependencies (dependent_node_id, dependency_node_id) VALUES
(17, 15),
(18, 15),
(19, 17),
(19, 18),
(20, 18),
(16, 19),
(16, 20);

-- orders

INSERT INTO orders (id, service_id, company_id) VALUES
(1, 1, 1),
(2, 1, 1),
(3, 1, 2),
(4, 1, 3),
(5, 2, 3),
(6, 2, 4),
(7, 3, 1),
(8, 3, 2),
(9, 3, 3),
(10, 3, 4);

-- tasks are created in orders on insert trigger
