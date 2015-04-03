IF OBJECT_ID ('dbo.usp_Get_Top_Posts', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Get_Top_Posts;
GO


CREATE PROCEDURE usp_Get_Top_Posts (
    @Num_Posts AS INTEGER = 50)
AS 
BEGIN

    SELECT TOP (@Num_Posts)
           p.Id ,
           p.Title ,
           p.CreationDate
    FROM   Posts p
    WHERE  p.PostTypeId = 1

END

