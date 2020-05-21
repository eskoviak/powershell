USE [PurchaseOrderContainer]
GO

/****** Object:  Table [dbo].[runlog]    Script Date: 5/13/2020 9:19:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS
(
	SELECT *
	FROM sys.tables t
	  INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
	WHERE t.name = 'runlog'
	  AND s.name = 'dbo'
)
BEGIN
	DROP TABLE dbo.runlog
END

CREATE TABLE [dbo].[runlog]
(
    runid   bigint  NOT NULL,
    runDate datetime NOT NULL,
    RowsProcessed int NULL,
    RecsArchived int NULL,
    RecsUpdated int null,
    ArchRecsUpdated int null,
    RecsInserted int null
)