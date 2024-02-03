CREATE TABLE Transactions1 (
    OrderId INT PRIMARY KEY,
    UserId INT,
    City VARCHAR(255),
    Timestamp INT
);

-- Insert 10 records for the year 2022
INSERT INTO Transactions1 (OrderId, UserId, City, Timestamp) VALUES
    (1, 101, 'City1', DATEDIFF(SECOND, '1970-01-01', '2022-01-01 12:00:00')),
    (2, 102, 'City2', DATEDIFF(SECOND, '1970-01-01', '2022-02-15 15:30:00')),
    (3, 103, 'City3', DATEDIFF(SECOND, '1970-01-01', '2022-03-20 08:45:00')),
    (4, 104, 'City4', DATEDIFF(SECOND, '1970-01-01', '2022-04-05 18:20:00')),
    (5, 105, 'City5', DATEDIFF(SECOND, '1970-01-01', '2022-05-10 09:10:00')),
    (6, 106, 'City6', DATEDIFF(SECOND, '1970-01-01', '2022-06-25 14:55:00')),
    (7, 107, 'City7', DATEDIFF(SECOND, '1970-01-01', '2022-07-12 11:30:00')),
    (8, 108, 'City8', DATEDIFF(SECOND, '1970-01-01', '2022-08-03 17:40:00')),
    (9, 109, 'City9', DATEDIFF(SECOND, '1970-01-01', '2022-09-18 20:15:00')),
    (10, 110, 'City10', DATEDIFF(SECOND, '1970-01-01', '2022-10-30 22:00:00'));

select * from Transactions1
-- 1.total order  for each city
SELECT
	City,
	FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM') AS [Month],
    COUNT(orderid) AS OrderCount
FROM
    Transactions1
GROUP BY
    City,
    FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM') 
ORDER BY
    [Month];

--2.CUMMULATIVE NUMBER OF ORDER  MONTHLY
with cte as(SELECT
     FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM') as[month],
	 COUNT(OrderID) AS OrderCount,
	 ROW_NUMBER() OVER(order by COUNT(OrderID)  desc) as RowNum
FROM
    Transactions1
GROUP BY
	FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM')
)
select [month],
		OrderCount,
		SUM(OrderCount) OVER (ORDER BY RowNum) AS CumulativeOrderCount
FROM
    cte
order by
	[month]
----OR
SELECT
     CONVERT(VARCHAR(6), DATEADD(SECOND, Timestamp, '19700101'), 112) AS [month],
	 COUNT(OrderID) AS OrderCount,
	SUM(COUNT(OrderID)) OVER(ORDER BY CONVERT(VARCHAR(6), DATEADD(SECOND, Timestamp, '19700101'), 112))AS culumativeordercount
FROM
    Transactions1
GROUP BY 
	CONVERT(VARCHAR(6), DATEADD(SECOND, Timestamp, '19700101'), 112) ;


----- 3.number of new users monthly
SELECT
	FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM') as[month],
    COUNT(DISTINCT UserID) AS NewUserCount
FROM
    Transactions1
GROUP BY
   FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM')
ORDER BY
    [month];
-----or
---. montly new user 
SELECT 
	months,
	count(UserID) AS NewUserCount
from(
	SELECT UserID,min(FORMAT(dateadd(s,timestamp,'19700101'),'yyyyMM'))AS months
	FROM Transactions1
	group by UserID)AS CH
	group by months;


	
-----4.city with highest number of order each month
WITH MonthlyCityOrderCounts AS (
    SELECT
        FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM') as[month],
        City,
        COUNT(OrderID) AS OrderCount,
        ROW_NUMBER() OVER (PARTITION BY FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM') ORDER BY COUNT(OrderID) DESC) AS RankByOrderCount
    FROM
        Transactions1
    GROUP BY
        FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM'),
        City
)
SELECT
    [month],
    City
FROM
    MonthlyCityOrderCounts
WHERE
    RankByOrderCount = 1;

----or
SELECT [MONTH],city 
 from(SELECT
        CONVERT(VARCHAR(6), DATEADD(SECOND, Timestamp, '19700101'), 112) AS [MONTH],
        City,
		MAX(COUNT(OrderID)) OVER(ORDER BY   CONVERT(VARCHAR(6), DATEADD(SECOND, Timestamp, '19700101'), 112) )as an
	  FROM
        Transactions1
	 GROUP BY 
		City , CONVERT(VARCHAR(6), DATEADD(SECOND, Timestamp, '19700101'), 112))as n
order by [MONTH];



---5. monthly rentension rate 
WITH MonthlyRetention AS (
    SELECT
        CONVERT(VARCHAR(6), DATEADD(SECOND, Timestamp, '19700101'), 112) AS TransactionMonth,
        UserId
    FROM Transactions1
)
SELECT
    t1.TransactionMonth AS Month1,
    t2.TransactionMonth AS Month2,
    COUNT(DISTINCT t1.UserId) AS TransactingUserCount
FROM MonthlyRetention t1
CROSS JOIN MonthlyRetention t2 
GROUP BY
    t1.TransactionMonth,
    t2.TransactionMonth
ORDER BY
    t1.TransactionMonth, t2.TransactionMonth;


-----------
WITH MonthlyRetention AS (
    SELECT
        FORMAT(DATEADD(SECOND, Timestamp,'19700101'), 'yyyyMM')AS TransactionMonth,
        UserId
    FROM Transactions1
)
SELECT
    t1.TransactionMonth AS Month1,
    t2.TransactionMonth AS Month2,
    COUNT(DISTINCT t1.UserId) AS TransactingUserCount
FROM MonthlyRetention t1
CROSS JOIN MonthlyRetention t2 
GROUP BY
    t1.TransactionMonth,
    t2.TransactionMonth
ORDER BY
    t1.TransactionMonth, t2.TransactionMonth;