/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\01 - SEQUENCE - Sequence One Table.sql */
USE Throwaway
GO

IF OBJECT_ID ('dbo.seq_Test', 'SO') IS NOT NULL
    DROP SEQUENCE dbo.seq_Test;
GO

IF OBJECT_ID ('dbo.Seq_Tester', 'U') IS NOT NULL
    DROP TABLE dbo.Seq_Tester;
GO

CREATE SEQUENCE seq_Test AS INTEGER 
    START WITH 20
    INCREMENT BY 5
    MINVALUE 15
    MAXVALUE 50
    CYCLE
    CACHE 2;
GO

CREATE TABLE Seq_Tester (
  ID            INT IDENTITY(1,1)   NOT NULL PRIMARY KEY,
  Sequence_Num  INT                 NOT NULL)
GO

INSERT INTO Seq_Tester (Sequence_Num)
VALUES (NEXT VALUE FOR seq_Test)
GO 10

SELECT * FROM Seq_Tester
GO

SELECT name ,
       current_value ,
       start_value ,
       increment , 
       minimum_value , 
       maximum_value , 
       is_cycling, 
       is_cached ,
       cache_size
FROM   sys.sequences
GO

GO

USE Throwaway
GO

IF OBJECT_ID ('dbo.seq_Test', 'SO') IS NOT NULL
    DROP SEQUENCE dbo.seq_Test;
GO
IF OBJECT_ID ('dbo.Seq_Tester_1', 'U') IS NOT NULL
    DROP TABLE dbo.Seq_Tester_1;
GO
IF OBJECT_ID ('dbo.Seq_Tester_2', 'U') IS NOT NULL
    DROP TABLE dbo.Seq_Tester_2;
GO
IF OBJECT_ID ('dbo.Seq_Tester_3', 'U') IS NOT NULL
    DROP TABLE dbo.Seq_Tester_3;
GO

CREATE SEQUENCE seq_Test AS INTEGER 
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 20
    CYCLE
    CACHE 25;
GO

CREATE TABLE Seq_Tester_1 (
  ID            INT IDENTITY(1,1)   NOT NULL PRIMARY KEY,
  Sequence_Num  INT                 NOT NULL)
GO
CREATE TABLE Seq_Tester_2 (
  ID            INT IDENTITY(1,1)   NOT NULL PRIMARY KEY,
  Sequence_Num  INT                 NOT NULL)
GO
CREATE TABLE Seq_Tester_3 (
  ID            INT IDENTITY(1,1)   NOT NULL PRIMARY KEY,
  Sequence_Num  INT                 NOT NULL)
GO

INSERT INTO Seq_Tester_1 (Sequence_Num)
VALUES (NEXT VALUE FOR seq_Test)

INSERT INTO Seq_Tester_2 (Sequence_Num)
VALUES (NEXT VALUE FOR seq_Test)

INSERT INTO Seq_Tester_3 (Sequence_Num)
VALUES (NEXT VALUE FOR seq_Test)
GO 10

SELECT * FROM Seq_Tester_1
SELECT * FROM Seq_Tester_2
SELECT * FROM Seq_Tester_3
GO

SELECT name ,
       current_value ,
       start_value ,
       increment , 
       minimum_value , 
       maximum_value , 
       is_cycling, 
       is_cached ,
       cache_size
FROM   sys.sequences
GO

GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\03 - sp_describe_first_result_set - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- default
sp_describe_first_result_set N'SELECT TOP 50 * FROM Posts'
GO

-- @browse_information_mode comparison
sp_describe_first_result_set N'SELECT TOP 50 Id FROM Posts', NULL, @browse_information_mode = 0
GO
sp_describe_first_result_set N'SELECT TOP 50 Id FROM Posts', NULL, @browse_information_mode = 1
GO
sp_describe_first_result_set N'SELECT TOP 50 Id FROM Posts', NULL, @browse_information_mode = 2
GO

-- With a stored procedure
sp_describe_first_result_set N'usp_Get_Top_Posts ',NULL, @browse_information_mode = 1
GO

GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\04 - WITH RESULT SETS - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- Description of the sp resultset
sp_describe_first_result_set N'usp_Get_Top_Posts ',NULL, @browse_information_mode = 1
GO

-- 
EXEC usp_Get_Top_Posts WITH RESULT SETS
(
    (
        Post_ID         INTEGER ,
        Post_Title      VARCHAR(250) ,
        Date_Created    DATETIME2
    )
)
GO

GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\05 - OFFSET FETCH - SO - Demo.sql */
-- OFFSET and FETCH

USE StackOverflow_Aug2011
GO
-- 100 years 
-- Get first five rows
SELECT   DateFull ,
         DateKey
FROM     DateLookup
ORDER BY DateFull
OFFSET 0 ROWS
FETCH NEXT 5 ROWS ONLY
GO

-- Get next 5 rows
SELECT   DateFull ,
         DateKey
FROM     DateLookup
ORDER BY DateFull 
OFFSET 5 ROWS
FETCH NEXT 5 ROWS ONLY

-- Look ma, expressions
-- Get last five rows
SELECT    *
FROM      DateLookup
ORDER BY  DateFull
OFFSET (SELECT COUNT(*)- 5 FROM DateLookup)  ROWS
FETCH NEXT 5 ROWS ONLY


-- Get the second year of dates in the table
SELECT   DateFull ,
         DateKey
FROM     DateLookup
ORDER BY DateFull 
OFFSET 366 ROWS  -- 2000 was a leap year
FETCH NEXT (SELECT COUNT(*) FROM DateLookup) / 100 ROWS ONLY

GO

/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\06 - OVER - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- ROWNUMBER Ranking function
SELECT   dl.DateFull ,
         ROW_NUMBER() OVER (ORDER BY dl.DateFull) AS RowNum
FROM     DateLookup dl
WHERE    dl.FullYear = 2001

-- PARTITION BY
SELECT   dl.DateFull ,
         ROW_NUMBER() 
           OVER (PARTITION BY dl.MonthNumber 
                 ORDER BY dl.DateFull) AS RowNum
FROM     DateLookup dl
WHERE    dl.FullYear = 2001

-- OVER with Aggregate Function
SELECT   dl.DateFull ,
         MAX(dl.DateFull) 
           OVER (PARTITION BY dl.MonthNumber 
                 ORDER BY dl.FullYear) AS MaxMonth
FROM     DateLookup dl
WHERE    dl.FullYear = 2001

GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\07 - LAGLEAD - AW - Sales by Person.sql */
    USE AdventureWorks2012;
GO

-- 1) Show LAG with Default
-- Get Sales by Person
SELECT    BusinessEntityID , 
          FirstName + ' ' + LastName AS Name , 
          TerritoryName , 
          SalesYTD , 
          LAG (SalesYTD) 
            OVER (ORDER BY SalesYTD DESC) AS PrevRepSales 
FROM      Sales.vSalesPerson
WHERE     TerritoryName IN (N'Northwest', N'Canada') 
ORDER BY  SalesYTD DESC;

-- LEAD
-- 2) Modify and show LAG with Offset 2
-- 3) Modify and show LAG with Default 0
SELECT    BusinessEntityID , 
          FirstName + ' ' + LastName AS Name , 
          TerritoryName , 
          SalesYTD , 
          LEAD (SalesYTD, 2, 0) 
            OVER (ORDER BY SalesYTD DESC) AS NextRepSales
FROM      Sales.vSalesPerson
WHERE     TerritoryName IN (N'Northwest', N'Canada') 
ORDER BY  SalesYTD DESC;

-- 4) Show PARTITION BY 
SELECT    BusinessEntityID , 
          FirstName + ' ' + LastName AS Name , 
          TerritoryName , 
          SalesYTD , 
          LAG (SalesYTD, 1, 0) 
            OVER (PARTITION BY TerritoryName ORDER BY SalesYTD DESC) AS PrevRepSales
FROM      Sales.vSalesPerson
WHERE     TerritoryName IN (N'Northwest', N'Canada') 
ORDER BY  TerritoryName;
GO

/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\08 - LAGLEAD - SO - Average Days To Answer.sql */
USE StackOverflow_Aug2011
GO

-- Average Days to answer by month


-- Old, busted, stanky way to do Lag
SELECT    AVG(pa.DaysToAnswer) AS AvgDaysToAnswer,
          COUNT(pa.CreationDate) As QuestionCount ,
          MONTH(pa.CreationDate) AS MonthNumber , 
          YEAR(pa.CreationDate) AS FullYear ,
          prev_pa.AvgDaysToAnswer AS PrevMonthDaysToAnswer 
FROM      vw_PostAnswer pa
LEFT JOIN (
  SELECT    AVG(pa.DaysToAnswer) AS AvgDaysToAnswer,
            COUNT(pa.CreationDate) AS QuestionCount ,
            MONTH(pa.CreationDate) AS MonthNumber ,
            DATEPART(m, DATEADD(m, 1, pa.CreationDate)) AS NextMonthNum , 
            DATEPART(yy, DATEADD(m, 1, pa.CreationDate)) AS NextYearNum ,
            YEAR(pa.CreationDate) AS FullYear 
  FROM      vw_PostAnswer pa
  GROUP BY  MONTH(pa.CreationDate) , 
            YEAR(pa.CreationDate) ,
            DATEPART(m, DATEADD(m, 1, pa.CreationDate)) ,
            DATEPART(yy, DATEADD(m, 1, pa.CreationDate))
)  prev_pa  ON  MONTH(pa.CreationDate) = prev_pa.NextMonthNum
            AND YEAR(pa.CreationDate) = prev_pa.NextYearNum
GROUP BY  MONTH(pa.CreationDate) , 
	      YEAR(pa.CreationDate) ,
          prev_pa.AvgDaysToAnswer
ORDER BY  YEAR(pa.CreationDate) , 
	      MONTH(pa.CreationDate)

-- 543188
-- New shiny LAG function
SELECT    AVG(pa.DaysToAnswer) ,
          COUNT(pa.CreationDate) QuestionCount ,
          MONTH(pa.CreationDate) AS MonthNumber , 
          YEAR(pa.CreationDate) AS FullYear ,
          LAG(AVG(pa.DaysToAnswer), 1) 
            OVER (ORDER BY YEAR(pa.CreationDate), MONTH(pa.CreationDate)) AS PrevMonthDaysToAnswer 
FROM      vw_PostAnswer pa
GROUP BY  MONTH(pa.CreationDate) , 
	      YEAR(pa.CreationDate) 
ORDER BY  YEAR(pa.CreationDate) , 
	      MONTH(pa.CreationDate)




GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\09 - FIRST_VALUE LAST_VALUE - AW - Demo.sql */
USE AdventureWorks2012;
GO

-- 1) FIRST_VALUE, LAST_VALUE
-- Get Sales by Person
SELECT    BusinessEntityID , 
          FirstName + ' ' + LastName AS Name , 
          TerritoryName , 
          SalesYTD , 
          FIRST_VALUE (SalesYTD) 
            OVER (ORDER BY SalesYTD DESC) AS FirstSales
FROM      Sales.vSalesPerson
WHERE     TerritoryName IN (N'Northwest', N'Canada') 
ORDER BY  SalesYTD DESC;

-- PARTITION BY with a wut
SELECT    BusinessEntityID , 
          FirstName + ' ' + LastName AS Name , 
          TerritoryName , 
          SalesYTD , 
          FIRST_VALUE (SalesYTD) 
            OVER (PARTITION BY TerritoryName ORDER BY SalesYTD DESC) AS FirstSales ,
          LAST_VALUE (SalesYTD) 
            OVER (PARTITION BY TerritoryName ORDER BY SalesYTD DESC) AS LastSales 
FROM      Sales.vSalesPerson
WHERE     TerritoryName IN (N'Northwest', N'Canada') 
ORDER BY  TerritoryName;

-- Need to set the window frame
SELECT    BusinessEntityID , 
          FirstName + ' ' + LastName AS Name , 
          TerritoryName , 
          SalesYTD , 
          FIRST_VALUE (SalesYTD) 
            OVER (PARTITION BY TerritoryName ORDER BY SalesYTD DESC) AS FirstSales ,
          LAST_VALUE (SalesYTD) 
            OVER (PARTITION BY TerritoryName ORDER BY SalesYTD DESC
                  ROWS BETWEEN UNBOUNDED PRECEDING
                  AND UNBOUNDED FOLLOWING) AS LastSales 
FROM      Sales.vSalesPerson
WHERE     TerritoryName IN (N'Northwest', N'Canada') 
ORDER BY  TerritoryName;
GO

/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\10 - PERCENT_RANK - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- PERCENT_RANK
-- Calculates a relative rank of a row.
-- (RANK() – 1) / (Total Rows – 1)
SELECT Id,
       p.Title ,
       p.AnswerCount ,
       PERCENT_RANK() 
         OVER (ORDER BY p.AnswerCount Desc) PercentRank
FROM   Posts p
WHERE  p.Id IN (723195, 686724, 144283, 42648, 1221559, 56628)
GO

-- Can we do this manually? Yup.
-- (RANK() – 1) / (Total Rows – 1)
SELECT Id,
       p.Title ,
       p.AnswerCount ,
       RANK() OVER (Order by p.AnswerCount DESC) AS AnsRank ,
       COUNT(*) OVER () AS AnsCount ,
       CONVERT(float(53), 
       (RANK() OVER (Order by p.AnswerCount DESC) - 1.0) / (COUNT(*) OVER () - 1.0) ) AS ManPerRank,
       PERCENT_RANK() OVER (ORDER BY p.AnswerCount Desc) AnsPerRank
FROM   Posts p
WHERE  p.Id IN (723195, 686724, 144283, 42648, 1221559, 56628)


GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\11 - CUME_DIST - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- CUME_DIST
-- Calculates the percentage of values less than or equal to the current value in the group.
SELECT Id,
       p.Title ,
       p.AnswerCount ,
       CUME_DIST() OVER (ORDER BY p.AnswerCount) AS CumeDist
FROM   Posts p
WHERE  p.Id IN (723195, 686724, 144283, 42648, 1221559, 56628, 64981, 10616, 580, 2018)
GO

-- Manual Calculation? TRUE.
-- COUNT(*) OVER (ORDER BY Col1) / Total Count
SELECT Id,
       p.Title ,
       p.AnswerCount ,
       COUNT(*) OVER (ORDER BY p.AnswerCount) CountOver,
       COUNT(*) OVER () AS TotalCount,
       COUNT(*) OVER (ORDER BY p.AnswerCount) / CONVERT(float(53), COUNT(*) OVER ()) ManCumeDist,
       CUME_DIST() OVER (ORDER BY p.AnswerCount) AS CumeDist
FROM   Posts p
WHERE  p.Id IN (723195, 686724, 144283, 42648, 1221559, 56628, 64981, 10616, 580, 2018)
GO

GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\12 - PERCENTILE_CONT PERCENTILE_DISC - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- What's the median?
SELECT   Id,
         p.Title ,
         p.AnswerCount 
FROM     Posts p
WHERE    p.Id IN (723195, 686724, 144283, 42648, 1221559, 56628, 64981, 10616, 580, 2018)
ORDER BY p.AnswerCount
GO

-- PERCENTILE_CONT PERCENTILE_DISC
SELECT Id,
       p.Title ,
       p.AnswerCount ,
       CUME_DIST() OVER (ORDER BY p.AnswerCount)  CumeDist,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.AnswerCount) OVER () PerCont,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY p.AnswerCount) OVER () PerDisc
FROM   Posts p
WHERE  p.Id IN (723195, 686724, 144283, 42648, 1221559, 56628, 64981, 10616, 580, 2018)
GO

GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\13 - PARSE TRY_PARSE TRY_CONVERT - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- PARSE 

-- Change VARCHAR to a datetime2
SELECT CAST('Saturday, June 16 2012' AS DATETIME2) AS Result
GO

SELECT CONVERT (DATETIME2, 'Saturday, June 16 2012') AS Result
GO

SELECT PARSE('Saturday, June 16 2012' AS DATETIME2) AS Result
GO

-- Convert string to int. Will it blend?
SELECT CONVERT(INT, '100.000')
GO

SELECT PARSE('100.000' AS INT)
GO

-- TRY_PARSE - Like PARSE but if an error occurs returns NULL
SELECT PARSE('A100.000' AS INT)
GO

SELECT TRY_PARSE('A100.000' AS INT)
GO

-- TRY_CONVERT
SELECT CONVERT(INT, 'A100')
GO

SELECT TRY_CONVERT(INT, 'A100')
GO

/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\14 - IIF - SO - DEMO.sql */
USE StackOverflow_Aug2011
GO

--SET SHOWPLAN_TEXT ON
--SET SHOWPLAN_TEXT OFF

-- IIF
SELECT   u.Id ,
         u.DisplayName ,
         u.Age ,
         IIF (u.Age >= 40, '40 or over', 'Under 40') AS AgeBracket
FROM     Users u
WHERE    DisplayName IN ('Jeff Atwood' , 
                         'Joel Spolsky' ,
                         'Jorriss' ,
                         'Jon Skeet',
                         'cecilphillip')
GO

-- Same thing but using CASE
SELECT   u.Id ,
         u.DisplayName ,
         u.Age ,
         CASE 
           WHEN u.Age >=40 THEN '40 or Over' 
           ELSE 'Under 40' 
         END AS AgeBracket
FROM     Users u
WHERE    DisplayName IN ('Jeff Atwood' , 
                         'Joel Spolsky' ,
                         'Jorriss' ,
                         'Jon Skeet',
                         'cecilphillip')
GO


-- Embedded IIFs. 
SELECT   u.Id ,
         u.DisplayName ,
         u.Age ,
         IIF (u.Age >= 40, '40 or Over', 
           IIF (u.Age < 30, 'Under 30', 'Between 30 and 39'))  AS AgeBracket
FROM     Users u
WHERE    DisplayName IN ('Jeff Atwood' , 
                         'Joel Spolsky' ,
                         'Jorriss' ,
                         'Jon Skeet',
                         'cecilphillip')
GO



GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\15 - CHOOSE - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- CHOOSE uses an index to select a value.
SELECT CHOOSE(2, 'Luke', 'Yoda', 'Obi-Wan') As Jedi
GO

-- Index 0 is out of bounds
SELECT CHOOSE(0, 'Luke', 'Yoda', 'Obi-Wan') As Jedi
GO

-- Index 4 is out of bounds
SELECT CHOOSE(4, 'Luke', 'Yoda', 'Obi-Wan') As Jedi
GO

-- Careful with your return datatypes
SELECT CHOOSE(1, CONVERT(datetime2, '12/1/2012'), 'Yoda', 'Obi-Wan') As Jedi
GO

SELECT CHOOSE(2, CONVERT(datetime2, '12/1/2012'), 'Yoda', 'Obi-Wan') As Jedi
GO


-- Use table value 
SELECT dl.DateFull ,
       dl.WeekDayName ,
       dl.WeekDay ,
       CHOOSE(dl.WeekDay, 'PLAY', 'Work', 'Work', 'Work', 'Work', 'Work', 'SQL SATURDAY') AS WorkOrPlay
FROM   DateLookup dl
WHERE  dl.DateFull < '2/1/2000'
GO

/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\16 - EOMONTH - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- To get the last day in the month we used to have to do this.
SELECT DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, '6/18/2012') + 1, 0)) 
GO

-- Yup, that was a hassle. Better to do it this way
SELECT EOMONTH('6/18/2012')
GO

-- But does it know about leap year?
SELECT EOMONTH('2/1/2011') AS Feb2011 ,
       EOMONTH('2/1/2012') AS Feb2012 ,
       EOMONTH('2/1/2013') AS Feb2013
GO 

-- Last day of next month
SELECT EOMONTH('6/18/2012', 1)
GO

-- Last day of previous month
SELECT EOMONTH('6/18/2012', - 1)
GO
GO

/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\17 - FROMPARTS - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- FROMPARTS Family
SELECT DATEFROMPARTS (2012,6,18) AS Result;
SELECT DATETIME2FROMPARTS (2012,6,18,23,59,59,0,0) AS Result;
SELECT DATETIMEFROMPARTS (2012,6,18,23,59,59,0) AS Result;
SELECT DATETIMEOFFSETFROMPARTS (2012,6,18,14,23,23,0,12,0,7) AS Result;
SELECT SMALLDATETIMEFROMPARTS (2012,6,18,23,59) AS Result
SELECT TIMEFROMPARTS (23,59,59,0,0) AS Result;
GO

/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\18 - CONCAT - SO - Demo.sql */

USE StackOverflow_Aug2011
GO

-- Old way
SELECT 'Dave ' + 'Nicolas ' + '2013'
GO

-- CONCAT 
SELECT CONCAT('Dave ', 'Nicolas ', '2013')
GO

-- Old Way with different data types
SELECT 'Dave '+ 'Nicolas ' + 2013
GO

-- CONCAT with different data types
SELECT CONCAT('Dave ', 'Nicolas ', 2013)
GO

-- Old way..NULLS?
SELECT 'Dave ' + 'Nicolas ' + NULL
GO

-- We don't need no stinkin NULLs
SELECT CONCAT('Dave ', 'Nicolas ', NULL)
GO

-- CONCAT with a table
SELECT u.DisplayName ,
       u.WebsiteUrl ,
       CONCAT(u.DisplayName, '-', u.WebsiteUrl) AS NameURL
FROM   Users u
WHERE    DisplayName IN ('Jeff Atwood' , 
                         'Joel Spolsky' ,
                         'Jorriss' ,
                         'Jon Skeet',
                         'cecilphillip')
GO
       
GO
/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\19 - FORMAT - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- Current Date
SELECT FORMAT(GETDATE(), 'MM-dd-yyyy') as CurrDate
GO

-- Current Date with time
SELECT FORMAT(GETDATE(), 'MM-dd-yyyy h:mm:ss tt') as CurrDate
GO

-- What cha know about the day of the week?
SELECT FORMAT(GETDATE(), 'dddd, MMMM d, yyyy') as CurrDate
GO

-- This is a refined function it has culture
SELECT FORMAT(GETDATE(), 'd', 'es-MX') as CurrDate
GO

-- One Meeelion Dollars
SELECT FORMAT(1000000, '$###,###,#0.00') as OneMeeelion
GO

-- Percentage
SELECT FORMAT(.5025, '0.0000%') as Percent_Format
GO

-- Social Experiment
SELECT FORMAT(123456789, '###-##-####')
GO

-- Jenny
SELECT FORMAT(3058675309, '(000)000-0000')
GO

/* C:\users\rrump\Dropbox\My Documents\Presentations\TSQL in 2012\Code\Scripts\20 - THROW - SO - Demo.sql */
USE StackOverflow_Aug2011
GO

-- 2005/2008 way to handle errors
BEGIN TRY
  DECLARE @VarToTest INT
  SET @VarToTest = 'Jorriss'
END TRY
BEGIN CATCH
  DECLARE @ErrorMessage NVARCHAR(4000) 
  DECLARE @ErrorSeverity INT
 
  SET @ErrorMessage = ERROR_MESSAGE()
  SET @ErrorSeverity = ERROR_SEVERITY()
 
  RAISERROR (@ErrorMessage, @ErrorSeverity, 1)
END CATCH
GO

 -- If you're going to play CATCH you have to THROW
BEGIN TRY
  DECLARE @VarToTest INT
  SET @VarToTest = 'Jorriss'
END TRY
BEGIN CATCH
  THROW
END CATCH
GO
GO
