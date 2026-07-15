# Cellphone-Sales-Data-Analysis

## Project Overview

This project focuses on analyzing cellphone sales data using Microsoft SQL Server. The objective is to explore sales performance, customer spending patterns, cellphone models, and manufacturer performance by answering business-related questions using SQL.

## Tools Used

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)

## Database Structure

The database contains the following tables:

- `DIM_MANUFACTURER` - Manufacturer information
- `DIM_MODEL` - Cellphone model and price information
- `DIM_CUSTOMER` - Customer information
- `DIM_LOCATION` - Location details
- `DIM_DATE` - Date information
- `FACT_TRANSACTIONS` - Sales transaction data

## SQL Concepts Used

- INNER JOIN
- GROUP BY
- Aggregate Functions
- Subqueries
- Common Table Expressions (CTEs)
- Window Functions
- DENSE_RANK()
- LAG()
- INTERSECT
- EXCEPT

## Analysis Performed

The project answers business questions related to:

1. States where customers purchased cellphones from 2005 onwards.
2. The US state with the highest Samsung cellphone sales.
3. Number of transactions for each model by ZIP code and state.
4. The cheapest cellphone model and its price.
5. Average price of models from the top five manufacturers by sales quantity.
6. Customers with an average spending greater than 500 in 2009.
7. Models that ranked in the top five by quantity in 2008, 2009, and 2010.
8. Manufacturers with the second-highest sales in 2009 and 2010.
9. Manufacturers that sold cellphones in 2010 but not in 2009.
10. Analysis of the top 100 customers, including average spending, average quantity, and year-over-year percentage change in spending.

## Project Files

- `Cellphone_Sales_Data_Analysis.sql` - Contains SQL queries used to answer the business questions.
- `Database_Setup.sql` - Contains the database setup script used for the analysis.

## Key Skills Demonstrated

- Data querying and analysis
- Relational database joins
- Sales and customer analysis
- Ranking and year-over-year analysis
- Writing SQL queries to solve business problems

## Author

**Sushant Kumar Singh**

Aspiring Data Analyst | SQL | Excel | Power BI | Python
