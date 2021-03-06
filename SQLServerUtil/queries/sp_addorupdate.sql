USE [PurchaseOrderContainer]
GO
/****** Object:  StoredProcedure [dbo].[PurchaseOrderContainerAddOrUpdate]    Script Date: 5/6/2020 1:13:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER     PROCEDURE [dbo].[PurchaseOrderContainerAddOrUpdate]
		@PurchaseOrderContainerID BIGINT OUTPUT
		, @PurchaseOrderNum CHAR(10) -- M3Upgrade2016 change
		, @ContainerNum VARCHAR(20)
		, @ItemNum VARCHAR(15)
		, @DeliveryDate SMALLDATETIME
		, @CaseCount INT
		, @OriginalAddDate SMALLDATETIME
		, @OriginalAddMachineName VARCHAR(50)
		, @OriginalAddUserName VARCHAR(30)
		, @ItemQuantity INT = NULL
		, @HouseBOL VARCHAR(25) = NULL
		, @MasterBOL VARCHAR(25) = NULL
		
AS
set nocount on

------------------------------------------------------------------------------
-- CHANGE LOG
--
-- RYAKIEF 20160516 M3UPGRADE2016 TFS #31730 Change Purchase Order Number char(7) to char(10)
------------------------------------------------------------------------------

SET @PurchaseOrderNum =  LTRIM(RTRIM(@PurchaseOrderNum))  -- M3Upgrade2016 change. 

--If a match occurs with PONum, ContainerNum, and ItemNum within the POContainer for a new record, update the record in POContainer when the DeliveryDate is >= for the record in ?
IF EXISTS (SELECT 1 FROM PurchaseOrderContainer
		WHERE LTRIM(RTRIM(PurchaseOrderNum)) = @PurchaseOrderNum  
			AND ContainerNum=@ContainerNum
			AND ItemNum=@ItemNum)
			--now update the fields in POContainer
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
								OR (@MasterBOL IS NOT NULL AND ISNULL(MasterBOL, '') != @MasterBOL))

					IF @@RowCount = 0
					BEGIN
						RAISERROR('"SQLCustomError","Duplicate","A Container Already Exists for this Purchase Order and Item Number"',16,1)
					END
					ELSE
					BEGIN
						RAISERROR('"SQLCustomError","Duplicate","A Container Already Exists for this Purchase Order and Item Number - rows were updated"',16,1)
					END
						
					RETURN
				END

--If a match occurs with PONum, ContainerNum, and ItemNum within the POContainerArchive for a new record, update the record in POContainerArchive when the DeliveryDate is >= for the record in ?
IF EXISTS (SELECT 1 FROM PurchaseOrderContainerArchive
		WHERE LTRIM(RTRIM(PurchaseOrderNum))=@PurchaseOrderNum 
			AND ContainerNum=@ContainerNum
			AND ItemNum=@ItemNum)
			--now update the fields in POContainerArchive
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
							OR (@MasterBOL IS NOT NULL AND ISNULL(MasterBOL, '') != @MasterBOL))
					
					IF @@RowCount = 0
					BEGIN
						RAISERROR('"SQLCustomError","Duplicate","An Archived Container Already Exists for this Purchase Order and Item Number"',16,1)
					END
					ELSE
					BEGIN
						RAISERROR('"SQLCustomError","Duplicate","An Archived Container Already Exists for this Purchase Order and Item Number - rows were updated"',16,1)
					END

					RETURN
			END

	
SELECT @PurchaseOrderContainerID = ISNULL(MAX([PurchaseOrderContainerID]) + 1,0)
FROM PurchaseOrderContainer

INSERT PurchaseOrderContainer(PurchaseOrderContainerID, PurchaseOrderNum, ContainerNum, ItemNum, DeliveryDate, CaseCount, OriginalAddDate, OriginalAddMachineName, OriginalAddUsername, ItemQuantity, HouseBOL, MasterBOL)
Values(@PurchaseOrderContainerID, @PurchaseOrderNum, @ContainerNum, @ItemNum, @DeliveryDate, @CaseCount, @OriginalAddDate, @OriginalAddMachineName, @OriginalAddUsername, @ItemQuantity, @HouseBOL, @MasterBOL)

RETURN @@ROWCOUNT

SET NOCOUNT OFF

