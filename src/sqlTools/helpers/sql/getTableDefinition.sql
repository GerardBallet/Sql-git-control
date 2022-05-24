set nocount on 


declare @table_name nvarchar(max)='${0}'
declare @query varchar(max) =''
declare @query_aux varchar(max) =''
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
  set @query_aux ='ALTER TABLE ['+@schema+'].['+@table_name+']  ADD CONSTRAINT '+@primarykey+' PRIMARY KEY '+case when @clustered='CLUSTERED'then 'CLUSTERED' else '' end+' ('
  
  set @query_aux=@query_aux+(
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

	set @query_aux =@query_aux +')'+char(13)+char(10)+'GO'+char(13)+char(10)
	set @query =@query +isnull(@query_aux,'')
 end




/*Deafult values*/

set @query_aux=(
select replace(replace(STUFF(( 
select a.field+char(13)+char(10) +'GO'+char(13)+char(10) from (
select 'ALTER TABLE ['+@schema + '].['+@table_name+'] ADD  DEFAULT '+COLUMN_DEFAULT+' FOR ['+COLUMN_NAME+'] ' as field
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @table_name
	and COLUMN_DEFAULT is not null
	) a	
FOR XML PATH('')
         ), 1, 0, ''),'&#x0D;',CHAR(13) ),'&gt;','>')  as code)



set @query_aux=@query_aux+(
select replace(replace(STUFF((
select 'ALTER TABLE ['+main_table_schema+'].['+main_table+']  WITH CHECK ADD  CONSTRAINT ['+a.constraint_name+'] FOREIGN KEY('+a.main_table_cols+')'+char(13)+char(10)+

			'REFERENCES ['+a.ref_table_schema+'].['+a.ref_table+'] ('+a.ref_table_cols+')'+char(13)+char(10)+
			case when a.update_referential_action >0 then 'ON UPDATE '+a.update_referential_action_desc+char(13)+char(10) else '' end+
			case when a.delete_referential_action >0 then 'ON DELETE '+a.delete_referential_action_desc+char(13)+char(10) else '' end+
			'GO'+char(13)+char(10) from ( 

	select 
		fk.name COLLATE Latin1_General_CI_AS_KS_WS  as constraint_name
		,main_schema.name COLLATE Latin1_General_CI_AS_KS_WS as main_table_schema
		,main_table.name  COLLATE Latin1_General_CI_AS_KS_WS as main_table 	
		,ref_schema.name COLLATE Latin1_General_CI_AS_KS_WS  as ref_table_schema
		,ref_table.name  COLLATE Latin1_General_CI_AS_KS_WS as ref_table		
		,fk.delete_referential_action_desc COLLATE Latin1_General_CI_AS_KS_WS as delete_referential_action_desc
		,fk.update_referential_action_desc COLLATE Latin1_General_CI_AS_KS_WS  as update_referential_action_desc
		,fk.delete_referential_action 
		,fk.update_referential_action 
		,   STUFF((
			SELECT ', ' +'[' +table_col_main.name+']' 
			
				from  sys.foreign_key_columns fkc_main				
				inner join sys.columns as table_col_main
				on fkc_main.parent_object_id=table_col_main.object_id
				and fkc_main.parent_column_id=table_col_main.column_id				
				where fk.object_id=fkc_main.constraint_object_id
				order by fkc_main.constraint_column_id

			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		  ,1,2,'') COLLATE Latin1_General_CI_AS_KS_WS AS main_table_cols
		 ,   STUFF((
			SELECT ', ' +'[' +table_col_ref.name+']' 
			
				from  sys.foreign_key_columns fkc_ref				
				inner join sys.columns as table_col_ref
				on fkc_ref.referenced_object_id=table_col_ref.object_id
				and fkc_ref.referenced_column_id=table_col_ref.column_id				
				where fk.object_id=fkc_ref.constraint_object_id
				order by fkc_ref.constraint_column_id

			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		  ,1,2,'') COLLATE Latin1_General_CI_AS_KS_WS AS ref_table_cols


	from sys.foreign_keys fk

	inner join sys.objects as main_table
	on fk.parent_object_id=main_table.object_id
	
	inner join sys.objects as ref_table
	on fk.referenced_object_id=ref_table.object_id	
	inner join sys.schemas as main_schema
	on main_table.schema_id=main_schema.schema_id
	inner join sys.schemas as ref_schema
	on ref_table.schema_id=ref_schema.schema_id
	
	where @table_name = main_table.name
	
	) a
	order by main_table
	FOR XML PATH('')
         ), 1, 0, ''),'&#x0D;',CHAR(13) ),'&gt;','>')  as code)
set @query =@query +isnull(@query_aux,'')
select @query