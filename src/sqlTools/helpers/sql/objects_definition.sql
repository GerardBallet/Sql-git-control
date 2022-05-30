SELECT 
OBJECT_DEFINITION(a.object_id) as object_definition,
b.name as [schema],
a.name as [object]
FROM sys.objects a
left join sys.schemas b
on a.schema_id=b.schema_id
WHERE type  IN (${0})