/*****************************************************************
SQL INTERVIEW PREPARATION
Author: Your Name
Purpose: Frequently Asked SQL Interview Questions & Answers
******************************************************************/

/*****************************************************************
SETUP TABLES
******************************************************************/

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    salary INT,
    manager_id INT
);

INSERT INTO Employees VALUES
(1,'John','IT',90000,NULL),
(2,'Alice','HR',60000,1),
(3,'Bob','IT',80000,1),
(4,'Charlie','Finance',70000,1),
(5,'David','IT',95000,3),
(6,'Emma','HR',65000,2);

CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

INSERT INTO Departments VALUES
(1,'IT'),
(2,'HR'),
(3,'Finance');


/*****************************************************************
Q1. Retrieve all employees
******************************************************************/

SELECT * FROM Employees;


/*****************************************************************
Q2. Find employees earning more than 70000
******************************************************************/

SELECT *
FROM Employees
WHERE salary > 70000;


/*****************************************************************
Q3. Find employees whose name starts with 'A'
******************************************************************/

SELECT *
FROM Employees
WHERE emp_name LIKE 'A%';


/*****************************************************************
Q4. Sort employees by salary descending
******************************************************************/

SELECT *
FROM Employees
ORDER BY salary DESC;


/*****************************************************************
Q5. Top 3 highest paid employees
******************************************************************/

SELECT *
FROM Employees
ORDER BY salary DESC
LIMIT 3;


/*****************************************************************
Q6. Find highest salary
******************************************************************/

SELECT MAX(salary) AS highest_salary
FROM Employees;


/*****************************************************************
Q7. Find second highest salary
******************************************************************/

SELECT MAX(salary)
FROM Employees
WHERE salary <
(
    SELECT MAX(salary)
    FROM Employees
);


/*****************************************************************
Q8. Find third highest salary
******************************************************************/

SELECT DISTINCT salary
FROM Employees
ORDER BY salary DESC
LIMIT 1 OFFSET 2;


/*****************************************************************
Q9. Find Nth highest salary (N=3)
******************************************************************/

SELECT salary
FROM
(
    SELECT DISTINCT salary,
           DENSE_RANK() OVER
           (ORDER BY salary DESC) AS rnk
    FROM Employees
) x
WHERE rnk = 3;


/*****************************************************************
Q10. Count employees in each department
******************************************************************/

SELECT department,
       COUNT(*) AS total_employees
FROM Employees
GROUP BY department;


/*****************************************************************
Q11. Departments having more than 2 employees
******************************************************************/

SELECT department,
       COUNT(*) AS total
FROM Employees
GROUP BY department
HAVING COUNT(*) > 2;


/*****************************************************************
Q12. Average salary by department
******************************************************************/

SELECT department,
       AVG(salary) AS avg_salary
FROM Employees
GROUP BY department;


/*****************************************************************
Q13. INNER JOIN Example
******************************************************************/

SELECT e.emp_name,
       d.dept_name
FROM Employees e
INNER JOIN Departments d
ON e.department = d.dept_name;


/*****************************************************************
Q14. LEFT JOIN Example
******************************************************************/

SELECT e.emp_name,
       d.dept_name
FROM Employees e
LEFT JOIN Departments d
ON e.department = d.dept_name;


/*****************************************************************
Q15. RIGHT JOIN Example
******************************************************************/

SELECT e.emp_name,
       d.dept_name
FROM Employees e
RIGHT JOIN Departments d
ON e.department = d.dept_name;


/*****************************************************************
Q16. FULL OUTER JOIN
******************************************************************/

SELECT e.emp_name,
       d.dept_name
FROM Employees e
FULL OUTER JOIN Departments d
ON e.department = d.dept_name;


/*****************************************************************
Q17. SELF JOIN (Employee - Manager)
******************************************************************/

SELECT e.emp_name AS Employee,
       m.emp_name AS Manager
FROM Employees e
LEFT JOIN Employees m
ON e.manager_id = m.emp_id;


/*****************************************************************
Q18. Employees earning above average salary
******************************************************************/

SELECT *
FROM Employees
WHERE salary >
(
    SELECT AVG(salary)
    FROM Employees
);


/*****************************************************************
Q19. Highest salary in each department
******************************************************************/

SELECT department,
       MAX(salary)
FROM Employees
GROUP BY department;


/*****************************************************************
Q20. Employee with highest salary in each department
******************************************************************/

SELECT *
FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
              PARTITION BY department
              ORDER BY salary DESC
           ) rn
    FROM Employees
) x
WHERE rn = 1;


/*****************************************************************
Q21. ROW_NUMBER()
******************************************************************/

SELECT emp_name,
       salary,
       ROW_NUMBER() OVER
       (ORDER BY salary DESC) AS row_num
FROM Employees;


/*****************************************************************
Q22. RANK()
******************************************************************/

SELECT emp_name,
       salary,
       RANK() OVER
       (ORDER BY salary DESC) AS rank_no
FROM Employees;


/*****************************************************************
Q23. DENSE_RANK()
******************************************************************/

SELECT emp_name,
       salary,
       DENSE_RANK() OVER
       (ORDER BY salary DESC) AS dense_rank_no
FROM Employees;


/*****************************************************************
Q24. Find duplicate values
******************************************************************/

SELECT department,
       COUNT(*)
FROM Employees
GROUP BY department
HAVING COUNT(*) > 1;


/*****************************************************************
Q25. Delete duplicate rows
******************************************************************/

WITH cte AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
              PARTITION BY emp_name
              ORDER BY emp_id
           ) rn
    FROM Employees
)
DELETE FROM cte
WHERE rn > 1;


/*****************************************************************
Q26. Common Table Expression (CTE)
******************************************************************/

WITH HighSalaryEmployees AS
(
    SELECT *
    FROM Employees
    WHERE salary > 80000
)
SELECT *
FROM HighSalaryEmployees;


/*****************************************************************
Q27. Running Total
******************************************************************/

SELECT emp_id,
       salary,
       SUM(salary) OVER
       (
          ORDER BY emp_id
       ) AS running_total
FROM Employees;


/*****************************************************************
Q28. Difference Between WHERE and HAVING

WHERE  -> Filters rows before GROUP BY

HAVING -> Filters groups after GROUP BY
******************************************************************/


/*****************************************************************
Q29. Difference Between DELETE, TRUNCATE, DROP

DELETE   -> Removes rows
TRUNCATE -> Removes all rows quickly
DROP     -> Removes entire table
******************************************************************/


/*****************************************************************
Q30. Most Asked Interview Query

Find Top 2 Salaries from each Department
******************************************************************/

SELECT *
FROM
(
    SELECT *,
           DENSE_RANK() OVER
           (
               PARTITION BY department
               ORDER BY salary DESC
           ) rnk
    FROM Employees
) x
WHERE rnk <= 2;


/*****************************************************************
END OF SQL INTERVIEW PREPARATION
******************************************************************/