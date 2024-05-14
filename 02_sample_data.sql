INSERT INTO users (role, first_name, last_name, email, phone_number) VALUES
('admin', 'John', 'Doe', 'john.doe@example.com', '1234567890'),
('admin', 'Jessica', 'Garcia', 'jessica.garcia@example.com', '5678901234'),
('admin', 'Christopher', 'Lopez', 'christopher.lopez@example.com', '6543210987'),
('basic', 'Susan', 'Hall', 'susan.hall@example.com', '9876543210'),
('basic', 'Sarah', 'Taylor', 'sarah.taylor@example.com', '3216549870'),
('basic', 'Jane', 'Smith', 'jane.smith@example.com', '0987654321'),
('basic', 'Michael', 'Johnson', 'michael.johnson@example.com', '5551234567'),
('basic', 'Emily', 'Brown', 'emily.brown@example.com', '9876543210'),
('basic', 'Daniel', 'Martinez', 'daniel.martinez@example.com', '4567890123'),
('basic', 'Christopher', 'Anderson', 'christopher.anderson@example.com', '7890123456'),
('basic', 'Amanda', 'Thomas', 'amanda.thomas@example.com', '6543210987'),
('basic', 'Matthew', 'Hernandez', 'matthew.hernandez@example.com', '2345678901'),
('basic', 'David', 'Young', 'david.young@example.com', '2109876543'),
('basic', 'Ashley', 'King', 'ashley.king@example.com', '8765432109'),
('basic', 'James', 'Lee', 'james.lee@example.com', '4321098765'),
('basic', 'Jennifer', 'Walker', 'jennifer.walker@example.com', '9012345678'),
('basic', 'Mary', 'Perez', 'mary.perez@example.com', '1234567890'),
('basic', 'Robert', 'Wright', 'robert.wright@example.com', '8901234567'),
('basic', 'Linda', 'Scott', 'linda.scott@example.com', '3456789012'),
('basic', 'John', 'Adams', 'john.adams@example.com', '6789012345');

INSERT INTO departments (id, name) VALUES
(1, 'Marketing'),
(2, 'Finance'),
(3, 'Human Resources'),
(4, 'Engineering'),
(5, 'Sales');

INSERT INTO employees (id, department_id, salary) VALUES
(1, 1, 60000.00),
(2, 2, 75000.00),
(3, 3, 55000.00),
(4, 4, 80000.00),
(5, 5, 70000.00);

INSERT INTO companies (id, name, nip) VALUES
(1, 'ABC Corporation', 1234567890),
(2, 'XYZ Ltd.', 9876543212),
(3, 'DEF Industries', 4567891234),
(4, 'GHI Enterprises', 3789123456);

INSERT INTO employees (user_id, company_id, role) VALUES
(1, 1, 60000.00),
(2, 2, 75000.00),
(3, 3, 55000.00),
(4, 4, 80000.00),
(5, 5, 70000.00);

INSERT INTO company_users (user_id, company_id, role) VALUES
(6, 1, 'owner'),
(7, 1, 'admin'),
(8, 1, 'basic'),
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

-- checkpoint

-- Website Development service

INSERT INTO services (id, name, description, price) VALUES
(1, 'Website Development', 'Comprehensive website development service including design, development, and deployment.', 5000.00);

INSERT INTO service_steps (id, name, description, service_id, department_id, input_definition) VALUES
(1, 'Design Consultation', 'Discuss design preferences and requirements with the client.', 1, 5, '{"preferences": {"type": "text", "description": "Client preferences and requirements"}}'),
(2, 'Wireframing', 'Create wireframes based on the design consultation.', 1, 4, '{"wireframes": {"type": "image", "description": "Wireframes"}}'),
(3, 'Frontend Development', 'Develop the frontend of the website based on the wireframes.', 1, 4, '{"code": {"type": "code", "description": "Frontend code"}}'),
(4, 'Backend Development', 'Develop the backend functionalities of the website.', 1, 4, '{"code": {"type": "code", "description": "Backend code"}}'),
(5, 'Testing & Quality Assurance', 'Test the website thoroughly to ensure functionality and quality.', 1, 3, '{"test_results": {"type": "text", "description": "Test results and feedback"}}'),
(6, 'Deployment & Launch', 'Deploy the website to the client server and launch it.', 1, 4, null),
(7, 'Issue an Invoice', null, 1, 2, '{"invoice": {"type": "file"}}');

INSERT INTO service_step_dependencies (service_step_id, depends_on) VALUES
(7, 6),
(6, 5),
(5, 4),
(4, 3),
(3, 2),
(2, 1);

-- Social Media Management service

INSERT INTO services (id, name, description, price) VALUES
(2, 'Social Media Management', 'Social media management service including content creation, scheduling, and analytics.', 2000.00);

INSERT INTO service_steps (id, name, description, service_id, department_id, input_definition) VALUES
(8, 'Client Onboarding', 'Onboard the client and gather necessary account access.', 2, 1, '{"login": {"type": "text"}, "password": {"type": "text"}}'),
(9, 'Content Creation', 'Create engaging content for social media platforms.', 2, 5, null),
(10, 'Scheduling', 'Schedule posts on various social media platforms.', 2, 5, null),
(11, 'Analytics & Reporting', 'Analyze social media performance and generate reports.', 2, 2, '{"spreadsheet_link": {"type": "text", "description": "Analytics report"}}');

INSERT INTO service_step_dependencies (service_step_id, depends_on) VALUES
(11, 10),
(10, 9),
(9, 8);

-- Search Engine Optimization (SEO) service

INSERT INTO services (id, name, description, price) VALUES
(3, 'Search Engine Optimization (SEO)', 'Search engine optimization service to improve website visibility and search rankings.', 3000.00);

INSERT INTO service_steps (id, name, description, service_id, department_id, input_definition) VALUES
(12, 'Website Audit', 'Conduct a comprehensive audit of the client website for SEO improvements.', 3, 4, '{"report": {"type": "file", "description": "Audit report"}}'),
(13, 'Keyword Research', 'Research and identify relevant keywords for the client industry.', 3, 1, '{"keyword_list":{"type": "file", "description": "Keyword list"}}'),
(14, 'On-Page Optimization', 'Optimize website content and structure for improved search rankings.', 3, 4, null),
(15, 'Off-Page Optimization', 'Implement strategies to improve website authority and backlinks.', 3, 4, null);

INSERT INTO service_step_dependencies (service_step_id, depends_on) VALUES
(14, 12),
(14, 13);

-- orders

INSERT INTO orders (service_id, company_id) VALUES
(1, 1),
(1, 1),
(1, 2),
(1, 3),
(2, 3),
(2, 4),
(3, 1),
(3, 2),
(3, 3),
(3, 4);

-- tasks are created in orders on insert trigger
