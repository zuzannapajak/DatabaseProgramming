-- users

CREATE TABLE users (
    id INT PRIMARY KEY,
    role VARCHAR2(5) NOT NULL CHECK (role IN ('admin', 'basic')),
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100) NOT NULL UNIQUE,
    phone_number VARCHAR2(12) UNIQUE
);

CREATE INDEX idx_users_email ON users (email);

CREATE SEQUENCE users_id_seq
  START WITH 100
  INCREMENT BY 1;

-- departments

CREATE TABLE departments (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL
);

CREATE SEQUENCE departments_id_seq
  START WITH 100
  INCREMENT BY 1;

CREATE TABLE employees (
    user_id INT PRIMARY KEY REFERENCES users(id),
    department_id INT REFERENCES users(id) NOT NULL,
    salary NUMBER(10, 2) DEFAULT 0 NOT NULL
);

-- companies

CREATE TABLE companies (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    nip INT NOT NULL UNIQUE
);

CREATE SEQUENCE companies_id_seq
  START WITH 100
  INCREMENT BY 1;

CREATE TABLE company_users (
    user_id INT REFERENCES users(id) NOT NULL,
    company_id INT REFERENCES companies(id) NOT NULL,
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

CREATE SEQUENCE services_id_seq
  START WITH 100
  INCREMENT BY 1;

CREATE TABLE service_steps (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    description VARCHAR2(2000),
    department_id INT REFERENCES departments(id) NOT NULL,
    input_definition CLOB CHECK (input_definition IS JSON)
);

CREATE SEQUENCE service_steps_id_seq
  START WITH 100
  INCREMENT BY 1;

CREATE TABLE service_nodes (
    id INT PRIMARY KEY,
    service_id INT REFERENCES services(id) NOT NULL,
    service_step_id INT REFERENCES service_steps(id) NOT NULL
);

CREATE SEQUENCE service_nodes_id_seq
  START WITH 100
  INCREMENT BY 1;

CREATE TABLE service_node_dependencies (
    dependent_node_id INT REFERENCES service_nodes(id) NOT NULL,
    dependency_node_id INT REFERENCES service_nodes(id) NOT NULL,
    PRIMARY KEY (dependent_node_id, dependency_node_id)
);

-- orders

CREATE TABLE orders (
    id INT PRIMARY KEY,
    service_id INT REFERENCES services(id),
    company_id INT REFERENCES companies(id),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE INDEX idx_orders_company_id ON orders (company_id);

CREATE SEQUENCE orders_id_seq
  START WITH 100
  INCREMENT BY 1;

-- tasks

CREATE TABLE tasks (
    id INT PRIMARY KEY,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    service_node_id INT REFERENCES service_nodes(id) NOT NULL,
    status VARCHAR2(15) NOT NULL CHECK (status IN ('to_do', 'in_progress', 'hold', 'cancelled', 'done')),
    status_changed_at TIMESTAMP,
    order_id INT REFERENCES orders(id) NOT NULL,
    assignee INT REFERENCES users(id),
    input_data CLOB CHECK (input_data IS JSON)
);

CREATE INDEX idx_tasks_order_id ON tasks (order_id);

CREATE SEQUENCE tasks_id_seq
  START WITH 100
  INCREMENT BY 1;
