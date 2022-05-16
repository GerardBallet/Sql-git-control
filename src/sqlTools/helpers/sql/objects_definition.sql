SELECT 
OBJECT_DEFINITION(object_id) as object_definition,
  name
FROM sys.objects
WHERE type  IN (${0})