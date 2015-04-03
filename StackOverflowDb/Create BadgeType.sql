IF OBJECT_ID ('dbo.BadgeTypes', 'U') IS NOT NULL
    DROP TABLE dbo.BadgeTypes;
GO

CREATE TABLE BadgeTypes (
    Id      INTEGER     IDENTITY(1,1)   NOT NULL ,
    Type    VARCHAR(100)                NOT NULL ,
    CONSTRAINT [PK_BadgeTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
)
GO

CREATE NONCLUSTERED INDEX IX_BadgeTypes_Name ON BadgeTypes
    (Type) INCLUDE (Id)
GO

INSERT INTO BadgeTypes (Type) VALUES ('General');
INSERT INTO BadgeTypes (Type) VALUES ('Tag');
GO
