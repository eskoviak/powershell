USE [PurchaseOrderContainer]
GO
/****** Object:  StoredProcedure [dbo].[POCStage]    Script Date: 5/14/2020 3:33:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ed Skoviak
-- Create date: 5/14/2020
-- Description:	Prepares the POC table
-- =============================================
ALTER PROCEDURE [dbo].[POCStage] 
	-- Add the parameters for the stored procedure here
	@RecsArchived int = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PurchaseOrderNum CHAR(10)
		, @ContainerNum VARCHAR(20)
		, @ItemNum VARCHAR(15)
		, @PurchaseOrderContainerID bigint
		, @ArchiveDate SMALLDATETIME = GetDate()
		, @ArchiveMachineName VARCHAR(50) = 'EDSKOV-HP840'
		, @ArchiveUserName VARCHAR(30) = 'EDSKOV'

		, @DeliveryDate SMALLDATETIME
		, @CaseCount INT
		, @OriginalAddDate SMALLDATETIME = GetDate()
		, @OriginalAddMachineName VARCHAR(50) = 'EDSKOV-HP840'
		, @OriginalAddUserName VARCHAR(30) = 'EDSKOV'
		, @ItemQuantity INT = NULL
		, @HouseBOL VARCHAR(25) = NULL
		, @MasterBOL VARCHAR(25) = NULL
		, @runid bigint
		, @runDate datetime
		, @RowsProcessed int = 0
		, @RecsUpdated int = 0
		, @ArchRecsUpdated int = 0
		, @RecsInserted int = 0
;
	-- Create a Cross Reference Table, wkrPOStatus
	-- Find the POs in PurchaseOrderContainer that have been received and closed in
	-- M3 Replicate (MPHEAD.IAPUSL = '85') 
	DROP TABLE wrkPOStatus;
	SELECT PurchaseOrderNum, ItemNum, COUNT(*) As ContainerCount, IAPUSL, IBITNO, IBPUSL, IBORQA, IBRVQA
	INTO wrkPOStatus
	FROM PurchaseOrderContainer
	  , [M3SQLREPLDEV\REPLDEV].[RWSReplicate].[dbo].MPHEAD 
	  JOIN [M3SQLREPLDEV\REPLDEV].[RWSReplicate].[dbo].MPLINE ON IBCONO=IACONO AND IBPUNO=IAPUNO
	WHERE IACONO='100' AND IAPUNO=PurchaseOrderNum
	  AND IAPUSL = '85'
	GROUP BY PurchaseOrderNum, ItemNum, IAPUNO, IAPUSL, IBITNO, IBPUSL, IBORQA, IBRVQA
	ORDER BY PurchaseOrderNum, ItemNum;

	DECLARE closedPO_cursor CURSOR 
		FOR
			SELECT DISTINCT PurchaseOrderNum
		FROM wrkPOStatus;

	OPEN closedPO_cursor;
	FETCH NEXT FROM closedPO_cursor
	INTO @PurchaseOrderNum;

	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Get all the line items from the POC table ...
		DECLARE po_cursor CURSOR
		FOR
			SELECT PurchaseOrderContainerID, ContainerNum, ItemNum
			FROM PurchaseOrderContainer
			WHERE PurchaseOrderNum = @PurchaseOrderNum;

		OPEN po_cursor;
		FETCH NEXT FROM po_cursor
			INTO @PurchaseOrderContainerID, @ContainerNum, @ItemNum;
	
		-- ... and call the SPROC to move from Active to Archive
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC [dbo].[PurchaseOrderContainerArchiveAndDelete]
				@PurchaseOrderContainerID
				, @PurchaseOrderNum
				, @ContainerNum
				, @ItemNum
				, @ArchiveDate
				, @ArchiveMachineName
				, @ArchiveUserName;

			SELECT @RecsArchived = @RecsArchived + 1;

			FETCH NEXT FROM po_cursor
				INTO @PurchaseOrderContainerID, @ContainerNum, @ItemNum;
		END
		CLOSE po_cursor;
		DEALLOCATE po_cursor;

		FETCH NEXT FROM closedPO_cursor
		  INTO @PurchaseOrderNum;
	END
	CLOSE closedPO_cursor;
	DEALLOCATE closedPO_cursor;
	RETURN
END;