/*
   Saturday, March 3, 201810:29:43 AM
   User: sa
   Server: 172.22.195.252
   Database: mytest
   Application: 
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.harvardActivity
	(
	id int NOT NULL IDENTITY (1, 1),
	activityName varchar(50) NOT NULL,
	calories125 decimal(6, 0) NOT NULL,
	calories155 decimal(6, 0) NOT NULL,
	calories185 decimal(6, 0) NOT NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Calories expended in 30 minutes for each weight (lb) for each activity type'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'harvardActivity', NULL, NULL
GO
ALTER TABLE dbo.harvardActivity ADD CONSTRAINT
	PK_harvardActivity PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.harvardActivity SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
