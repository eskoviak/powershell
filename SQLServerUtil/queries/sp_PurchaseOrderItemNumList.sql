USE [PurchaseOrderContainer]
GO
/****** Object:  StoredProcedure [dbo].[PurchaseOrderItemNumList]    Script Date: 5/12/2020 1:01:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- PurchaseOrderContainerLookup 'TESTPON', 'GE193838333', '00202D 100'


ALTER PROCEDURE [dbo].[PurchaseOrderItemNumList]
			
AS
set nocount on

SELECT DISTINCT PurchaseOrderNum, ItemNum, COUNT(*) AS ContainerCount
FROM PurchaseOrderContainer
GROUP BY PurchaseOrderNum, ItemNum
ORDER BY PurchaseOrderNum, ItemNum

SET NOCOUNT OFF