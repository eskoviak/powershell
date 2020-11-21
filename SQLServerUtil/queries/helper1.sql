/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [PurchaseOrderNum]
      ,[ContainerNum]
      ,[ItemNum]
      ,[DeliveryDate]
      ,[CaseCount]
      ,[OriginalAddDate]
      ,[OriginalAddMachineName]
      ,[OriginalAddUsername]
      ,[LastChangeDate]
      ,[LastChangeUsername]
      ,[ItemQuantity]
      ,[HouseBOL]
      ,[MasterBOL]
  FROM [PurchaseOrderContainer].[dbo].[PurchaseOrderContainer]


  use PurchaseOrderContainer;
SELECT *
FROM runlog;

insert into runlog (runid, runDate ) values (0, GetDate());
DECLARE @runid int;
SELECT @runid = MAX(runid)+1 FROM runlog;
PRINT @runid;

SELECT [PurchaseOrderNum]
      ,[ContainerNum]
      ,[ItemNum]
      ,[DeliveryDate]
      ,[CaseCount]
      ,[ItemQuantity]
      ,[HouseBOL]
      ,[MasterBOL]
FROM wrkPurchaseOrderContainer
WHERE PurchaseOrderNum = '3452289'
  AND ItemNum LIKE '83636%'
ORDER BY ItemNum

SELECT [PurchaseOrderNum]
      ,[ContainerNum]
      ,[ItemNum]
      ,[DeliveryDate]
      ,[CaseCount]
      ,[ItemQuantity]
      ,[HouseBOL]
      ,[MasterBOL]
FROM PurchaseOrderContainer
WHERE PurchaseOrderNum = '3452289'
  AND ItemNum LIKE '83636%'

SELECT BOTTOM (1000) 
FROM PurchaseOrderContainer;

SELECT *
FROM sys.columns
--WHERE name = 'PurchaseOrderContainer';
WHERE object_id = '2025058250';
