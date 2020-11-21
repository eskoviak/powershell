--SELECT *
--FROM PurchaseOrderContainer
--WHERE PurchaseOrderNum = '3444422'
--  AND ContainerNum = 'UESU4135050'
--  AND ItemNum = '83615D 105'

--SELECT DISTINCT PurchaseOrderNum from wrkPurchaseOrderContainer;

DECLARE
		@PurchaseOrderNum CHAR(10)
	    , @PurchaseOrderNum1 CHAR(10)
;

DECLARE helper_cursor CURSOR FOR
  SELECT DISTINCT PurchaseOrderNum from wrkPurchaseOrderContainer;

OPEN helper_cursor;
FETCH NEXT FROM helper_cursor
  INTO @PurchaseOrderNum;

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @PurchaseOrderNum1 = PurchaseOrderNum
	FROM PurchaseOrderContainer
	WHERE PurchaseOrderNum = @PurchaseOrderNum;

	PRINT @PurchaseOrderNum
	PRINT @PurchaseOrderNum1

	FETCH NEXT FROM helper_cursor
      INTO @PurchaseOrderNum;
END


CLOSE helper_cursor;
DEALLOCATE helper_cursor;

SELECT *
FROM PurchaseOrderContainer
WHERE LastChangeDate > '05/01/2020';

SELECT COUNT(*)
FROM PurchaseOrderContainer

--HERE--
CREATE TABLE wrkPOStatus (
  PurchaseOrderNum char(10) NULL,
  ItemNum varchar(15) NULL,
  ContainerCount int NULL,
  IAPUNO nchar(10) NULL, 
  IAPUSL nchar(2) NULL, 
  IBITNO nchar(15) NULL, 
  IBPUSL nchar(2) NULL, 
  IBORQA decimal(15,6) NULL, 
  IBRVQA decimal(15,6) NULL
)

INSERT INTO wrkPOStatus ( PurchaseOrderNum, ItemNum, ContainerCount)
  VALUES (
			SELECT DISTINCT poc.PurchaseOrderNum, poc.ItemNum, COUNT(*) AS ContainerCount
			FROM PurchaseOrderContainer poc
			GROUP BY PurchaseOrderNum, ItemNum
			ORDER BY PurchaseOrderNum, ItemNum
		 )

-- Create a lookup table from the current PurchaseOrderContainer, in which the 
drop table wrkPOStatus;
SELECT PurchaseOrderNum, ItemNum, COUNT(*) As ContainerCount, IAPUSL, IBITNO, IBPUSL, IBORQA, IBRVQA
INTO wrkPOStatus
FROM PurchaseOrderContainer,
[M3SQLREPLDEV\REPLDEV].[RWSReplicate].[dbo].MPHEAD 
JOIN [M3SQLREPLDEV\REPLDEV].[RWSReplicate].[dbo].MPLINE ON IBCONO=IACONO AND IBPUNO=IAPUNO
WHERE IACONO='100' AND IAPUNO=PurchaseOrderNum
  AND IAPUSL = '85'
  --AND IBORQA <> IBRVQA
GROUP BY PurchaseOrderNum, ItemNum, IAPUNO, IAPUSL, IBITNO, IBPUSL, IBORQA, IBRVQA
ORDER BY PurchaseOrderNum, ItemNum;
select *
from wrkPOStatus;

SELECT * 
FROM PurchaseOrderContainerArchive
WHERE PurchaseOrderNum = '3446227';
