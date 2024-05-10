CREATE TABLE department (
    id INT PRIMARY KEY,
    name VARCHAR2(255)
);

CREATE TABLE employees (
    id INT PRIMARY KEY,
    role VARCHAR2(50),
    department_id INT,
    salary NUMBER,
    FOREIGN KEY (department_id) REFERENCES department(id),
    CONSTRAINT role_chk CHECK (role IN ('CEO', 'Finance', 'Sales', 'Development', 'IT', 'Legal', 'HR', 'Marketing'))
);

CREATE TABLE companies (
    id INT PRIMARY KEY,
    name VARCHAR2(255),
    nip INT
);

CREATE TABLE clients (
    id INT PRIMARY KEY,
    company_id INT,
    role VARCHAR2(50),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    CONSTRAINT role_chk_clients CHECK (role IN ('Business Partner', 'Supplier', 'Distributor', 'Reseller', 'Consumer'))
);

CREATE TABLE services (
    id INT PRIMARY KEY,
    name VARCHAR2(255),
    price NUMBER,
    last_step INT
);

CREATE TABLE orders (
    id INT PRIMARY KEY,
    name VARCHAR2(255),
    service_id INT,
    company_id INT,
    FOREIGN KEY (service_id) REFERENCES services(id),
    FOREIGN KEY (company_id) REFERENCES companies(id)
);

CREATE TABLE service_steps (
    id INT PRIMARY KEY,
    name VARCHAR2(255),
    description VARCHAR2(255),
    form_definition CLOB,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES department(id)
);

CREATE TABLE service_step_dependencies (
    service_step_id INT,
    depends_on INT,
    PRIMARY KEY (service_step_id, depends_on),
    FOREIGN KEY (service_step_id) REFERENCES service_steps(id),
    FOREIGN KEY (depends_on) REFERENCES service_steps(id)
);

CREATE TABLE service_assigned_steps (
    service_id INT,
    service_step INT,
    FOREIGN KEY (service_id) REFERENCES services(id),
    FOREIGN KEY (service_step) REFERENCES service_steps(id)
);

CREATE TABLE tasks (
    id INT PRIMARY KEY,
    service_step_id INT,
    status VARCHAR2(50),
    order_id INT,
    assignee INT,
    form_data CLOB,
    FOREIGN KEY (service_step_id) REFERENCES service_steps(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (assignee) REFERENCES users(id),
    CONSTRAINT status_chk CHECK (status IN ('Pending', 'In Progress', 'On Hold', 'Completed', 'Cancelled', 'Failed', 'Reviewed', 'Approved'))
);

CREATE TABLE users (
    id INT PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100),
    phone_number VARCHAR2(12)
);