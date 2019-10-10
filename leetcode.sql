-----------------------------------------------------------------------------------------------------
--174
-----------------------------------------------------------------------------------------------------
SELECT class
FROM (
        SELECT class,
                COUNT(DISTINCT student) AS st_num
        FROM courses
        GROUP BY class
        ) AS temp_table
WHERE st_num >= 5
;


SELECT class FROM courses
GROUP BY class
HAVING COUNT(distinct student) >= 5
;

-----------------------------------------------------------------------------------------------------
--175
-----------------------------------------------------------------------------------------------------
SELECT  Person.FirstName,
        Person.LastName,
        Address.City,
        Address.State
FROM Person 
LEFT JOIN Address
ON Person.PersonID = Address.PersonID
;


-----------------------------------------------------------------------------------------------------
--176
-----------------------------------------------------------------------------------------------------
SELECT IFNULL(
                (SELECT DISTINCT Salary
                FROM Employee 
                ORDER BY Salary DESC
                LIMIT 1 OFFSET 1
                ),NULL
                ) AS SecondHighestSalary
;

① select * from table limit 2,1;                 
--含义是跳过2条取出1条数据，limit后面是从第2条开始读，读取1条信息，即读取第3条数据

② select * from table limit 2 offset 1;      
--含义是从第1条（不包括）数据开始取出2条数据，limit后面跟的是2条数据，offset后面是跳过第1条，即读取第2,3条


-----------------------------------------------------------------------------------------------------
--177
-----------------------------------------------------------------------------------------------------

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN SET N = N-1;
  RETURN (
          # Write your MySQL query statement below.
          SELECT DISTINCT Salary
          FROM Employee
          LIMIT 1 OFFSET N
          );
END


-----------------------------------------------------------------------------------------------------
--178
-----------------------------------------------------------------------------------------------------
SELECT  t1.Score,
        t2.Rank
FROM Scores t1 
LEFT JOIN 
    (
        SELECT t1.Score,
                COUNT(DISTINCT t2.Score) AS Rank
        FROM Scores t1
        LEFT JOIN 
            (
                SELECT DISTINCT Score
                FROM Scores
            ) t2 
        ON t1.Score <= t2.Score
        GROUP BY t1.Score
        ) t2
ON t1.Score = t2.Score
ORDER BY t1.Score DESC, t2.Rank ASC
;

    

-----------------------------------------------------------------------------------------------------
--180. Consecutive Numbers
-----------------------------------------------------------------------------------------------------

SELECT DISTINCT t1.Num AS ConsecutiveNums
FROM Logs t1 
LEFT JOIN Logs t2
ON t1.Id = t2.Id + 1
LEFT JOIN Logs t3
ON t1.Id = t3.Id +2
WHERE t1.Num = t2.Num 
AND t1.Num = t3.Num
;


-----------------------------------------------------------------------------------------------------
--181. Employees Earning More Than Their Managers
-----------------------------------------------------------------------------------------------------

SELECT  t1.Name AS Employee
FROM (
        SELECT  DISTINCT
                t1.Name,
                t1.Salary,
                t2.Name AS Name_M,
                t2.Salary AS Salary_M
        FROM Employee t1 
        LEFT JOIN Employee t2
        ON t1.ManagerId = t2.Id
        ) t1 
WHERE Salary > Salary_M
;

-----------------------------------------------------------------------------------------------------
--182. Duplicate Emails
-----------------------------------------------------------------------------------------------------
SELECT Email
FROM Person
GROUP BY Email
HAVING COUNT(Email) > 1
;

-----------------------------------------------------------------------------------------------------
--183. Customers Who Never Order
-----------------------------------------------------------------------------------------------------
SELECT t1.Name AS Customers
FROM Customers t1
LEFT JOIN Orders t2
ON t1.Id = t2.CustomerId
WHERE t2.CustomerId IS NULL
;


-----------------------------------------------------------------------------------------------------
--184. Department Highest Salary
-----------------------------------------------------------------------------------------------------

SELECT  t3.Name AS Department,
        t2.Name AS Employee,
        t1.SalaryMax AS Salary
FROM (
        SELECT DepartmentId, Max(Salary) AS SalaryMax
        FROM Employee 
        GROUP BY DepartmentId
        ) t1 
INNER JOIN Employee t2
ON t1.DepartmentId = t2.DepartmentId
AND t1.SalaryMax = t2.Salary
INNER JOIN Department t3 
ON t1.DepartmentId = t3.Id
ORDER BY t1.SalaryMax
;


-----------------------------------------------------------------------------------------------------
--185. Department Top Three Salaries
-----------------------------------------------------------------------------------------------------
WITH cte (Department, Employee, Salary, rw)  
AS  
-- Define the first CTE query.  
( 
    SElECT d.name,
           e.name, 
           e.Salary,
           row_number() over (partition by departmentid ORDER BY salary DESC)
    FROM employee e
    LEFT JOIN 
        department d 
    ON d.id= e.departmentid
)

SElECT Department, Employee, Salary FROM cte
WHERE rw < 4
;


select e1.Name as 'Employee', e1.Salary
from Employee e1
where 3 >
(
    select count(distinct e2.Salary)
    from Employee e2
    where e2.Salary > e1.Salary
)
;




SELECT  t2.Name AS Department,
        t1.Name AS Employee,
        t1.Salary
FROM (
        SELECT t1.*, COUNT(DISTINCT t2.Salary) AS num
        FROM Employee t1 
        LEFT JOIN 
            (
                SELECT DISTINCT DepartmentId, Id, Salary
                FROM Employee
                ) t2
        ON t1.DepartmentId = t2.DepartmentId
        AND t1.Salary <= t2.Salary
        GROUP BY t1.Id, t1.Name, t1.Salary, t1.DepartmentId
        ) t1 
INNER JOIN Department t2
ON t1.DepartmentId = t2.Id
WHERE t1.num <= 3
ORDER BY t2.Name, t1.Salary DESC
;

-----------------------------------------------------------------------------------------------------
--196. Delete Duplicate Emails
-----------------------------------------------------------------------------------------------------

DELETE p1 FROM Person p1,
    Person p2
WHERE
    p1.Email = p2.Email AND p1.Id > p2.Id

GROUP_CONCAT


-----------------------------------------------------------------------------------------------------
--197. Rising Temperature
-----------------------------------------------------------------------------------------------------

SELECT t1.Id
FROM Weather t1
LEFT JOIN Weather t2
ON SUBDATE(t1.RecordDate, 1) = t2.RecordDate
AND t1.Temperature > t2.Temperature
WHERE t2.Temperature IS NOT NULL
;



-----------------------------------------------------------------------------------------------------
--262. Trips and Users    
-----------------------------------------------------------------------------------------------------

SELECT 	t.request_at AS Day, 
		ROUND(SUM(CASE WHEN t.status = 'completed' THEN 0 ELSE 1 END) / (SELECT COUNT(t.status)), 2) AS 'Cancellation Rate' 
FROM (
		SELECT *
		FROM trips
		INNER JOIN users 
		ON trips.client_id = users.users_id 
		WHERE users.banned = 'No'
		) AS t 
GROUP BY t.request_at
HAVING t.request_at BETWEEN '2013-10-01' AND '2013-10-03';



select t2.Day, round(t3.cancelled/t2.tot,2) as `Cancellation Rate` FROM

(select Request_at as Day, Count(Status) AS tot FROM
(select * from trips where Driver_Id not in
(select users_id as Driver_Id from Users where Banned='Yes')
and 
Client_Id not in (select users_id as Client_Id from Users where Banned='Yes')) t1
group by Day) t2,

(select Request_at as Day, Count(case Status when 'completed' then null else 1 end) AS cancelled FROM 
(select * from trips where Driver_Id not in
(select users_id as Driver_Id from Users where Banned='Yes')
and 
Client_Id not in (select users_id as Client_Id from Users where Banned='Yes')) t4
 group by Day) t3
 
 where t2.day=t3.day
 and t2.day between '2013-10-01' and '2013-10-03';



-----------------------------------------------------------------------------------------------------
--569. Median Employee Salary
-----------------------------------------------------------------------------------------------------

# The median's frequency should be equal or grater than the absolute difference of its bigger 
# elements and small ones in an array no matter whether it has odd or even amount of numbers and 
# whether they are distinct. 

SELECT
    Employee.Id, 
    Employee.Company, 
    Employee.Salary
FROM
    Employee,
    Employee alias
WHERE
    Employee.Company = alias.Company
GROUP BY Employee.Company , Employee.Salary
HAVING SUM(CASE
    WHEN Employee.Salary = alias.Salary THEN 1
    ELSE 0
END) >= ABS(SUM(SIGN(Employee.Salary - alias.Salary)))
ORDER BY Employee.Id
;


-----------------------------------------------------------------------------------------------------
--570. Managers with at Least 5 Direct Reports
-----------------------------------------------------------------------------------------------------

SELECT DISTINCT Name AS Name
FROM Employee t1
INNER JOIN 
    (
        SELECT ManagerId
        FROM Employee
        GROUP BY ManagerId
        HAVING COUNT(1) >= 5
    ) t2
ON t1.Id = t2.ManagerId;


-----------------------------------------------------------------------------------------------------
--571. Find Median Given Frequency of Numbers
-----------------------------------------------------------------------------------------------------
/*
When the observations (n) is odd, then median = (n+1)/2
When the observations is even, then median = [ (n+1)/2 + n/2 ] / 2
*/


SELECT AVG(t1.Number) AS median
FROM Numbers t1 
INNER JOIN 
    (
        SELECT  t1.Number,
                ABS(
                    SUM(CASE WHEN t1.Number > t2.Number THEN t2.Frequency ELSE 0 END)-
                    SUM(CASE WHEN t1.Number < t2.Number THEN t2.Frequency ELSE 0 END)
                    ) AS count_diff
        FROM Numbers t1,
             Numbers t2
        GROUP BY t1.Number
    ) t2 
ON t1.Number = t2.Number
WHERE t1.Frequency >= t2.count_diff



-----------------------------------------------------------------------------------------------------
--574. Winning Candidate
-----------------------------------------------------------------------------------------------------

SELECT Name
FROM Candidate
INNER JOIN 
    (
        SELECT  CandidateId
        FROM Vote
        GROUP BY CandidateId
        ORDER BY COUNT(1) DESC
        LIMIT 1
        ) Vote
ON Candidate.id = Vote.CandidateId
;



-----------------------------------------------------------------------------------------------------
--577. Employee Bonus
-----------------------------------------------------------------------------------------------------

SELECT name, bonus
FROM Employee
LEFT JOIN 
    (
        SELECT  empId,
                bonus
        FROM Bonus
        
    ) Bonus
ON Employee.empId = Bonus.empId
WHERE bonus < 1000 OR bonus IS NULL
;


-----------------------------------------------------------------------------------------------------
--578. Get Highest Answer Rate Question
-----------------------------------------------------------------------------------------------------

SELECT question_id AS survey_log
FROM (
        SELECT  question_id,
                SUM(CASE WHEN answer_id IS NULL THEN 0 ELSE 1 END) AS answer_cnt,
                SUM(CASE WHEN action = 'show' THEN 1 ELSE 0 END) AS info_cnt
        FROM survey_log
        GROUP BY question_id
) a
ORDER BY answer_cnt/info_cnt DESC
LIMIT 1;


-----------------------------------------------------------------------------------------------------
--579. Find Cumulative Salary of an Employee
-----------------------------------------------------------------------------------------------------

SELECT  t1.Id,
        t1.Month,
        IFNULL(t1.Salary,0) + IFNULL(t2.Salary,0) + IFNULL(t3.Salary,0) AS Salary
FROM (
        SELECT  t2.Id,
                t2.Month,
                t2.Salary
        FROM (
                SELECT  Id,
                        MAX(Month) AS max_month
                FROM Employee 
                GROUP BY Id
                ) t1 
        LEFT JOIN Employee t2
        ON t1.Id = t2.Id
        WHERE max_month > t2.Month
    ) t1 
LEFT JOIN Employee t2
ON t1.Id = t2.Id
AND t1.Month = t2.Month+1
LEFT JOIN Employee t3
ON t1.Id = t3.Id
AND t1.Month = t3.Month+2
ORDER BY    t1.Id ASC,
            t1.Month DESC
;


-----------------------------------------------------------------------------------------------------
--580. Count Student Number in Departments
-----------------------------------------------------------------------------------------------------
SELECT  t1.dept_name,
        COUNT(DISTINCT t2.student_id) AS student_number
FROM department t1
LEFT JOIN student t2
ON t1.dept_id = t2.dept_id
GROUP BY t1.dept_name
ORDER BY COUNT(DISTINCT t2.student_id) DESC, t1.dept_name ASC
;


-----------------------------------------------------------------------------------------------------
--584. Find Customer Referee
-----------------------------------------------------------------------------------------------------
SELECT  
        name
FROM customer
WHERE referee_id <> 2 OR referee_id IS NULL
;


-----------------------------------------------------------------------------------------------------
--585. Investments in 2016
-----------------------------------------------------------------------------------------------------

SELECT ROUND(SUM(TIV_2016),2) AS TIV_2016
FROM insurance t1 
INNER JOIN 
    (
        SELECT LAT,LON
        FROM insurance 
        GROUP BY LAT,LON
        HAVING COUNT(DISTINCT PID) = 1
    ) t2 
ON t1.LAT = t2.LAT
AND t1.LON = t2.LON
WHERE t1.TIV_2015 IN (
        SELECT TIV_2015
        FROM insurance
        GROUP BY TIV_2015
        HAVING COUNT(DISTINCT PID) > 1
        )
;

-----------------------------------------------------------------------------------------------------
--586. Customer Placing the Largest Number of Orders
-----------------------------------------------------------------------------------------------------

SELECT  customer_number
FROM orders
GROUP BY customer_number
ORDER BY COUNT(DISTINCT order_number) DESC
LIMIT 1
;


-----------------------------------------------------------------------------------------------------
--595. Big Countries
-----------------------------------------------------------------------------------------------------

SELECT  name,
        population,
        area
FROM World
WHERE area > 3000000
OR population > 25000000
;


-----------------------------------------------------------------------------------------------------
--597. Friend Requests I: Overall Acceptance Rate
-----------------------------------------------------------------------------------------------------
SELECT 
    ROUND(IFNULL(
        (SELECT COUNT(DISTINCT requester_id, accepter_id) AS A FROM request_accepted)
        /
        (SELECT COUNT(DISTINCT sender_id, send_to_id) AS B FROM friend_request)
        ,0),2) AS accept_rate
;

    

-----------------------------------------------------------------------------------------------------
--601. Human Traffic of Stadium
-----------------------------------------------------------------------------------------------------
SELECT DISTINCT t1.* 
FROM stadium t1
JOIN stadium t2
JOIN stadium t3
WHERE t1.people >= 100 AND t2.people >= 100 AND t3.people >= 100
AND ( (t1.id - t2.id = 1 AND t2.id - t3.id = 1 AND t1.id - t3.id = 2) 
	 OR 
	 (t3.id - t2.id = 1 AND t2.id - t1.id = 1 AND t3.id - t1.id = 2) 
	 OR 
	 (t3.id - t1.id = 1 AND t1.id - t2.id = 1 AND t3.id - t2.id = 2) 
	 OR 
	 (t2.id - t1.id = 1 AND t1.id - t3.id = 1 AND t2.id - t3.id = 2) 
	 OR 
	 (t2.id - t3.id = 1 AND t3.id - t1.id = 1 AND t2.id - t1.id = 2) 
	 OR 
	 (t1.id - t3.id = 1 AND t3.id - t2.id = 1 AND t1.id - t2.id = 2) 
   )
ORDER BY t1.id ASC;


-----------------------------------------------------------------------------------------------------
--602. Friend Requests II: Who Has the Most Friends
-----------------------------------------------------------------------------------------------------

SELECT id, num
FROM (
		SELECT  requester_id AS id,
		        COUNT(*) AS num
		FROM (
		        SELECT requester_id, accepter_id
		        FROM request_accepted
		        UNION ALL 
		        SELECT accepter_id, requester_id
		        FROM request_accepted
		        ) t1
		GROUP BY requester_id
    	) t2
ORDER BY num DESC
LIMIT 1
;


-----------------------------------------------------------------------------------------------------
--603. Consecutive Available Seats
-----------------------------------------------------------------------------------------------------
SELECT DISTINCT 
        a.seat_id AS seat_id
FROM cinema a 
JOIN cinema b
ON abs(a.seat_id - b.seat_id) = 1
WHERE a.free = 1
AND b.free = 1
ORDER BY a.seat_id ASC
;



-----------------------------------------------------------------------------------------------------
--607. Sales Person
-----------------------------------------------------------------------------------------------------

SElECT DISTINCT name 
FROM salesperson
LEFT JOIN 
    (
        SELECT DISTINCT sales_id
        FROM orders
        LEFT JOIN company
        ON orders.com_id = company.com_id
        WHERE company.name = 'RED'
        AND company.com_id IS NOT NULL
        ) t1 
ON salesperson.sales_id = t1.sales_id
WHERE t1.sales_id IS NULL
;



-----------------------------------------------------------------------------------------------------
--608. Tree Node
-----------------------------------------------------------------------------------------------------

SELECT  id AS `Id`,
        (CASE WHEN p_id IS NULL THEN 'Root'
              WHEN id IN (SELECT p_id FROM tree) THEN 'Inner'
              ELSE 'Leaf'
              END) AS `Type`
FROM tree
ORDER BY id
;


-----------------------------------------------------------------------------------------------------
--610. Triangle Judgement
-----------------------------------------------------------------------------------------------------

SELECT 	x,
		y,
		z,
		(CASE WHEN x+y > z AND x+z > y AND y+z >x THEN 'Yes' 
			  ELSE 'No' END) AS triangle
FROM triangle
;


-----------------------------------------------------------------------------------------------------
--612. Shortest Distance in a Plane
-----------------------------------------------------------------------------------------------------

SELECT ROUND(distance,2) AS shortest
FROM (
        SELECT SQRT(POWER((t1.x-t2.x),2)+POWER((t1.y-t2.y),2)) AS distance
        FROM point_2d t1 
        JOIN point_2d t2
        ) t1
WHERE t1.distance >0
ORDER BY distance ASC
LIMIT 1;


-----------------------------------------------------------------------------------------------------
--613. Shortest Distance in a Line
-----------------------------------------------------------------------------------------------------

SELECT ABS(t1.x - t2.x) AS shortest
FROM point t1
JOIN point t2
ON t1.x != t2.x
ORDER BY ABS(t1.x - t2.x) ASC
LIMIT 1
;

-----------------------------------------------------------------------------------------------------
--614. Second Degree Follower
-----------------------------------------------------------------------------------------------------

SELECT DISTINCT t1.follower, t2.num
FROM follow t1 
JOIN (
        SELECT  followee,
                COUNT(DISTINCT follower) AS num
        FROM follow
        WHERE followee IN (SELECT follower FROM follow)
        GROUP BY followee
        ) t2
ON UPPER(t1.follower) = UPPER(t2.followee)
;



-----------------------------------------------------------------------------------------------------
--615. Average Salary: Departments VS Company
-----------------------------------------------------------------------------------------------------

SELECT  t1.pay_month,
        t1.department_id,
        (CASE WHEN t1.avg_amount < t2.avg_amount_com THEN 'lower'
              WHEN t1.avg_amount = t2.avg_amount_com THEN 'same'
              WHEN t1.avg_amount > t2.avg_amount_com THEN 'higher'
         END) AS comparison
FROM (         
        SELECT  date_format(t1.pay_date, '%Y-%m') AS pay_month,
                t2.department_id,
                ROUND(AVG(amount),2) AS avg_amount
        FROM salary t1 
        LEFT JOIN employee t2 
        ON t1.employee_id = t2.employee_id
        GROUP BY date_format(t1.pay_date, '%Y-%m'),
                 t2.department_id
        ) t1
LEFT JOIN 
    (
        SELECT  date_format(pay_date, '%Y-%m') AS pay_month,
                ROUND(AVG(amount),2) AS avg_amount_com
        FROM salary
        GROUP BY date_format(pay_date, '%Y-%m')
        ) t2
ON t1.pay_month = t2.pay_month
ORDER BY 
         t1.department_id,
         t1.pay_month
;


-----------------------------------------------------------------------------------------------------
--618. Students Report By Geography
-----------------------------------------------------------------------------------------------------


SELECT  t1.America AS America,
        t2.Asia AS Asia,
        t3.Europe AS Europe
FROM (
        SELECT ROW_NUMBER() AS id,
                continent AS America
        FROM student
        WHERE continent = 'America'
        ) t1
LEFT JOIN 
    (
        SELECT ROW_NUMBER() AS id,
                continent AS Asia
        FROM student
        WHERE continent = 'Asia'
        ) t2
ON t1.id = t2.id
LEFT JOIN 
    (
        SELECT ROW_NUMBER() AS id,
                continent AS Europe
        FROM student
        WHERE continent = 'Europe'
        ) t3
ON t1.id = t3.id
;


-----------------------------------------------------------------------------------------------------
--619. Biggest Single Number
-----------------------------------------------------------------------------------------------------

SELECT MAX(num) AS num
FROM (
        SELECT  t1.num, 
                COUNT(*) AS times
        FROM number t1 
        JOIN number t2
        ON t1.num = t2.num
        GROUP BY t1.num
        ) t1 
WHERE times = 1
;


-----------------------------------------------------------------------------------------------------
--620. Not Boring Movies
-----------------------------------------------------------------------------------------------------

SELECT  id,
        movie,
        description,
        rating
FROM cinema
WHERE MOD(id,2) = 1
AND description != 'boring'
ORDER BY rating DESC
;



-----------------------------------------------------------------------------------------------------
--626. Exchange Seats
-----------------------------------------------------------------------------------------------------

SELECT  t1.id,
        COALESCE((CASE t1.id % 2 WHEN 1 THEN t2.student 
                                 WHEN 0 THEN t3.student END)
                 , t1.student) AS student
FROM seat t1 
LEFT JOIN seat t2
ON t1.id = t2.id - 1
LEFT JOIN seat t3
ON t1.id = t3.id + 1
ORDER BY t1.id ASC
;


-----------------------------------------------------------------------------------------------------
--1045. Customers Who Bought All Products
-----------------------------------------------------------------------------------------------------

SELECT DISTINCT c.customer_id 
FROM Customer c
GROUP BY c.customer_id 
HAVING COUNT(DISTINCT c.product_key) = (SELECT COUNT(DISTINCT product_key) FROM Product)


-----------------------------------------------------------------------------------------------------
--1050. Actors and Directors Who Cooperated At Least Three Times
-----------------------------------------------------------------------------------------------------
SELECT  actor_id, director_id
FROM ActorDirector
GROUP BY actor_id, director_id
HAVING COUNT(timestamp) >= 3


-----------------------------------------------------------------------------------------------------
--1068. Product Sales Analysis I
-----------------------------------------------------------------------------------------------------
SELECT  p.product_name,
        s.year,
        s.price
FROM Sales s 
INNER JOIN Product p 
ON s.product_id = p.product_id
ORDER BY p.product_name

-----------------------------------------------------------------------------------------------------
--1069. Product Sales Analysis II
-----------------------------------------------------------------------------------------------------
SELECT  product_id,
        SUM(quantity) AS total_quantity
FROM Sales
GROUP BY product_id


-----------------------------------------------------------------------------------------------------
--1070. Product Sales Analysis III
-----------------------------------------------------------------------------------------------------

SELECT  t1.product_id,
        t1.first_year,
        t2.quantity,
        t2.price
FROM (    

        SELECT  product_id, 
                MIN(year) AS first_year
        FROM Sales
        GROUP BY product_id
        ) t1 
INNER JOIN Sales t2 
ON t1.product_id = t2.product_id
AND t1.first_year = t2.year





-----------------------------------------------------------------------------------------------------
--1070. Product Sales Analysis III
-----------------------------------------------------------------------------------------------------
SELECT  t1.product_id,
        t1.first_year,
        t2.quantity,
        t2.price
FROM (    

        SELECT  product_id, 
                MIN(year) AS first_year
        FROM Sales
        GROUP BY product_id
        ) t1 
INNER JOIN Sales t2 
ON t1.product_id = t2.product_id
AND t1.first_year = t2.year



-----------------------------------------------------------------------------------------------------
--511. Game Play Analysis I
-----------------------------------------------------------------------------------------------------
SELECT  player_id,
        MIN(event_date) AS first_login
FROM Activity
GROUP BY player_id
;


-----------------------------------------------------------------------------------------------------
--512. Game Play Analysis II
-----------------------------------------------------------------------------------------------------
SELECT player_id,
        device_id
FROM Activity
WHERE (player_id, event_date) 
IN (
    SELECT player_id, MIN(event_date)
    FROM Activity
    GROUP BY player_id
    )
;


-----------------------------------------------------------------------------------------------------
--534. Game Play Analysis III
-----------------------------------------------------------------------------------------------------
SELECT  t1.player_id,
        t1.event_date,
        SUM(t2.games_played) AS games_played_so_far
FROM Activity t1 
LEFT JOIN Activity t2 
ON t1.player_id = t2.player_id
AND t1.event_date >= t2.event_date
GROUP BY t1.player_id,
         t1.event_date
;
      

-----------------------------------------------------------------------------------------------------
--550. Game Play Analysis IV
-----------------------------------------------------------------------------------------------------

SELECT  ROUND(COUNT(DISTINCT t2.player_id)/COUNT(DISTINCT t1.player_id),2) AS fraction
FROM (
        SELECT  player_id,
                MIN(event_date) AS first_login
        FROM Activity
        GROUP BY player_id
        ) t1 
LEFT JOIN Activity t2 
ON t1.player_id = t2.player_id 
AND DATEDIFF(t1.first_login,t2.event_date) = -1 
;




View Code SELECT [DT],[R1],[R2],[R3],[R4]
FROM
(
    SELECT [Rid],[DT],[Hits] FROM [dbo].[RecordHits]
) AS p
PIVOT
(
    SUM([Hits]) FOR [RId] IN ([R1],[R2],[R3],[R4])
) AS Q;



SELECT t1.DT, 
FROM (

        SELECT Rid, DT, Hites
        FROM RecordHits
        ) AS t1 

PIVOT (

        SELECT SUM(Hits) AS Hits 
        FOR Rid IN ([R1], [R2], [R3], [R4])
        ) AS t2 


