CREATE DATABASE employee_db;
USE employee_db;

CREATE TABLE department (
    dept_id INT NOT NULL,
    dept_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100),
    PRIMARY KEY (dept_id)
);

CREATE TABLE job_profile (
    job_id INT NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    dept_id INT,
    PRIMARY KEY (job_id),
    CONSTRAINT fk_jobprofile_department
        FOREIGN KEY (dept_id)
        REFERENCES department(dept_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE employee (
    employee_id INT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone_no VARCHAR(15),
	CHECK (phone_no REGEXP '^[0-9]+$'),
    hire_date DATE NOT NULL,
    salary INT,
    PRIMARY KEY (employee_id)
);

CREATE TABLE job_history (
    job_history_id INT NOT NULL,
    employee_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    job_id INT NOT NULL,
    PRIMARY KEY (job_history_id),
    CONSTRAINT fk_jobhistory_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_jobhistory_job
        FOREIGN KEY (job_id)
        REFERENCES job_profile(job_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


INSERT INTO department (dept_id, dept_name, city, country)
VALUES 
(1, 'IT', 'New York', 'USA'),
(2, 'HR', 'Chicago', 'USA'),
(3, 'Finance', 'London', 'UK');

INSERT INTO job_profile (job_id, job_title, dept_id)
VALUES
(101, 'Software Developer', 1),
(102, 'System Analyst', 1),
(201, 'HR Manager', 2),
(301, 'Accountant', 3);

INSERT INTO employee 
(employee_id, first_name, last_name, email, phone_no, hire_date, salary)
VALUES
(1001, 'John', 'Smith', 'john.smith@email.com', '0712345678', '2022-01-15', 55000),
(1002, 'Sarah', 'Johnson', 'sarah.j@email.com', '0723456789', '2021-06-10', 62000),
(1003, 'David', 'Brown', 'david.b@email.com', '0734567890', '2020-03-20', 50000),
(1004, 'Emma', 'Wilson', 'emma.w@email.com', '0745678901', '2019-11-05', 70000);

INSERT INTO job_history
(job_history_id, employee_id, start_date, end_date, job_id)
VALUES
(1, 1001, '2022-01-15', '2023-01-15', 102),
(2, 1002, '2021-06-10', '2022-12-31', 101),
(3, 1003, '2020-03-20', NULL, 201),
(4, 1001, '2023-01-15', NULL, 102),
(5, 1004, '2021-08-10', NULL, 301);

-- Find the employee with the highest salary
SELECT first_name, last_name, salary
FROM employee
WHERE salary = (SELECT MAX(salary) FROM employee);

-- Find the second highest salary
SELECT MAX(salary) AS second_highest_salary
FROM employee
WHERE salary < (SELECT MAX(salary) FROM employee);

-- Find employees hired after 2021
SELECT employee_id, first_name, last_name, hire_date
FROM employee
WHERE hire_date > '2021-12-31';

-- List employees along with their department and job title
SELECT e.employee_id, e.first_name, e.last_name,
       j.job_title, d.dept_name
FROM employee e
JOIN job_history jh ON e.employee_id = jh.employee_id
JOIN job_profile j ON jh.job_id = j.job_id
JOIN department d ON j.dept_id = d.dept_id
WHERE jh.start_date = (
        SELECT MAX(jh2.start_date)
        FROM job_history jh2
        WHERE jh2.employee_id = jh.employee_id
);

-- Find the total number of jobs held by each employee
SELECT e.employee_id, e.first_name, e.last_name,
       COUNT(jh.job_id) AS total_jobs
FROM employee e
JOIN job_history jh ON e.employee_id = jh.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name;

-- Find employees who currently hold a job (end_date is NULL)
SELECT e.employee_id, e.first_name, e.last_name, j.job_title
FROM employee e
JOIN job_history jh ON e.employee_id = jh.employee_id
JOIN job_profile j ON jh.job_id = j.job_id
WHERE jh.end_date IS NULL;

-- Find the average salary of employees in each department
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM employee e
JOIN job_history jh 
    ON e.employee_id = jh.employee_id
JOIN job_profile j 
    ON jh.job_id = j.job_id
JOIN department d 
    ON j.dept_id = d.dept_id
WHERE jh.start_date = (
        SELECT MAX(jh2.start_date)
        FROM job_history jh2
        WHERE jh2.employee_id = jh.employee_id
)
GROUP BY d.dept_name;

-- Find the number of employees in each department
SELECT d.dept_name, COUNT(DISTINCT e.employee_id) AS employee_count
FROM employee e
JOIN job_history jh 
    ON e.employee_id = jh.employee_id
JOIN job_profile j 
    ON jh.job_id = j.job_id
JOIN department d 
    ON j.dept_id = d.dept_id
GROUP BY d.dept_name;

-- Rank employees by salary (highest first)
SELECT employee_id, first_name, last_name, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employee;

-- Rank employees within each department
SELECT DISTINCT e.employee_id, d.dept_name, e.first_name, e.salary,
       RANK() OVER (PARTITION BY d.dept_name ORDER BY e.salary DESC) AS dept_rank
FROM employee e
JOIN job_history jh ON e.employee_id = jh.employee_id
JOIN job_profile j ON jh.job_id = j.job_id
JOIN department d ON j.dept_id = d.dept_id;
