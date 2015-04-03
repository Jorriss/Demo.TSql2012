IF OBJECT_ID ('dbo.VoteCounts', 'U') IS NOT NULL
    DROP TABLE dbo.VoteCounts;
GO

CREATE TABLE VoteCounts (
    Id          INT IDENTITY(1,1)   NOT NULL PRIMARY KEY ,
    PostId      INT                 NOT NULL ,
    VoteTypeId  INT                 NOT NULL ,
    VoteCount   INT                 NOT NULL )
GO

INSERT INTO VoteCounts (PostId , VoteTypeId , VoteCount)
SELECT     v.PostId ,
           v.VoteTypeId ,
           COUNT(*)
FROM       Votes v
GROUP BY   v.PostId ,
           v.VoteTypeId

CREATE NONCLUSTERED INDEX IX_VoteCounts_PostId 
    ON VoteCounts (PostId) INCLUDE (VoteTypeId, VoteCount);
GO

CREATE NONCLUSTERED INDEX IX_VoteCounts_VoteTypeId 
    ON VoteCounts (VoteTypeId) INCLUDE (PostId, VoteCount);
GO
