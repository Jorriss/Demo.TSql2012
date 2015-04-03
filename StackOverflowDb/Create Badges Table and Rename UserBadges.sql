IF OBJECT_ID ('dbo.BadgesTemp', 'U') IS NOT NULL
    DROP TABLE dbo.BadgesTemp;
GO

CREATE TABLE BadgesTemp (
    Id          INTEGER     IDENTITY(1,1)   NOT NULL ,
    Name        VARCHAR(100)                NOT NULL ,
    BadgeTypeId INT                         NOT NULL ,
    CONSTRAINT [PK_BadgesTemp] PRIMARY KEY CLUSTERED ([Id])
)
GO

INSERT INTO BadgesTemp (Name, BadgeTypeId)
SELECT DISTINCT
       b.Name ,
       IIF(t.Id IS NULL, 1, 2)
FROM   Badges b
LEFT JOIN   Tags   t ON b.Name COLLATE Latin1_General_CS_AS = t.Name COLLATE Latin1_General_CS_AS
ORDER BY   b.Name
GO

IF OBJECT_ID ('dbo.Badges', 'U') IS NOT NULL
BEGIN
    IF OBJECT_ID ('dbo.UserBadges', 'U') IS NOT NULL
    BEGIN
        DROP TABLE Badges;
    END
    ELSE
    BEGIN
        EXEC sp_rename 'Badges', 'UserBadges'
        EXEC sp_rename 'IX_Badges_Id_UserId', 'IX_UserBadges_Id_UserId'
        EXEC sp_rename 'PK_Badges', 'PK_UserBadges'
    END
    EXEC sp_rename 'BadgesTemp', 'Badges'
    EXEC sp_rename 'PK_BadgesTemp', 'PK_Badges'
END 
GO
/*
CREATE NONCLUSTERED INDEX IX_Badges_Name ON Badges
    (Name) INCLUDE (Id, BadgeTypeId)
GO
CREATE NONCLUSTERED INDEX IX_Badges_BadgeTypeId ON Badges
    (BadgeTypeId) INCLUDE (Id, Name)
GO
*/

