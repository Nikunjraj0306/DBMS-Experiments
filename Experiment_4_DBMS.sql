-- ============================================================
-- EXPERIMENT - 4
-- AIM:
-- Using the Employee schema, write queries with INNER JOIN,
-- LEFT JOIN, self-join, 3-way join, correlated subqueries,
-- EXISTS, and simulated INTERSECT and EXCEPT.
-- Compare execution plans using EXPLAIN.
--
-- DATABASE: EmployeeManagement (created in Experiment 3)
-- ============================================================

USE EmployeeManagement;

-- ============================================================
-- 1. INNER JOIN
-- Display employees with their department names.
-- ============================================================
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee AS e
INNER JOIN Department AS d
    ON e.dept_id = d.dept_id;


-- ============================================================
-- 2. LEFT JOIN
-- Display all departments, including departments with no employees.
-- ============================================================
SELECT
    d.dept_id,
    d.dept_name,
    e.emp_name
FROM Department AS d
LEFT JOIN Employee AS e
    ON d.dept_id = e.dept_id;


-- ============================================================
-- 3. SELF JOIN
-- Display pairs of employees working in the same department.
-- The emp_id condition avoids duplicate pairs and self-pairing.
-- ============================================================
SELECT
    e1.emp_name AS Employee1,
    e2.emp_name AS Employee2,
    e1.dept_id
FROM Employee AS e1
INNER JOIN Employee AS e2
    ON e1.dept_id = e2.dept_id
   AND e1.emp_id < e2.emp_id;


-- ============================================================
-- 4. THREE-WAY JOIN
-- Display employees, their departments, and projects belonging
-- to the same department.
-- ============================================================
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name
FROM Employee AS e
INNER JOIN Department AS d
    ON e.dept_id = d.dept_id
INNER JOIN Project AS p
    ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;


-- ============================================================
-- 5. EMPLOYEE-PROJECT JOIN
-- Display employees and the projects they are assigned to.
-- This joins four tables to include department information too.
-- ============================================================
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name,
    ep.hours_worked
FROM Employee AS e
INNER JOIN Department AS d
    ON e.dept_id = d.dept_id
INNER JOIN Employee_Project AS ep
    ON e.emp_id = ep.emp_id
INNER JOIN Project AS p
    ON ep.project_id = p.project_id
ORDER BY ep.hours_worked DESC;


-- ============================================================
-- 6. CORRELATED SUBQUERY
-- Find employees whose salary is greater than their department's
-- average salary.
-- ============================================================
SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    e.dept_id
FROM Employee AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee AS e2
    WHERE e2.dept_id = e.dept_id
);


-- ============================================================
-- 7. EXISTS
-- Find employees who are assigned to at least one project.
-- ============================================================
SELECT
    e.emp_id,
    e.emp_name
FROM Employee AS e
WHERE EXISTS (
    SELECT 1
    FROM Employee_Project AS ep
    WHERE ep.emp_id = e.emp_id
);


-- ============================================================
-- 8. SIMULATED INTERSECT
-- Find employees in department 1 who are assigned to project 201.
-- EXISTS simulates the intersection of these two conditions.
-- ============================================================
SELECT
    e.emp_id,
    e.emp_name
FROM Employee AS e
WHERE e.dept_id = 1
  AND EXISTS (
      SELECT 1
      FROM Employee_Project AS ep
      WHERE ep.emp_id = e.emp_id
        AND ep.project_id = 201
  );


-- ============================================================
-- 9. SIMULATED EXCEPT
-- Find employees in department 1 who are NOT assigned to project 201.
-- NOT EXISTS simulates the EXCEPT operation.
-- ============================================================
SELECT
    e.emp_id,
    e.emp_name
FROM Employee AS e
WHERE e.dept_id = 1
  AND NOT EXISTS (
      SELECT 1
      FROM Employee_Project AS ep
      WHERE ep.emp_id = e.emp_id
        AND ep.project_id = 201
  );


-- ============================================================
-- 10. COMPARE EXECUTION PLANS USING EXPLAIN
-- Run each EXPLAIN statement separately to inspect its execution plan.
-- MySQL EXPLAIN output can vary by version and available indexes.
-- ============================================================

-- EXPLAIN: INNER JOIN
EXPLAIN
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee AS e
INNER JOIN Department AS d
    ON e.dept_id = d.dept_id;


-- EXPLAIN: LEFT JOIN
EXPLAIN
SELECT
    d.dept_name,
    e.emp_name
FROM Department AS d
LEFT JOIN Employee AS e
    ON d.dept_id = e.dept_id;


-- EXPLAIN: SELF JOIN
EXPLAIN
SELECT
    e1.emp_name AS Employee1,
    e2.emp_name AS Employee2,
    e1.dept_id
FROM Employee AS e1
INNER JOIN Employee AS e2
    ON e1.dept_id = e2.dept_id
   AND e1.emp_id < e2.emp_id;


-- EXPLAIN: THREE-WAY JOIN
EXPLAIN
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name
FROM Employee AS e
INNER JOIN Department AS d
    ON e.dept_id = d.dept_id
INNER JOIN Project AS p
    ON d.dept_id = p.dept_id;


-- EXPLAIN: CORRELATED SUBQUERY
EXPLAIN
SELECT
    e.emp_name,
    e.salary
FROM Employee AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee AS e2
    WHERE e2.dept_id = e.dept_id
);


-- EXPLAIN: EXISTS
EXPLAIN
SELECT
    e.emp_id,
    e.emp_name
FROM Employee AS e
WHERE EXISTS (
    SELECT 1
    FROM Employee_Project AS ep
    WHERE ep.emp_id = e.emp_id
);
