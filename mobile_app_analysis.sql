
create database mobile_app_db ;

use mobile_app_db ;

-- user table
Create table users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    signup_date DATE,
    device_type VARCHAR(20),
    app_version VARCHAR(20)
);

select * from users ;

-- Issues Table
Create table Issues (
    issue_id INT PRIMARY KEY,
    user_id INT,
    issue_type VARCHAR(50),
    description TEXT,
    reported_date DATETIME,
    status VARCHAR(20),
    priority VARCHAR(20),
    app_version VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

select * from issues ;

select count(user_id) as Total_users 
from users ;

-- CHECK MISSING VALUES (IF ANY)
select
  sum(case when name is null or name = '' then 1 else 0 end) as missing_user_name,
  sum(case when email is null or  email = '' then 1 else 0 end ) as missing_email,
  SUM(case when signup_date is null then 1 else 0 end ) as missing_signup_date,
  SUM(case when device_type is null or  device_type = ''  then 1 else 0 end) as missing_device_type,
  SUM(case when  app_version is null or  app_version = '' then 1 else 0 end) as missing_app_version
  from users ;

-- CHECK MISSING VALUES (IF ANY)
select
  sum(case when user_id is null or user_id = '' then 1 else 0 end) as missing_user_id,
  sum(case when issue_type is null or issue_type = '' then 1 else 0 end) as missing_issue_type,
  sum(case when description is null or description = '' then 1 else 0 end) as missing_description,
  sum(case when reported_date is null then 1 else 0 end) as missing_reported_date,
  sum(case when status is null or status = '' then 1 else 0 end) as missing_status,
  sum(case when priority is null or priority = '' then 1 else 0 end) as missing_priority,
  sum(case when app_version is null or app_version = '' then 1 else 0 end) as missing_app_version
  from  issues;
  
  
-- CHECKING DUPLICATES FOR USERS TABLE
select *
from (
select* , row_number()over (partition by user_id ,name , email ,signup_date ,device_type , app_version  order by user_id) as row_num
from users
) as sub
where row_num >1 ;

-- CHECKING DUPLICATES FOR ISSUES TABLE
with duplicates as (
 select row_number() over(partition by issue_id ,user_id ,issue_type ,description,reported_date,status ,priority,app_version  order by user_id)as row_num
 from issues 
 )
select *
from issues ,duplicates
where row_num >1 ;


-- 1. what is the overall trend of issues reported over time (monthly) ?

select date_format(reported_date, '%Y-%m') AS month,count(*) AS total_issues
from issues
Group by month
order by month ;

-- 2. Which issue types (Crash, UI Bug, Performance, etc.) are most frequently reported?

select issue_type ,count(*)as issues_count
from issues
group by issue_type 
order by issues_count  desc ;

-- 3. Which app versions have the most reported issues?
select app_version,Count(issue_id) AS total_issues
from Issues
group by app_version
order by total_issues desc
limit 14 ;

-- 4. Are certain device types more prone to specific issue types?

select i.issue_type, u.device_type,count(*) AS issues_count
from Issues as i
join users as u ON i.user_id = u.user_id
group by i.issue_type,u.device_type
order by issues_count  desc ;

-- 5. What is the distribution of issue priority levels (Low, Medium, High, Critical) over time?

select date_format(reported_date, '%Y-%m') as month,priority,count(*) AS count_by_priority
from issues
group by month , priority
order by month, priority ;

-- 6. How many issues remain unresolved (status = Open or In Progress) over time, and is there a backlog growing?

Select Date_format(reported_date,'%Y-%m') AS report_month,status,Count(*) AS issue_count
from Issues
where status in('Open', 'In Progress')
group by report_month,status
order by report_month,status ;

