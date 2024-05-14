-- users

CREATE TABLE users (
    id INT PRIMARY KEY,
    role VARCHAR2(5) NOT NULL CHECK (role IN ('admin', 'basic')),
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100) NOT NULL,
    phone_number VARCHAR2(12)
);

-- departments

CREATE TABLE departments (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL
);

CREATE TABLE employees (
    id INT PRIMARY KEY REFERENCES users(id),
    department_id INT REFERENCES users(id) NOT NULL,
    salary NUMBER(10, 2) DEFAULT 0 NOT NULL
);

-- companies

CREATE TABLE companies (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    nip INT NOT NULL
);

CREATE TABLE company_users (
    user_id INT REFERENCES users(id),
    company_id INT REFERENCES companies(id),
    role VARCHAR2(5) NOT NULL CHECK (role IN ('owner', 'admin', 'basic')),

    PRIMARY KEY (user_id, company_id)
);

-- services

CREATE TABLE services (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    description VARCHAR2(2000),
    price NUMBER(10, 2) DEFAULT 0 NOT NULL
);

CREATE TABLE service_steps (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    description VARCHAR2(2000),
    service_id INT REFERENCES services(id),
    department_id INT REFERENCES departments(id) NOT NULL,
    input_definition CLOB CHECK (input_definition IS JSON)
);

CREATE TABLE service_step_dependencies (
    service_step_id INT REFERENCES service_steps(id),
    depends_on INT REFERENCES service_steps(id),
    PRIMARY KEY (service_step_id, depends_on)
);

-- orders

CREATE TABLE orders (
    id INT PRIMARY KEY,
    service_id INT REFERENCES services(id),
    company_id INT REFERENCES companies(id),
    created_at TIMESTAMP NOT NULL DEFAULT SYSTIMESTAMP
);

-- tasks

CREATE TABLE tasks (
    id INT PRIMARY KEY,
    service_step_id INT REFERENCES service_steps(id),
    status VARCHAR2(15) NOT NULL CHECK (status IN ('blocked', 'to_do', 'in_progress', 'hold', 'cancelled', 'failed', 'done')),
    status_changed_at TIMESTAMP,
    order_id INT REFERENCES orders(id),
    assignee INT REFERENCES users(id),
    input_data CLOB CHECK (input_data IS JSON)
);

CREATE OR REPLACE VIEW task_dependencies AS
SELECT
    t1.id AS task_id,
    t1.id AS dependent_task_id
FROM
    tasks t1
JOIN
    service_step_dependencies ssd ON t1.service_step_id = ssd.service_step_id
JOIN
    tasks t2 ON ssd.depends_on = t2.service_step_id
WHERE
    t1.order_id = t2.order_id;
