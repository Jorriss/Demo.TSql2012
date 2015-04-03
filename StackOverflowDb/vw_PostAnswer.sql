
IF OBJECT_ID ('dbo.vw_PostAnswer', 'V') IS NOT NULL
DROP VIEW dbo.vw_PostAnswer;
GO

CREATE VIEW dbo.vw_PostAnswer
AS 

SELECT     QuestionId = p.id ,
		   p.Title ,
		   p.PostTypeId ,
		   p.CreationDate ,
		   p.LastActivityDate ,
		   p.LastEditDate ,
		   p.OwnerUserId ,
		   p.ViewCount ,
		   p.CommentCount ,
		   p.FavoriteCount ,
		   p.Tags ,
           AnswerId = p.AcceptedAnswerId ,
		   p.AnswerCount ,
		   AnswerCreationDate = a.CreationDate ,
		   AnswerOwnerUserId = a.OwnerUserId ,
		   DaysToAnswer = DATEDIFF(d, p.CreationDate, a.CreationDate)
FROM       Posts p
LEFT JOIN  Posts a ON p.AcceptedAnswerId = a.Id
WHERE      p.PostTypeId = 1


