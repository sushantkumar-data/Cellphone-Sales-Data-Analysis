-- =====================================================
-- Project: Cellphone Sales Data Analysis
-- Tool: Microsoft SQL Server
-- =====================================================


-- =====================================================
--Q1. List all the states in which we have customers who have bought cellphones  
--from 2005 till today.  
-- =====================================================

SELECT DISTINCT L.State
FROM DIM_LOCATION AS L
INNER JOIN FACT_TRANSACTIONS AS T
    ON L.IDLocation = T.IDLocation
WHERE YEAR(T.Date) >= 2005;


-- =====================================================
--Q2. What state in the US is buying the most 'Samsung' cell phones?   
-- =====================================================

SELECT TOP 1
    L.State
FROM DIM_LOCATION AS L
INNER JOIN FACT_TRANSACTIONS AS T
    ON L.IDLocation = T.IDLocation
INNER JOIN DIM_MODEL AS M
    ON T.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS D
    ON M.IDManufacturer = D.IDManufacturer
WHERE L.Country = 'US'
  AND D.Manufacturer_Name = 'Samsung'
GROUP BY L.State
ORDER BY SUM(T.Quantity) DESC;

-- =====================================================
--Q3. Show the number of transactions for each model per zip code per state.        
-- =====================================================

SELECT
    T.IDModel,L.ZipCode,L.State,
    COUNT(*) AS NumberOfTransactions
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_LOCATION AS L
    ON T.IDLocation = L.IDLocation
GROUP BY T.IDModel,L.ZipCode,L.State
ORDER BY T.IDModel;

-- =====================================================
--Q4. Show the cheapest cellphone (Output should contain the price also) 
-- =====================================================

SELECT TOP 1 Model_Name, Unit_price
FROM DIM_MODEL
ORDER BY Unit_price ASC;


-- =====================================================
--Q5. Find out the average price for each model in the top5 manufacturers in  
-- terms of sales quantity and order by average price.
-- =====================================================

SELECT M.Model_Name,
    AVG(CAST(T.TotalPrice AS DECIMAL(18,2)) / NULLIF(T.Quantity, 0)) AS AveragePrice
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M
    ON T.IDModel = M.IDModel
WHERE M.IDManufacturer IN
(
    SELECT TOP 5 M2.IDManufacturer
    FROM FACT_TRANSACTIONS AS T2
    INNER JOIN DIM_MODEL AS M2
        ON T2.IDModel = M2.IDModel
    GROUP BY M2.IDManufacturer
    ORDER BY SUM(T2.Quantity) DESC
)
GROUP BY M.Model_Name
ORDER BY AveragePrice;

-- =====================================================
--Q6. List the names of the customers and the average amount spent in 2009,  
--where the average is higher than 500 
-- =====================================================

SELECT 
    C.Customer_Name,
    AVG(T.TotalPrice) AS Average_Amount_Spent
FROM DIM_CUSTOMER AS C
INNER JOIN FACT_TRANSACTIONS AS T
    ON C.IDCustomer = T.IDCustomer
WHERE YEAR(T.Date) = 2009
GROUP BY C.Customer_Name
HAVING AVG(T.TotalPrice) > 500;

-- =====================================================	
--Q7. List if there is any model that was in the top 5 in terms of quantity,  
--simultaneously in 2008, 2009 and 2010  
-- =====================================================

SELECT Model_Name
FROM
(
    SELECT TOP 5 M.Model_Name
    FROM FACT_TRANSACTIONS AS T
    INNER JOIN DIM_MODEL AS M
        ON T.IDModel = M.IDModel
    WHERE YEAR(T.Date) = 2008
    GROUP BY M.Model_Name
    ORDER BY SUM(T.Quantity) DESC
) AS Top2008

INTERSECT

SELECT Model_Name
FROM
(
    SELECT TOP 5 M.Model_Name
    FROM FACT_TRANSACTIONS AS T
    INNER JOIN DIM_MODEL AS M
        ON T.IDModel = M.IDModel
    WHERE YEAR(T.Date) = 2009
    GROUP BY M.Model_Name
    ORDER BY SUM(T.Quantity) DESC
) AS Top2009

INTERSECT

SELECT Model_Name
FROM
(
    SELECT TOP 5 M.Model_Name
    FROM FACT_TRANSACTIONS AS T
    INNER JOIN DIM_MODEL AS M
        ON T.IDModel = M.IDModel
    WHERE YEAR(T.Date) = 2010
    GROUP BY M.Model_Name
    ORDER BY SUM(T.Quantity) DESC
) AS Top2010;
	


-- =====================================================
--Q8. Show the manufacturer with the 2nd top sales in the year of 2009 and the  
-- manufacturer with the 2nd top sales in the year of 2010.
-- =====================================================

WITH ManufacturerSales AS
(
    SELECT
        YEAR(T.Date) AS SalesYear,
        D.Manufacturer_Name,
        SUM(T.TotalPrice) AS TotalSales,
        DENSE_RANK() OVER
        (
            PARTITION BY YEAR(T.Date)
            ORDER BY SUM(T.TotalPrice) DESC
        ) AS SalesRank
    FROM FACT_TRANSACTIONS AS T
    INNER JOIN DIM_MODEL AS M
        ON T.IDModel = M.IDModel
    INNER JOIN DIM_MANUFACTURER AS D
        ON M.IDManufacturer = D.IDManufacturer
    WHERE YEAR(T.Date) IN (2009, 2010)
    GROUP BY
        YEAR(T.Date),
        D.Manufacturer_Name
)

SELECT
    SalesYear,
    Manufacturer_Name,
    TotalSales
FROM ManufacturerSales
WHERE SalesRank = 2
ORDER BY SalesYear;


-- =====================================================
--Q9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.
-- =====================================================

SELECT DISTINCT D.Manufacturer_Name
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M
    ON T.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS D
    ON M.IDManufacturer = D.IDManufacturer
WHERE YEAR(T.Date) = 2010

EXCEPT

SELECT DISTINCT D.Manufacturer_Name
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M
    ON T.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS D
    ON M.IDManufacturer = D.IDManufacturer
WHERE YEAR(T.Date) = 2009;

-- =====================================================
--Q10. Find top 100 customers and their average spend, average quantity by each  
--year. Also find the percentage of change in their spend. 
-- =====================================================

WITH Top100Customers AS
(
    SELECT TOP 100 IDCustomer
    FROM FACT_TRANSACTIONS
    GROUP BY IDCustomer
    ORDER BY SUM(TotalPrice) DESC
),
YearlyData AS
(
    SELECT T.IDCustomer, C.Customer_Name,
        YEAR(T.Date) AS SalesYear,
        AVG(T.TotalPrice) AS AverageSpend,
        AVG(CAST(T.Quantity AS DECIMAL(10,2))) AS AverageQuantity
    FROM FACT_TRANSACTIONS AS T
    INNER JOIN DIM_CUSTOMER AS C
        ON T.IDCustomer = C.IDCustomer
    WHERE T.IDCustomer IN
    (
        SELECT IDCustomer
        FROM Top100Customers
    )
    GROUP BY
        T.IDCustomer,
        C.Customer_Name,
        YEAR(T.Date)
),
PreviousYearData AS
(
    SELECT *,
        LAG(AverageSpend) OVER
        (
            PARTITION BY IDCustomer
            ORDER BY SalesYear
        ) AS PreviousYearSpend
    FROM YearlyData
)
SELECT
    IDCustomer,Customer_Name,
    SalesYear, AverageSpend,
    AverageQuantity,
    ((AverageSpend - PreviousYearSpend) * 100.0
        / NULLIF(PreviousYearSpend, 0)) AS PercentageChange
FROM PreviousYearData
ORDER BY IDCustomer, SalesYear;


	