-- users

CREATE TABLE users (
    id INT PRIMARY KEY,
    role VARCHAR2(5) NOT NULL CHECK (role IN ('admin', 'basic')),
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100) NOT NULL,
    phone_number VARCHAR2(12)
);

CREATE SEQUENCE users_id_seq;

CREATE OR REPLACE TRIGGER users_on_insert
  BEFORE INSERT ON users
  FOR EACH ROW
BEGIN
  SELECT users_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

-- departments

CREATE TABLE departments (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL
);

CREATE SEQUENCE departments_id_seq;

CREATE OR REPLACE TRIGGER departments_on_insert
  BEFORE INSERT ON departments
  FOR EACH ROW
BEGIN
  SELECT departments_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

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

CREATE SEQUENCE companies_id_seq;

CREATE OR REPLACE TRIGGER companies_on_insert
  BEFORE INSERT ON companies
  FOR EACH ROW
BEGIN
  SELECT companies_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

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

CREATE SEQUENCE services_id_seq;

CREATE OR REPLACE TRIGGER services_on_insert
  BEFORE INSERT ON services
  FOR EACH ROW
BEGIN
  SELECT services_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

CREATE TABLE service_steps (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    description VARCHAR2(2000),
    department_id INT REFERENCES departments(id) NOT NULL,
    input_definition CLOB CHECK (input_definition IS JSON)
);

CREATE SEQUENCE service_steps_id_seq;

CREATE OR REPLACE TRIGGER service_steps_on_insert
  BEFORE INSERT ON service_steps
  FOR EACH ROW
BEGIN
  SELECT service_steps_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

CREATE TABLE service_step_dependencies (
    service_step_id INT REFERENCES service_steps(id),
    depends_on INT REFERENCES service_steps(id),
    PRIMARY KEY (service_step_id, depends_on)
);

CREATE TABLE service_assigned_steps (
    service_id INT REFERENCES services(id),
    service_step_id INT REFERENCES service_steps(id),
    PRIMARY KEY (service_id, service_step_id)
);

-- orders

CREATE TABLE orders (
    id INT PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    service_id INT REFERENCES services(id),
    company_id INT REFERENCES companies(id)
);

CREATE SEQUENCE orders_id_seq;

CREATE OR REPLACE TRIGGER orders_on_insert
  BEFORE INSERT ON orders
  FOR EACH ROW
BEGIN
  SELECT orders_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

-- tasks

CREATE TABLE tasks (
    id INT PRIMARY KEY,
    service_step_id INT REFERENCES service_steps(id),
    status VARCHAR2(15) NOT NULL CHECK (status IN ('blocked', 'to_do', 'in_progress', 'hold', 'cancelled', 'failed', 'done')),
    order_id INT REFERENCES orders(id),
    assignee INT REFERENCES users(id),
    input_data CLOB CHECK (input_data IS JSON)
);

CREATE SEQUENCE tasks_id_seq;

CREATE OR REPLACE TRIGGER tasks_on_insert
  BEFORE INSERT ON tasks
  FOR EACH ROW
BEGIN
  SELECT tasks_id_seq.nextval
  INTO :new.id
  FROM dual;
END;