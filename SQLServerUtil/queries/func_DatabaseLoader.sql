-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ed Skoviak
-- Create date: 5/14/2020
-- Description:	This function processes records in the working table into the live tables
-- =============================================
CREATE FUNCTION DatabaseLoader 
(
	-- Add the parameters for the function here
	 
)
RETURNS int
AS
BEGIN
	DECLARE @RowsProcessed int
		, @PurchaseOrderNum CHAR(10)
		, @ContainerNum VARCHAR(20)
		, @ItemNum VARCHAR(15)
		, @DeliveryDate SMALLDATETIME
		, @CaseCount INT
		, @OriginalAddDate SMALLDATETIME = GetDate()
		, @ArchiveDate SMALLDATETIME = GetDate()
		, @ArchiveMachineName VARCHAR(50) = 'EDSKOV-HP840'
		, @ArchiveUserName VARCHAR(30) = 'EDSKOV'
		, @OriginalAddMachineName VARCHAR(50) = 'EDSKOV-HP840'
		, @OriginalAddUserName VARCHAR(30) = 'EDSKOV'
		, @ItemQuantity INT = NULL
		, @HouseBOL VARCHAR(25) = NULL
		, @MasterBOL VARCHAR(25) = NULL
		, @PurchaseOrderContainerID bigint
		, @runid bigint
		, @runDate datetime
		, @RecsArchived int = 0
		, @RecsUpdated int = 0
		, @ArchRecsUpdated int = 0
		, @RecsInserted int = 0
		;

	-- Setup
	SELECT @runid = MAX(runid)+1 FROM [dbo].runlog;
	SELECT @runDate = GetDate();

	-- ********************************
	-- Stanza 1
	--
	-- Archive closed Purchase Orders
	-- ********************************

	-- Create a Cross Reference Table, wkrPOStatus
	-- Find the POs in PurchaseOrderContainer that have been received and closed in
	-- M3 Replicate (MPHEAD.IAPUSL = '85') 
	drop table wrkPOStatus;
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
		FROM wrkPOStatus

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

	-- ********************************
	-- Stanza 2
	--
	-- Read through the updates uploaded into the wrkPurchaseOrderContainer table
	-- If the item exists in the active, update same if changes have occurred (see WHERE clause),
	-- else if they are in the archive table, then update the archive (same rules).  
	-- Else, must be new--Insert into active
	-- ********************************
	DECLARE wrkPOC_cursor CURSOR
		FOR SELECT PurchaseOrderNum, ContainerNum, ItemNum, DeliveryDate, CaseCount, ItemQuantity, HouseBOL, MasterBOL
		FROM wrkPurchaseOrderContainer;
	OPEN wrkPOC_cursor;

	FETCH NEXT FROM wrkPOC_cursor
	INTO @PurchaseOrderNum, @ContainerNum, @ItemNum, @DeliveryDate, @CaseCount, @ItemQuantity, @HouseBOL, @MasterBOL;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @RowsProcessed = @RowsProcessed + 1;

		-- Case 1:  In active
		IF EXISTS (SELECT 1 FROM PurchaseOrderContainer
			WHERE LTRIM(RTRIM(PurchaseOrderNum)) = @PurchaseOrderNum  
				AND ContainerNum = @ContainerNum
				AND ItemNum= @ItemNum)
			BEGIN
				UPDATE PurchaseOrderContainer
					SET
						DeliveryDate=ISNULL(@DeliveryDate, DeliveryDate)
						, CaseCount=ISNULL(@CaseCount, CaseCount)
						, LastChangeDate=ISNULL(@OriginalAddDate, GetDate())
						, LastChangeUserName=ISNULL(@OriginalAddUserName, SYSTEM_USER)
						, ItemQuantity=ISNULL(@ItemQuantity, ItemQuantity)
						, HouseBOL=ISNULL(@HouseBOL, HouseBOL)
						, MasterBOL=ISNULL(@MasterBOL, MasterBOL)
					WHERE
						LTRIM(RTRIM(PurchaseOrderNum))=@PurchaseOrderNum 
						AND ContainerNum=@ContainerNum
						AND ItemNum=@ItemNum
						AND ((@DeliveryDate IS NOT NULL AND ISNULL(DeliveryDate, '01-01-1900') != @DeliveryDate)
							OR (@CaseCount IS NOT NULL AND ISNULL(CaseCount, 0) != @CaseCount)
							OR (@ItemQuantity IS NOT NULL AND ISNULL(ItemQuantity, 0) != @ItemQuantity)
							OR (@HouseBOL IS NOT NULL AND ISNULL(HouseBOL, '') != @HouseBOL)
							OR (@MasterBOL IS NOT NULL AND ISNULL(MasterBOL, '') != @MasterBOL));
				IF @@RowCount <> 0
					BEGIN
						SELECT @RecsUpdated = @RecsUpdated + 1
						PRINT @PurchaseOrderNum
						PRINT @ItemNum
					END
			END

		-- Case 2: Not active, but in archive
		ELSE IF EXISTS (SELECT 1 FROM PurchaseOrderContainerArchive
			WHERE LTRIM(RTRIM(PurchaseOrderNum))=@PurchaseOrderNum 
				AND ContainerNum=@ContainerNum
				AND ItemNum=@ItemNum)
			BEGIN
				UPDATE PurchaseOrderContainerArchive
					SET
						DeliveryDate=ISNULL(@DeliveryDate, DeliveryDate)
						, CaseCount=ISNULL(@CaseCount, CaseCount)
						, LastChangeDate=ISNULL(@OriginalAddDate, GetDate())
						, LastChangeUserName=ISNULL(@OriginalAddUserName, SYSTEM_USER)
						, ItemQuantity=ISNULL(@ItemQuantity, ItemQuantity)
						, HouseBOL=ISNULL(@HouseBOL, HouseBOL)
						, MasterBOL=ISNULL(@MasterBOL, MasterBOL)
					WHERE
						LTRIM(RTRIM(PurchaseOrderNum))=@PurchaseOrderNum 
						AND ContainerNum=@ContainerNum
						AND ItemNum=@ItemNum
						AND ((@DeliveryDate IS NOT NULL AND ISNULL(DeliveryDate, '01-01-1900') != @DeliveryDate)
							OR (@CaseCount IS NOT NULL AND ISNULL(CaseCount, 0) != @CaseCount)
							OR (@ItemQuantity IS NOT NULL AND ISNULL(ItemQuantity, 0) != @ItemQuantity)
							OR (@HouseBOL IS NOT NULL AND ISNULL(HouseBOL, '') != @HouseBOL)
							OR (@MasterBOL IS NOT NULL AND ISNULL(MasterBOL, '') != @MasterBOL));
				IF @@RowCount <> 0
					BEGIN
						SELECT @ArchRecsUpdated = @ArchRecsUpdated + 1;
					END
			END

		-- Case 3:  Must be new
		ELSE
			BEGIN
				SELECT @PurchaseOrderContainerID = ISNULL(MAX([PurchaseOrderContainerID]) + 1,0)
				FROM PurchaseOrderContainer

				INSERT PurchaseOrderContainer(PurchaseOrderContainerID, PurchaseOrderNum, ContainerNum, ItemNum, DeliveryDate, CaseCount, OriginalAddDate, OriginalAddMachineName, OriginalAddUsername, ItemQuantity, HouseBOL, MasterBOL)
				  Values(@PurchaseOrderContainerID, @PurchaseOrderNum, @ContainerNum, @ItemNum, @DeliveryDate, @CaseCount, @OriginalAddDate, @OriginalAddMachineName, @OriginalAddUsername, @ItemQuantity, @HouseBOL, @MasterBOL)

				SELECT @RecsInserted = @RecsInserted + 1;
			END
		FETCH NEXT FROM wrkPOC_cursor
		INTO @PurchaseOrderNum, @ContainerNum, @ItemNum, @DeliveryDate, @CaseCount, @ItemQuantity, @HouseBOL, @MasterBOL
	END
	CLOSE wrkPOC_cursor;
	DEALLOCATE wrkPOC_cursor;
	INSERT INTO [dbo].[runlog] (runid, runDate, RowsProcessed, RecsArchived, RecsUpdated, ArchRecsUpdated, RecsInserted)
	  VALUES (@runid, @runDate, @RowsProcessed, @RecsArchived, @RecsUpdated, @ArchRecsUpdated, @RecsInserted);

	-- Return the result of the function
	RETURN @RowsProcessed
END
GO

