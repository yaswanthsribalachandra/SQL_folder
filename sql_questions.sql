-- ============================================================
--  SQL INTERVIEW QUESTIONS & ANSWERS
--  Topics: SELECT, Filtering, Aggregations, Joins, Subqueries,
--          Window Functions, Nth Row, Indexing, and More
-- ============================================================

-- ============================================================
-- SETUP: Sample Tables used throughout this file
-- ============================================================

CREATE TABLE employees (
    emp_id    INT PRIMARY KEY,
    name      VARCHAR(100),
    dept_id   INT,
    salary    DECIMAL(10,2),
    manager_id INT,
    hire_date DATE
);

CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(100),
    location  VARCHAR(100)
);

CREATE TABLE orders (
    order_id   INT PRIMARY KEY,
    customer_id INT,
    amount     DECIMAL(10,2),
    order_date DATE
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name        VARCHAR(100),
    city        VARCHAR(100)
);

-- ============================================================
-- SECTION 1: BASIC SELECT & FILTERING
-- ============================================================

-- Q1: Fetch all employees from department 10.
SELECT * FROM employees WHERE dept_id = 10;

-- Q2: List employees hired in the last 90 days.
SELECT * FROM employees WHERE hire_date >= CURRENT_DATE - INTERVAL '90 days';

-- Q3: Find employees whose name starts with 'A'.
SELECT * FROM employees WHERE name LIKE 'A%';

-- Q4: Get distinct department IDs from employees table.
SELECT DISTINCT dept_id FROM employees;

-- Q5: List employees ordered by salary descending, then by name ascending.
SELECT * FROM employees ORDER BY salary DESC, name ASC;

-- ============================================================
-- SECTION 2: AGGREGATIONS & GROUP BY
-- ============================================================

-- Q6: Find the total salary paid per department.
SELECT dept_id, SUM(salary) AS total_salary
FROM employees
GROUP BY dept_id;

-- Q7: Find departments with average salary greater than 60000.
SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 60000;

-- Q8: Count the number of employees in each department.
SELECT dept_id, COUNT(*) AS emp_count
FROM employees
GROUP BY dept_id;

-- Q9: Find the max and min salary in the entire company.
SELECT MAX(salary) AS highest_salary, MIN(salary) AS lowest_salary
FROM employees;

-- ============================================================
-- SECTION 3: NTH ROW / TOP N QUERIES
-- ============================================================

-- Q10: Find the TOP 3 highest paid employees.
SELECT * FROM employees ORDER BY salary DESC LIMIT 3;

-- Q11: Find the 2nd highest salary. (Classic interview question!)
-- Approach 1: Using OFFSET
SELECT salary FROM employees ORDER BY salary DESC LIMIT 1 OFFSET 1;

-- Approach 2: Using subquery
SELECT MAX(salary) AS second_highest
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- Q12: Find the Nth highest salary (e.g., 4th highest). Change N=4 as needed.
-- Using OFFSET (replace 3 with N-1)
SELECT salary FROM employees ORDER BY salary DESC LIMIT 1 OFFSET 3;

-- Using dense subquery
SELECT salary
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
) ranked
WHERE rnk = 4;

-- Q13: Fetch the top 1 earner per department.
SELECT dept_id, name, salary
FROM (
    SELECT dept_id, name, salary,
           RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rnk
    FROM employees
) ranked
WHERE rnk = 1;

-- Q14: Fetch the 3rd row in the table by insertion order (using rownum / row_number).
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER () AS rn
    FROM employees
) numbered
WHERE rn = 3;

-- ============================================================
-- SECTION 4: JOINS
-- ============================================================

-- Q15: INNER JOIN — Get employee names along with their department names.
SELECT e.name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Q16: LEFT JOIN — List all employees and their department names,
--       including employees with no department assigned.
SELECT e.name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Q17: RIGHT JOIN — List all departments and employees in them,
--       including departments with no employees.
SELECT e.name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Q18: FULL OUTER JOIN — Show all employees and all departments,
--       regardless of whether they match.
SELECT e.name, d.dept_name
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;

-- Q19: SELF JOIN — Find employees and their managers.
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Q20: CROSS JOIN — Produce every combination of employees and departments.
SELECT e.name, d.dept_name
FROM employees e
CROSS JOIN departments d;

-- Q21: Find employees who have placed at least one order
--       (joining employees with orders on customer_id = emp_id).
SELECT DISTINCT e.name
FROM employees e
INNER JOIN orders o ON e.emp_id = o.customer_id;

-- Q22: Find customers who have NEVER placed an order.
SELECT c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- ============================================================
-- SECTION 5: SUBQUERIES
-- ============================================================

-- Q23: Find employees earning more than the company average salary.
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Q24: Find the department with the highest total salary.
SELECT dept_id, SUM(salary) AS total_salary
FROM employees
GROUP BY dept_id
ORDER BY total_salary DESC
LIMIT 1;

-- Q25: Find employees who work in the same department as 'Alice'.
SELECT name FROM employees
WHERE dept_id = (SELECT dept_id FROM employees WHERE name = 'Alice');

-- Q26: Correlated subquery — Find employees earning more than
--       the average salary of their own department.
SELECT e.name, e.salary, e.dept_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.dept_id = e.dept_id
);

-- Q27: Using EXISTS — Find employees who manage at least one other employee.
SELECT DISTINCT m.name
FROM employees m
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.manager_id = m.emp_id
);

-- ============================================================
-- SECTION 6: WINDOW FUNCTIONS
-- ============================================================

-- Q28: Assign a rank to employees by salary within each department.
SELECT name, dept_id, salary,
       RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank
FROM employees;

-- Q29: Difference between RANK, DENSE_RANK, and ROW_NUMBER.
-- RANK()       — gaps after ties (1, 2, 2, 4)
-- DENSE_RANK() — no gaps after ties (1, 2, 2, 3)
-- ROW_NUMBER() — unique, no ties considered (1, 2, 3, 4)
SELECT name, salary,
       RANK()        OVER (ORDER BY salary DESC) AS rank_val,
       DENSE_RANK()  OVER (ORDER BY salary DESC) AS dense_rank_val,
       ROW_NUMBER()  OVER (ORDER BY salary DESC) AS row_num_val
FROM employees;

-- Q30: Running total of salaries ordered by hire_date.
SELECT name, hire_date, salary,
       SUM(salary) OVER (ORDER BY hire_date) AS running_total
FROM employees;

-- Q31: Calculate each employee's salary vs the department average.
SELECT name, dept_id, salary,
       AVG(salary) OVER (PARTITION BY dept_id) AS dept_avg,
       salary - AVG(salary) OVER (PARTITION BY dept_id) AS diff_from_avg
FROM employees;

-- Q32: LAG and LEAD — Compare each order's amount with the previous one.
SELECT order_id, amount, order_date,
       LAG(amount)  OVER (ORDER BY order_date) AS prev_order_amount,
       LEAD(amount) OVER (ORDER BY order_date) AS next_order_amount
FROM orders;

-- ============================================================
-- SECTION 7: STRING & DATE FUNCTIONS
-- ============================================================

-- Q33: Concatenate first and last name (assuming split columns).
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM employees;

-- Q34: Find employees hired in the year 2023.
SELECT * FROM employees WHERE EXTRACT(YEAR FROM hire_date) = 2023;

-- Q35: Calculate each employee's tenure in years.
SELECT name, EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_of_service
FROM employees;

-- ============================================================
-- SECTION 8: DUPLICATE HANDLING
-- ============================================================

-- Q36: Find duplicate employee names.
SELECT name, COUNT(*) AS cnt
FROM employees
GROUP BY name
HAVING COUNT(*) > 1;

-- Q37: Delete duplicate rows, keeping the one with the lowest emp_id.
DELETE FROM employees
WHERE emp_id NOT IN (
    SELECT MIN(emp_id)
    FROM employees
    GROUP BY name, dept_id, salary
);

-- ============================================================
-- SECTION 9: CASE STATEMENTS
-- ============================================================

-- Q38: Label employees as 'Junior', 'Mid', or 'Senior' based on salary.
SELECT name, salary,
       CASE
           WHEN salary < 40000 THEN 'Junior'
           WHEN salary BETWEEN 40000 AND 80000 THEN 'Mid'
           ELSE 'Senior'
       END AS level
FROM employees;

-- Q39: Pivot — Count employees per department per level using CASE.
SELECT
    SUM(CASE WHEN salary < 40000 THEN 1 ELSE 0 END)  AS junior_count,
    SUM(CASE WHEN salary BETWEEN 40000 AND 80000 THEN 1 ELSE 0 END) AS mid_count,
    SUM(CASE WHEN salary > 80000 THEN 1 ELSE 0 END)  AS senior_count
FROM employees;

-- ============================================================
-- SECTION 10: INDEXES & PERFORMANCE
-- ============================================================

-- Q40: Create an index on salary for faster filtering.
CREATE INDEX idx_salary ON employees(salary);

-- Q41: Create a composite index on dept_id and salary.
CREATE INDEX idx_dept_salary ON employees(dept_id, salary);

-- Q42: When would you use EXPLAIN / EXPLAIN ANALYZE?
-- Answer: To inspect the query execution plan and identify slow steps.
EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 70000;

-- ============================================================
-- SECTION 11: ADVANCED / TRICKY QUESTIONS
-- ============================================================

-- Q43: Find departments that have more than 5 employees
--       AND an average salary above 50000.
SELECT dept_id
FROM employees
GROUP BY dept_id
HAVING COUNT(*) > 5 AND AVG(salary) > 50000;

-- Q44: Find the employee with the highest salary in each department
--       using a CTE (Common Table Expression).
WITH ranked AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dr
    FROM employees
)
SELECT emp_id, name, dept_id, salary
FROM ranked
WHERE dr = 1;

-- Q45: Recursive CTE — Build an org chart (employee hierarchy).
WITH RECURSIVE org_chart AS (
    -- Anchor: top-level managers (no manager)
    SELECT emp_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: employees reporting to someone in the previous level
    SELECT e.emp_id, e.name, e.manager_id, oc.level + 1
    FROM employees e
    INNER JOIN org_chart oc ON e.manager_id = oc.emp_id
)
SELECT * FROM org_chart ORDER BY level, name;

-- Q46: Find employees whose salary is in the top 10% of the company.
SELECT name, salary
FROM employees
WHERE salary >= (
    SELECT PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY salary)
    FROM employees
);

-- Q47: UNION vs UNION ALL — what is the difference?
-- UNION     removes duplicates (slower).
-- UNION ALL keeps all rows including duplicates (faster).
SELECT name FROM employees WHERE dept_id = 1
UNION
SELECT name FROM employees WHERE dept_id = 2;  -- removes duplicates

SELECT name FROM employees WHERE dept_id = 1
UNION ALL
SELECT name FROM employees WHERE dept_id = 2;  -- keeps duplicates

-- Q48: INTERSECT — Employees who are also customers.
SELECT name FROM employees
INTERSECT
SELECT name FROM customers;

-- Q49: EXCEPT — Customers who are NOT employees.
SELECT name FROM customers
EXCEPT
SELECT name FROM employees;

-- Q50: Find the running count of orders per customer, ordered by date.
SELECT customer_id, order_id, order_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_sequence
FROM orders;

-- ============================================================
-- END OF FILE
-- Happy Interviewing! 🚀
-- ============================================================