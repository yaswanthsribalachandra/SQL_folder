show databases;
create database test_db;
use test_db;
create table users (id int primary key, name varchar(100));

-- Insert sample users into the users table
insert into users (id, name) values 
(1, 'Alice Johnson'),
(2, 'Bob Smith'),
(3, 'Charlie Brown'),
(4, 'Diana Prince'),
(5, 'Eve Wilson');

-- Display all users from the test_db
select * from users;


