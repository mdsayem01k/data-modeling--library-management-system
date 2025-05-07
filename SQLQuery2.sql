create table employee(
emp_id varchar(20) PRIMARY KEY,
emp_name varchar(30),
age int,
department varchar(20),
salary DECIMAL(18,2));


INSERT INTO employee (emp_id, emp_name, age, department, salary)
VALUES
('E001454', 'John Doe', 28, 'IT', 50000.50),
('E0042', 'Jane Smith', 32, 'IT', 60000.00),
('E00443', 'Michael Brown', 45, 'IT', 80000.75),
('E4004', 'Emily Davis', 29, 'Marketing', 55000.20),
('E0405', 'Robert Wilson', 40, 'Marketing', 75000.50),
('E0406', 'Sophia Johnson', 27, 'HR', 48000.00),
('E04047', 'William Martinez', 35, 'Marketing', 68000.30),
('E00448', 'Olivia Garcia', 50, 'HR', 90000.25),
('E0049', 'James Rodriguez', 38, 'HR', 72000.10),
('E0140', 'Linda Lopez', 33, 'HR', 59000.65);


INSERT INTO employee (emp_id, emp_name, age, department, salary)
VALUES
('E011', 'Daniel Evans', 31, 'HR', 51000.00),
('E012', 'Isabella Green', 26, 'IT', 62000.45),
('E013', 'Lucas Moore', 42, 'Finance', 78000.90),
('E014', 'Mia Taylor', 34, 'Marketing', 57000.75),
('E015', 'Alexander Anderson', 47, 'Operations', 81000.60),
('E016', 'Ava Thomas', 30, 'HR', 49500.20),
('E017', 'Elijah Lee', 29, 'IT', 60500.00),
('E018', 'Charlotte Harris', 39, 'Finance', 85000.50),
('E019', 'Ethan Walker', 43, 'Operations', 73000.80),
('E020', 'Amelia Hall', 25, 'Marketing', 56000.30),
('E021', 'Henry King', 36, 'HR', 52000.75),
('E022', 'Harper Scott', 27, 'IT', 59000.40),
('E023', 'Jack Young', 48, 'Finance', 86000.90),
('E024', 'Ella White', 41, 'Operations', 70000.25),
('E025', 'Mason Lewis', 33, 'Marketing', 58000.65),
('E026', 'Liam Harris', 46, 'HR', 54000.00),
('E027', 'Sofia Clark', 28, 'IT', 63000.50),
('E028', 'Logan Robinson', 44, 'Finance', 80000.30),
('E029', 'Emma Perez', 38, 'Operations', 77000.10),
('E030', 'Oliver Turner', 32, 'Marketing', 60000.85);