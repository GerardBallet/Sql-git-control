set nocount on 

declare @table table ([schema] varchar(1000),[table] varchar(1000),orden int)
;WITH dependencies -- Get object with FK dependencies
AS (
    SELECT FK.TABLE_NAME AS Obj
		,FK.TABLE_SCHEMA AS obj_schema
        , PK.TABLE_NAME AS Depends
		
    FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
    INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK
        ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
    INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK
        ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME

    ), 
no_dependencies -- The first level are objects with no dependencies 
AS (
    SELECT 
        A.name AS Obj,
		B.name AS obj_schema
    FROM sys.objects a
	inner join sys.schemas b
	on a.schema_id=B.schema_id
    WHERE a.name +'.'+b.name NOT IN (SELECT obj+'.'+obj_schema FROM dependencies) --we remove objects with dependencies from first CTE
    AND type = 'U' -- Just tables
	
    ), 
recursiv -- recursive CTE to get dependencies
AS (/*caso 0*/
    SELECT 
		
		 Obj AS [Table]
		, obj_schema AS [Table_schema]
        , CAST('' AS VARCHAR(max)) AS DependsON
        , 0 AS LVL -- Level 0 indicate tables with no dependencies
    FROM no_dependencies
 
    UNION ALL /*Resto*/
 
    SELECT 
			
		d.Obj AS [Table]
		, d.obj_schema AS [Table_schema]
        , CAST(d.Depends AS VARCHAR(max))  -- visually reflects hierarchy
        , R.lvl + 1 AS LVL
    FROM dependencies d
    INNER JOIN recursiv r
        ON d.Depends = r.[Table]
    )

    

    
insert into @table
SELECT DISTINCT 
	R.[Table_schema]
    , R.[Table]  
    , MAX(R.LVL) as orden
FROM recursiv R
group by R.[Table]  , R.[Table_schema]
ORDER BY MAX(R.LVL)
    , R.[Table]
	, R.[Table_schema]


select [schema],[table] from @table  
order by orden