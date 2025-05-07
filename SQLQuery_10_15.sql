

drop table employee

CREATE TABLE employee (
    emp_id VARCHAR(20) PRIMARY KEY,
    emp_name VARCHAR(30),
    joining_date DATETIME DEFAULT CURRENT_TIMESTAMP,
	salary float
);


insert into employee(emp_id,emp_name,salary) values('101','sayem',1230)

INSERT INTO employee (emp_id, emp_name,salary) VALUES 
('102', 'rabbi',1474), 
('103', 'shakil',12548);

select * from employee;



DROP TABLE department;

CREATE TABLE department (
    dept_name VARCHAR(30),
    emp_id VARCHAR(20) unique,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);


insert into department(dept_name,emp_id) values
('HR','1025'),
('IT','105');




select e.emp_id,e.emp_name from employee e full join department d on e.emp_id=d.emp_id

select e.emp_id,e.emp_name,d.dept_name from employee e left join department d on e.emp_id=d.emp_id

select e.emp_id,e.emp_name,d.dept_name from employee e right join department d on e.emp_id=d.emp_id

select e.emp_id,e.emp_name,d.dept_name from employee e inner join department d on e.emp_id=d.emp_id




SELECT SUBSTRING(emp_name, 1, 1) AS FirstLetter,
       COUNT(1) AS Count
FROM employee
GROUP BY SUBSTRING(emp_name, 1, 1);


SELECT emp_name
      ,salary
      ,RANK() OVER (PARTITION BY emp_name ORDER BY salary desc) rank_salary
FROM employee;