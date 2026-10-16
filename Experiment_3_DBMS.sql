-- Experiment - 3 : Create an Employee–Department–Project schema. Insert at least 30 employees across 5 departments and 8 projects. Write SQL queries demonstrating selection, projection, aggregates, GROUP BY, HAVING, CASE expressions, and ORDER BY.

-- ============================================================
-- EXPERIMENT 3
-- Employee–Department–Project Database
-- ============================================================

CREATE DATABASE EmployeeManagement;
USE EmployeeManagement;

-- ============================================================
-- TABLE CREATION
-- ============================================================

-- Department Table
CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);

-- Employee Table
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    gender CHAR(1),
    salary DECIMAL(10, 2),
    hire_date DATE,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

-- Project Table
CREATE TABLE Project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    budget DECIMAL(12, 2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

-- Employee–Project Relationship
CREATE TABLE Employee_Project (
    emp_id INT,
    project_id INT,
    hours_worked INT,
    PRIMARY KEY (emp_id, project_id),
    FOREIGN KEY (emp_id) REFERENCES Employee(emp_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

-- ============================================================
-- DATA INSERTION
-- ============================================================

-- Departments
INSERT INTO Department (dept_id, dept_name, location)
VALUES
    (1, 'Engineering', 'Chandigarh'),
    (2, 'Human Resources', 'Jaipur'),
    (3, 'Accounts', 'Lucknow'),
    (4, 'Sales', 'Noida'),
    (5, 'Innovation', 'Gurugram');

-- Employees
INSERT INTO Employee
    (emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES
    (101, 'Aman Verma', 'M', 72000, '2021-02-12', 1),
    (102, 'Kriti Sharma', 'F', 69000, '2022-04-18', 1),
    (103, 'Rohit Singh', 'M', 84000, '2020-08-21', 1),
    (104, 'Pallavi Gupta', 'F', 76000, '2021-12-09', 1),
    (105, 'Nitin Malhotra', 'M', 93000, '2019-07-16', 1),
    (106, 'Ishita Jain', 'F', 66000, '2023-02-14', 1),
    (107, 'Varun Yadav', 'M', 57000, '2022-06-20', 2),
    (108, 'Radhika Soni', 'F', 63000, '2021-10-25', 2),
    (109, 'Kunal Arora', 'M', 59000, '2020-05-13', 2),
    (110, 'Muskan Bhatia', 'F', 68000, '2023-03-22', 2),
    (111, 'Deepak Joshi', 'M', 61000, '2022-09-05', 2),
    (112, 'Shalini Roy', 'F', 73000, '2019-12-19', 2),
    (113, 'Harsh Patel', 'M', 89000, '2020-02-27', 3),
    (114, 'Nandini Shah', 'F', 94000, '2019-09-17', 3),
    (115, 'Siddharth Rao', 'M', 78000, '2021-07-04', 3),
    (116, 'Tanvi Iyer', 'F', 86000, '2022-11-23', 3),
    (117, 'Gaurav Das', 'M', 74000, '2023-04-12', 3),
    (118, 'Priti Nair', 'F', 91000, '2020-12-11', 3),
    (119, 'Abhishek Mehta', 'M', 71000, '2021-03-03', 4),
    (120, 'Simran Gill', 'F', 67000, '2022-05-19', 4),
    (121, 'Rajat Bansal', 'M', 75000, '2020-10-14', 4),
    (122, 'Ayesha Khan', 'F', 82000, '2019-08-08', 4),
    (123, 'Tarun Sethi', 'M', 70000, '2023-02-06', 4),
    (124, 'Megha Arora', 'F', 79000, '2021-12-21', 4),
    (125, 'Yuvraj Kapoor', 'M', 99000, '2018-06-24', 5),
    (126, 'Anjali Mishra', 'F', 92000, '2020-04-20', 5),
    (127, 'Sameer Nair', 'M', 88000, '2021-11-12', 5),
    (128, 'Divya Das', 'F', 95000, '2019-12-02', 5),
    (129, 'Akash Thakur', 'M', 80000, '2022-08-16', 5),
    (130, 'Ritika Kapoor', 'F', 97000, '2023-03-07', 5);

-- Projects
INSERT INTO Project
    (project_id, project_name, budget, dept_id)
VALUES
    (201, 'Smart Inventory System', 520000, 1),
    (202, 'Network Upgrade', 780000, 1),
    (203, 'Staff Development', 270000, 2),
    (204, 'Budget Planning', 620000, 3),
    (205, 'Customer Outreach', 470000, 4),
    (206, 'Sales Forecasting', 370000, 4),
    (207, 'Predictive Analytics', 920000, 5),
    (208, 'Cybersecurity Platform', 1050000, 5);

-- Employee–Project Assignments
INSERT INTO Employee_Project
    (emp_id, project_id, hours_worked)
VALUES
    (101, 201, 120),
    (102, 201, 100),
    (103, 202, 150),
    (104, 202, 110),
    (105, 201, 130),
    (106, 202, 90),
    (107, 203, 100),
    (108, 203, 120),
    (109, 203, 80),
    (110, 203, 110),
    (111, 203, 90),
    (112, 203, 130),
    (113, 204, 140),
    (114, 204, 150),
    (115, 204, 120),
    (116, 204, 135),
    (117, 204, 100),
    (118, 204, 145),
    (119, 205, 110),
    (120, 205, 100),
    (121, 206, 120),
    (122, 205, 140),
    (123, 206, 90),
    (124, 206, 130),
    (125, 207, 160),
    (126, 207, 140),
    (127, 208, 150),
    (128, 208, 160),
    (129, 207, 120),
    (130, 208, 135);

-- ============================================================
-- SQL QUERIES
-- ============================================================

-- 1. Selection
SELECT *
FROM Employee
WHERE salary > 80000;

-- 2. Projection
SELECT emp_name, salary
FROM Employee;

-- 3. Aggregate Functions
SELECT
    COUNT(*) AS total_employees,
    SUM(salary) AS total_salary,
    AVG(salary) AS average_salary,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary
FROM Employee;

-- 4. GROUP BY
SELECT
    dept_id,
    COUNT(*) AS employee_count
FROM Employee
GROUP BY dept_id;

-- 5. GROUP BY with JOIN
SELECT
    d.dept_name,
    AVG(e.salary) AS average_salary
FROM Department AS d
JOIN Employee AS e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- 6. HAVING
SELECT
    d.dept_name,
    AVG(e.salary) AS average_salary
FROM Department AS d
JOIN Employee AS e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 75000;

-- 7. CASE Expression
SELECT
    emp_name,
    salary,
    CASE
        WHEN salary >= 90000 THEN 'High Salary'
        WHEN salary >= 70000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM Employee;

-- 8. ORDER BY
SELECT
    emp_id,
    emp_name,
    salary
FROM Employee
ORDER BY salary DESC;

-- 9. Complete Employee–Department Report
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name,
    e.salary
FROM Employee AS e
JOIN Department AS d
    ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.salary DESC;

-- 10. Project Details
SELECT
    p.project_name,
    d.dept_name,
    p.budget
FROM Project AS p
JOIN Department AS d
    ON p.dept_id = d.dept_id
ORDER BY p.budget DESC;

-- 11. Employees Working on Projects
SELECT
    e.emp_name,
    p.project_name,
    ep.hours_worked
FROM Employee_Project AS ep
JOIN Employee AS e
    ON ep.emp_id = e.emp_id
JOIN Project AS p
    ON ep.project_id = p.project_id
ORDER BY ep.hours_worked DESC;
