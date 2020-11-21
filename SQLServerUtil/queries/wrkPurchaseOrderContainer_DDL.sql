USE [PurchaseOrderContainer]
GO

/****** Object:  Table [dbo].[PurchaseOrderContainer_TEMP_KED]    Script Date: 5/11/2020 9:19:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS
(
	SELECT *
	FROM sys.tables t
	  INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
	WHERE t.name = 'wrkPurchaseOrderContainer'
	  AND s.name = 'dbo'
)
BEGIN
	DROP TABLE dbo.wrkPurchaseOrderContainer
END
	  

CREATE TABLE [dbo].[wrkPurchaseOrderContainer](
	[PurchaseOrderContainerID] [bigint] NULL,
	[PurchaseOrderNum] [varchar](10) NOT NULL,
	[ContainerNum] [varchar](20) NOT NULL,
	[ItemNum] [varchar](15) NOT NULL,
	[DeliveryDate] [smalldatetime] NOT NULL,
	[CaseCount] [int] NULL,
	[OriginalAddDate] [smalldatetime] NULL,
	[OriginalAddMachineName] [varchar](50) NULL,
	[OriginalAddUsername] [varchar](30) NULL,
	[LastChangeDate] [smalldatetime] NULL,
	[LastChangeUsername] [varchar](30) NULL,
	[ItemQuantity] [int] NULL,
	[HouseBOL] [varchar](25) NULL,
	[MasterBOL] [varchar](25) NULL
) ON [PRIMARY]
GO


