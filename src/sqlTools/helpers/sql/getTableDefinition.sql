set nocount on 


declare @table_name nvarchar(max)='${0}'
declare @query varchar(max) =''
declare @schema varchar(max)

  SELECT @schema = OBJECT_SCHEMA_NAME(OBJECT_ID)

FROM sys.objects
WHERE type  IN ('U')
and name =@table_name

/* Table main definition*/

set @query ='CREATE TABLE ['+@schema+'].['+  @table_name+'](' +char(13)+char(10)


set @query=@query+(
select replace(replace(STUFF(( 
select a.field+char(13)+char(10) from (
	SELECT 
	CASE  WHEN ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) =1 THEN '' ELSE ','END+
	'['+COLUMN_NAME+'] '+
	'['+DATA_TYPE+']'+
	CASE WHEN DATA_TYPE IN ('char','varchar','nvarchar') then '('+ convert(varchar,CHARACTER_MAXIMUM_LENGTH)+')'
	WHEN DATA_TYPE IN ('decimal') then '('+ convert(varchar, NUMERIC_PRECISION)+','+convert(varchar,NUMERIC_SCALE)+')'
	else '' end+' '+
	case when IS_NULLABLE='YES' then 'NULL' 
	else 'NOT NULL' END as field,ORDINAL_POSITION
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @table_name
	
	) a
	order by ORDINAL_POSITION
FOR XML PATH('')
         ), 1, 0, ''),'&#x0D;',CHAR(13) ),'&gt;','>')  as code)

set @query=@query +')'+char(13)+char(10)+'GO'+char(13)+char(10)

/* primary keys*/
declare @primarykey varchar(max)
declare @clustered varchar(max)

 SELECT top 1      
      @primarykey= i.name 
    -- , c.name AS ColumnName	 
     ,@clustered= i.type_desc  
 FROM sys.objects o
 INNER JOIN sys.indexes i ON i.object_id = o.object_id
 INNER JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id = i.index_id
 INNER JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id = ic.column_id
 INNER JOIN sys.schemas s ON o.schema_id=s.schema_id AND c.column_id = ic.column_id
 WHERE
 i.is_primary_key = 1
 and o.name =@table_name
 

 if @primarykey is not null begin 
  set @query =@query +'ALTER TABLE ['+@schema+'].['+@table_name+']  ADD CONSTRAINT '+@primarykey+' PRIMARY KEY '+case when @clustered='CLUSTERED'then 'CLUSTERED' else '' end+' ('
  
  set @query=@query+(
	select replace(replace(STUFF((
		select a.ColumnName+' ' from (
		  SELECT     
		  case when ROW_NUMBER() over (order by key_ordinal)>1 then ',' else '' end +
			 '['+c.name+']' AS ColumnName,
			 ROW_NUMBER() over (order by key_ordinal) as key_ordinal
	 
		 FROM sys.objects o
		 INNER JOIN sys.indexes i ON i.object_id = o.object_id
		 INNER JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id = i.index_id
		 INNER JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id = ic.column_id
		 INNER JOIN sys.schemas s ON o.schema_id=s.schema_id AND c.column_id = ic.column_id
		 WHERE
		 i.is_primary_key = 1
		 and o.name =@table_name
	 
		 ) a
		order by key_ordinal
		FOR XML PATH('')
         ), 1, 0, ''),'&#x0D;',CHAR(13) ),'&gt;','>'))

	set @query =@query +')'+char(13)+char(10)+'GO'+char(13)+char(10)
 end




/*Deafult values*/

set @query=@query+(
select replace(replace(STUFF(( 
select a.field+char(13)+char(10) +'GO'+char(13)+char(10) from (
select 'ALTER TABLE ['+@schema + '].['+@table_name+'] ADD  DEFAULT '+COLUMN_DEFAULT+' FOR ['+COLUMN_NAME+'] ' as field
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @table_name
	and COLUMN_DEFAULT is not null
	) a	
FOR XML PATH('')
         ), 1, 0, ''),'&#x0D;',CHAR(13) ),'&gt;','>')  as code)



select @query