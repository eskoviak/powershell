SELECT c.name, c.is_identity, c.system_type_id, c.max_length, c.precision, c.scale, c.is_nullable
FROM PurchaseOrderContainer.[sys].[tables] t, PurchaseOrderContainer.[sys].[columns] c
WHERE t.name = 'PurchaseOrderContainer'
    AND c.object_id = t.object_id

SELECT c.name, c.system_type_id
FROM PurchaseOrderContainer.[sys].[tables] t, PurchaseOrderContainer.[sys].[columns] c
WHERE t.name = 'wrkPurchaseOrderContainer'
    AND c.object_id = t.object_id

SELECT *
FROM sys.columns
WHERE object_id = (SELECT object_id FROM sys.tables WHERE name = 'wrkPurchaseOrderContainer');

SELECT *
FROM wrkPurchaseOrderContainer

SELECT COUNT(DISTINCT ContainerNum)
FROM wrkPurchaseOrderContainer