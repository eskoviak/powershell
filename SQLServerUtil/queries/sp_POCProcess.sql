-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ed Skovaik
-- Create date: 5/14/2020
-- Description:	Processes the POC inboud
-- =============================================
CREATE PROCEDURE POCProcess 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @PurchaseOrderNum CHAR(10)
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
;
	DECLARE wrkPOC_cursor CURSOR
		FOR SELECT PurchaseOrderNum, ContainerNum, ItemNum, DeliveryDate, CaseCount, ItemQuantity, HouseBOL, MasterBOL
		FROM wrkPurchaseOrderContainer;
	OPEN wrkPOC_cursor;

	FETCH NEXT FROM wrkPOC_cursor
		INTO @PurchaseOrderNum, @ContainerNum, @ItemNum, @DeliveryDate, @CaseCount, @ItemQuantity, @HouseBOL, @MasterBOL;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--SELECT @RowsProcessed = @RowsProcessed + 1;

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
--				IF @@RowCount <> 0
					--BEGIN
						--SELECT @RecsUpdated = @RecsUpdated + 1
						--PRINT @PurchaseOrderNum
						--PRINT @ItemNum
					--END
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
				--IF @@RowCount <> 0
					--BEGIN
						--SELECT @ArchRecsUpdated = @ArchRecsUpdated + 1;
					--END
			END

			-- Case 3:  Must be new
			ELSE
				BEGIN
					SELECT @PurchaseOrderContainerID = ISNULL(MAX([PurchaseOrderContainerID]) + 1,0)
					FROM PurchaseOrderContainer

					INSERT PurchaseOrderContainer(PurchaseOrderContainerID, PurchaseOrderNum, ContainerNum, ItemNum, DeliveryDate, CaseCount, OriginalAddDate, OriginalAddMachineName, OriginalAddUsername, ItemQuantity, HouseBOL, MasterBOL)
					  Values(@PurchaseOrderContainerID, @PurchaseOrderNum, @ContainerNum, @ItemNum, @DeliveryDate, @CaseCount, @OriginalAddDate, @OriginalAddMachineName, @OriginalAddUsername, @ItemQuantity, @HouseBOL, @MasterBOL)

					--SELECT @RecsInserted = @RecsInserted + 1;
				END
			FETCH NEXT FROM wrkPOC_cursor
			INTO @PurchaseOrderNum, @ContainerNum, @ItemNum, @DeliveryDate, @CaseCount, @ItemQuantity, @HouseBOL, @MasterBOL;
	END
	CLOSE wrkPOC_cursor;
	DEALLOCATE wrkPOC_cursor;
	--INSERT INTO [dbo].[runlog] (runid, runDate, RowsProcessed, RecsArchived, RecsUpdated, ArchRecsUpdated, RecsInserted)
	--VALUES (@runid, @runDate, @RowsProcessed, @RecsArchived, @RecsUpdated, @ArchRecsUpdated, @RecsInserted);
END;
