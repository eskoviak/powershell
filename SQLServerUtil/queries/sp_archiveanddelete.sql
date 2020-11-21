USE [PurchaseOrderContainer]
GO
/****** Object:  StoredProcedure [dbo].[PurchaseOrderContainerArchiveAndDelete]    Script Date: 5/13/2020 8:30:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- PurchaseOrderContainerArchiveAndDelete NULL, '3212289', NULL, NULL, '07-05-2007', 'todgirdM', 'todgird'

------------------------------------------------------------------------------
-- CHANGE LOG
--
-- RYAKIEF 20160516 M3UPGRADE2016 TFS #31730 Change Purchase Order Number char(7) to char(10)
------------------------------------------------------------------------------

ALTER     PROCEDURE [dbo].[PurchaseOrderContainerArchiveAndDelete]
		@PurchaseOrderContainerID BIGINT
		, @PurchaseOrderNum CHAR(10) -- M3Upgrade2016 change
		, @ContainerNum VARCHAR(20)
		, @ItemNum VARCHAR(15)
		, @ArchiveDate SMALLDATETIME
		, @ArchiveMachineName VARCHAR(50)
		, @ArchiveUserName VARCHAR(30)
AS
set nocount on

IF @PurchaseOrderNum = '' 
	SET @PurchaseOrderNum = NULL
IF @ContainerNum = '' 
	SET @ContainerNum = NULL
IF @ItemNum = '' 
	SET @ItemNum = NULL
 
IF (@PurchaseOrderContainerID IS NOT NULL OR @PurchaseOrderNum IS NOT NULL OR @ContainerNum IS NOT NULL OR @ItemNum IS NOT NULL)
BEGIN
	INSERT INTO PurchaseOrderContainerArchive
	(PurchaseOrderNum, ContainerNum, ItemNum, DeliveryDate, CaseCount, OriginalAddDate, 
	OriginalAddMachineName, OriginalAddUsername, LastChangeDate, LastChangeUsername, 
	ArchiveDate, ArchiveMachineName, ArchiveUserName, ItemQuantity, HouseBOL, MasterBOL)
	SELECT PurchaseOrderNum, ContainerNum, ItemNum, DeliveryDate
	, CaseCount, OriginalAddDate, OriginalAddMachineName, OriginalAddUsername, LastChangeDate
	, LastChangeUserName, @ArchiveDate, @ArchiveMachineName, @ArchiveUsername, ItemQuantity, HouseBOL, MasterBOL
	FROM PurchaseOrderContainer
	WHERE PurchaseOrderContainerID = ISNULL(@PurchaseOrderContainerID, PurchaseOrderContainerID) 
	AND LTRIM(RTRIM(PurchaseOrderNum)) = ISNULL(LTRIM(RTRIM(@PurchaseOrderNum)), PurchaseOrderNum)  -- M3Upgrade2016 change. 


	AND ContainerNum = ISNULL(@ContainerNum, ContainerNum)
	AND ItemNum = ISNULL(@ItemNum, ItemNum)

	DELETE PurchaseOrderContainer
	WHERE PurchaseOrderContainerID = ISNULL(LTRIM(RTRIM(@PurchaseOrderContainerID)), PurchaseOrderContainerID) 
	AND LTRIM(RTRIM(PurchaseOrderNum)) = ISNULL(LTRIM(RTRIM(@PurchaseOrderNum)), PurchaseOrderNum) -- M3Upgrade2016 change. 


	AND ContainerNum = ISNULL(@ContainerNum, ContainerNum)
	AND ItemNum = ISNULL(@ItemNum, ItemNum)
END

SET NOCOUNT OFF

