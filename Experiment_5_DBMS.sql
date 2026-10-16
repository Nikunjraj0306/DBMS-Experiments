-- ============================================================
-- EXPERIMENT - 5
-- AIM:
-- Create SQL views for department salary summary and employee
-- hierarchy. Test updatability of views. Implement a recursive
-- CTE to display employee reporting chains.
--
-- DATABASE: EmployeeManagement (created in Experiment 3)
-- ============================================================

USE EmployeeManagement;

-- ============================================================
-- 1. DEPARTMENT SALARY SUMMARY VIEW
-- Displays employee count and salary statistics for each department.
-- ============================================================
CREATE OR REPLACE VIEW Department_Salary_Summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    SUM(e.salary) AS total_salary,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS highest_salary,
    MIN(e.salary) AS lowest_salary
FROM Department AS d
LEFT JOIN Employee AS e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Display the view
SELECT *
FROM Department_Salary_Summary;


-- ============================================================
-- 2. QUERY THE DEPARTMENT SALARY SUMMARY VIEW
-- Find departments whose average salary is greater than 75000.
-- ============================================================
SELECT
    dept_name,
    average_salary
FROM Department_Salary_Summary
WHERE average_salary > 75000;


-- ============================================================
-- 3. ADD EMPLOYEE HIERARCHY SUPPORT
-- Run this section only once. If manager_id already exists,
-- skip the ALTER TABLE statements.
-- ============================================================
ALTER TABLE Employee
    ADD COLUMN manager_id INT NULL;

ALTER TABLE Employee
    ADD CONSTRAINT fk_employee_manager
    FOREIGN KEY (manager_id) REFERENCES Employee(emp_id);


-- ============================================================
-- 4. INSERT / SET EMPLOYEE REPORTING RELATIONSHIPS
-- Root managers have manager_id = NULL.
-- These IDs match the Employee IDs from Experiment 3.
-- ============================================================

-- Root managers
UPDATE Employee
SET manager_id = NULL
WHERE emp_id IN (105, 112, 114, 122, 125);

-- Engineering department (dept_id = 1)
UPDATE Employee SET manager_id = 105 WHERE emp_id IN (103, 104);
UPDATE Employee SET manager_id = 103 WHERE emp_id IN (101, 102);
UPDATE Employee SET manager_id = 104 WHERE emp_id = 106;

-- Human Resources department (dept_id = 2)
UPDATE Employee SET manager_id = 112 WHERE emp_id IN (107, 108);
UPDATE Employee SET manager_id = 107 WHERE emp_id = 109;
UPDATE Employee SET manager_id = 108 WHERE emp_id IN (110, 111);

-- Accounts department (dept_id = 3)
UPDATE Employee SET manager_id = 114 WHERE emp_id IN (115, 116);
UPDATE Employee SET manager_id = 115 WHERE emp_id = 117;
UPDATE Employee SET manager_id = 116 WHERE emp_id = 118;

-- Sales department (dept_id = 4)
UPDATE Employee SET manager_id = 122 WHERE emp_id IN (119, 120);
UPDATE Employee SET manager_id = 119 WHERE emp_id = 121;
UPDATE Employee SET manager_id = 120 WHERE emp_id IN (123, 124);

-- Innovation department (dept_id = 5)
UPDATE Employee SET manager_id = 125 WHERE emp_id IN (126, 127, 128);
UPDATE Employee SET manager_id = 126 WHERE emp_id = 129;
UPDATE Employee SET manager_id = 128 WHERE emp_id = 130;


-- ============================================================
-- 5. EMPLOYEE HIERARCHY VIEW
-- Shows each employee and their manager, if assigned.
-- ============================================================
CREATE OR REPLACE VIEW Employee_Hierarchy AS
SELECT
    e.emp_id,
    e.emp_name AS employee_name,
    e.manager_id,
    m.emp_name AS manager_name,
    e.salary,
    e.dept_id
FROM Employee AS e
LEFT JOIN Employee AS m
    ON e.manager_id = m.emp_id;

-- Display employee hierarchy
SELECT *
FROM Employee_Hierarchy
ORDER BY dept_id, manager_id, emp_id;


-- ============================================================
-- 6. TEST UPDATABILITY OF A SIMPLE VIEW
-- A simple view based on one table is generally updatable.
-- ============================================================
CREATE OR REPLACE VIEW Employee_Basic AS
SELECT
    emp_id,
    emp_name,
    salary,
    dept_id
FROM Employee;

-- View an employee record
SELECT *
FROM Employee_Basic
WHERE emp_id = 101;

-- Update salary through the view
-- This changes the corresponding row in the Employee table.
UPDATE Employee_Basic
SET salary = 78000
WHERE emp_id = 101;

-- Verify the update in the base table
SELECT *
FROM Employee
WHERE emp_id = 101;


-- ============================================================
-- 7. TEST NON-UPDATABILITY OF THE AGGREGATE VIEW
-- This UPDATE is expected to fail because the view contains
-- aggregate functions and GROUP BY.
-- Run separately if you want to observe the expected error.
-- ============================================================
-- UPDATE Department_Salary_Summary
-- SET average_salary = 80000
-- WHERE dept_id = 1;


-- ============================================================
-- 8. RECURSIVE CTE: DISPLAY ALL REPORTING CHAINS
-- Starts from top-level managers and recursively adds employees
-- reporting to each manager.
-- Requires MySQL 8.0 or later.
-- ============================================================
WITH RECURSIVE EmployeeChain AS (
    -- Anchor member: top-level managers
    SELECT
        emp_id,
        emp_name,
        manager_id,
        0 AS level,
        CAST(emp_name AS CHAR(1000)) AS reporting_chain
    FROM Employee
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member: employees reporting to the current level
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        ec.level + 1,
        CONCAT(ec.reporting_chain, ' -> ', e.emp_name)
    FROM Employee AS e
    INNER JOIN EmployeeChain AS ec
        ON e.manager_id = ec.emp_id
)
SELECT
    emp_id,
    emp_name,
    manager_id,
    level,
    reporting_chain
FROM EmployeeChain
ORDER BY reporting_chain;


-- ============================================================
-- 9. RECURSIVE CTE: REPORTING CHAIN FOR ONE EMPLOYEE
-- Starts with employee 101 and follows their managers upward.
-- ============================================================
WITH RECURSIVE ReportingChain AS (
    -- Anchor member: selected employee
    SELECT
        emp_id,
        emp_name,
        manager_id,
        0 AS level
    FROM Employee
    WHERE emp_id = 101

    UNION ALL

    -- Recursive member: move upward to the employee's manager
    SELECT
        m.emp_id,
        m.emp_name,
        m.manager_id,
        rc.level + 1
    FROM Employee AS m
    INNER JOIN ReportingChain AS rc
        ON m.emp_id = rc.manager_id
)
SELECT
    emp_id,
    emp_name,
    manager_id,
    level
FROM ReportingChain
ORDER BY level;
