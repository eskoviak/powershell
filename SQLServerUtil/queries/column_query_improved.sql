SELECT c.name, c.is_identity, st.name,  c.max_length, c.precision, c.scale, c.is_nullable
FROM [Activity].[sys].[tables] t, [Activity].[sys].[columns] c, [Activity].[sys].[systypes] st
WHERE t.name = 'HarvardActivityReference'
  AND c.object_id = t.object_id
  AND st.xusertype = c.system_type_id