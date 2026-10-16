-- ============================================================
-- EXPERIMENT - 6
-- AIM:
-- Create a stored procedure transfer_employee(emp_id, new_dept_id)
-- with validation and error handling. Implement triggers for salary
-- validation and audit logging. Test normal cases and edge cases.
--
-- DATABASE: EmployeeManagement (created in Experiment 3)
-- ============================================================

USE EmployeeManagement;

-- ============================================================
-- 1. STORED PROCEDURE: transfer_employee
-- Validates employee and department, prevents transfers to the
-- employee's current department, and rolls back on errors.
-- ============================================================

DROP PROCEDURE IF EXISTS transfer_employee;

DELIMITER //

CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_employee_count INT DEFAULT 0;
    DECLARE v_department_count INT DEFAULT 0;
    DECLARE v_current_dept INT DEFAULT NULL;

    -- Roll back and return SQL errors to the caller.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*)
    INTO v_employee_count
    FROM Employee
    WHERE emp_id = p_emp_id;

    IF v_employee_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Employee does not exist.';
    END IF;

    SELECT COUNT(*)
    INTO v_department_count
    FROM Department
    WHERE dept_id = p_new_dept_id;

    IF v_department_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Department does not exist.';
    END IF;

    SELECT dept_id
    INTO v_current_dept
    FROM Employee
    WHERE emp_id = p_emp_id
    FOR UPDATE;

    IF v_current_dept = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Employee is already in this department.';
    END IF;

    UPDATE Employee
    SET dept_id = p_new_dept_id
    WHERE emp_id = p_emp_id;

    COMMIT;

    SELECT 'Employee transferred successfully.' AS message;
END //

DELIMITER ;


-- ============================================================
-- 2. CHECK EMPLOYEE'S CURRENT DEPARTMENT
-- ============================================================
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee AS e
INNER JOIN Department AS d
    ON e.dept_id = d.dept_id
WHERE e.emp_id = 101;


-- ============================================================
-- 3. TEST SUCCESSFUL TRANSFER
-- Example: transfer employee 101 to department 3.
-- ============================================================
CALL transfer_employee(101, 3);

-- Verify the transfer
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee AS e
INNER JOIN Department AS d
    ON e.dept_id = d.dept_id
WHERE e.emp_id = 101;


-- ============================================================
-- 4. EDGE-CASE TESTS FOR THE PROCEDURE
-- Run each CALL separately because invalid cases raise SQL errors.
-- Expected outcomes are documented in comments.
-- ============================================================

-- Employee does not exist: expected error.
-- CALL transfer_employee(999, 3);

-- Department does not exist: expected error.
-- CALL transfer_employee(101, 99);

-- Employee is already in the requested department:
-- First check employee 101's current dept_id, then pass that ID.
-- Example if employee 101 is in department 3:
-- CALL transfer_employee(101, 3);

-- NULL employee ID or department ID should not transfer a record.
-- CALL transfer_employee(NULL, 3);
-- CALL transfer_employee(101, NULL);


-- ============================================================
-- 5. SALARY AUDIT TABLE
-- Stores old and new salaries whenever salary changes.
-- ============================================================
CREATE TABLE IF NOT EXISTS Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(30)
);


-- ============================================================
-- 6. SALARY VALIDATION TRIGGER FOR INSERT
-- Salary must not be NULL and must be at least 15000.
-- ============================================================
DROP TRIGGER IF EXISTS validate_employee_salary;

DELIMITER //

CREATE TRIGGER validate_employee_salary
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary cannot be NULL and must be at least 15000';
    END IF;
END //

DELIMITER ;


-- ============================================================
-- 7. SALARY VALIDATION TRIGGER FOR UPDATE
-- Prevents an existing employee salary from being set below 15000
-- or to NULL.
-- ============================================================
DROP TRIGGER IF EXISTS validate_employee_salary_update;

DELIMITER //

CREATE TRIGGER validate_employee_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary cannot be NULL and must be at least 15000';
    END IF;
END //

DELIMITER ;


-- ============================================================
-- 8. AUDIT LOGGING TRIGGER
-- Adds an audit row only when the salary actually changes.
-- ============================================================
DROP TRIGGER IF EXISTS salary_audit_trigger;

DELIMITER //

CREATE TRIGGER salary_audit_trigger
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NOT (OLD.salary <=> NEW.salary) THEN
        INSERT INTO Salary_Audit
            (emp_id, old_salary, new_salary, action)
        VALUES
            (NEW.emp_id, OLD.salary, NEW.salary, 'SALARY UPDATED');
    END IF;
END //

DELIMITER ;


-- ============================================================
-- 9. TEST VALID SALARY INSERT
-- Uses employee ID 131. If this ID already exists, choose another ID.
-- ============================================================
INSERT INTO Employee
    (emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES
    (131, 'Test Employee', 'M', 30000, '2026-09-25', 1);

SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id = 131;


-- ============================================================
-- 10. TEST INVALID SALARY INSERTS
-- These are expected to fail; run each separately.
-- ============================================================

-- Salary below minimum: expected validation error.
-- INSERT INTO Employee
--     (emp_id, emp_name, gender, salary, hire_date, dept_id)
-- VALUES
--     (132, 'Low Salary Test', 'F', 10000, '2026-09-25', 1);

-- NULL salary: expected validation error.
-- INSERT INTO Employee
--     (emp_id, emp_name, gender, salary, hire_date, dept_id)
-- VALUES
--     (133, 'Null Salary Test', 'F', NULL, '2026-09-25', 1);


-- ============================================================
-- 11. TEST INVALID SALARY UPDATE
-- Expected to fail; salary should remain unchanged.
-- ============================================================
-- UPDATE Employee
-- SET salary = 5000
-- WHERE emp_id = 131;

SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id = 131;


-- ============================================================
-- 12. TEST AUDIT LOGGING
-- Each actual salary change creates an audit row.
-- ============================================================
UPDATE Employee
SET salary = 35000
WHERE emp_id = 131;

UPDATE Employee
SET salary = 40000
WHERE emp_id = 131;

SELECT
    audit_id,
    emp_id,
    old_salary,
    new_salary,
    changed_at,
    action
FROM Salary_Audit
WHERE emp_id = 131
ORDER BY audit_id;


-- ============================================================
-- 13. EDGE CASE: SALARY UNCHANGED
-- This should not create a new audit row.
-- ============================================================
UPDATE Employee
SET salary = 40000
WHERE emp_id = 131;

SELECT *
FROM Salary_Audit
WHERE emp_id = 131
ORDER BY audit_id;


-- ============================================================
-- 14. CHECK CREATED TRIGGERS AND PROCEDURE
-- ============================================================
SHOW TRIGGERS;

SHOW PROCEDURE STATUS
WHERE Db = DATABASE();
