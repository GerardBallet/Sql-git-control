set nocount on

DECLARE @TABLE_NAME NVARCHAR(MAX) ='${0}',
        @CSV_COLUMN NVARCHAR(MAX),
        @QUOTED_DATA NVARCHAR(MAX),    
        @TEXT NVARCHAR(MAX),
		@order_file NVARCHAR(MAX),
		@schema varchar(max)= '${1}'

declare @backup_table_aux table(query Nvarchar(max),[orden] int)

SELECT @CSV_COLUMN=STUFF
	(
		(
		 SELECT ',['+ NAME +']' FROM sys.all_columns 
		 WHERE OBJECT_ID=OBJECT_ID(@TABLE_NAME) AND 
		 is_identity!=1 FOR XML PATH('')
		),1,1,''
	)

	SELECT @QUOTED_DATA=STUFF
	(
		(
		 SELECT ' ISNULL('+ 
			case 
				when system_type_id IN (40,41,42,43,58,61,189) then 'QUOTENAME('+'Convert(varchar(100),' 
				when system_type_id IN (173) then '''0x''+Convert(varchar(max),' 
				when system_type_id IN (167,231,239) then ' ''N'''''' + replace('
				else 'QUOTENAME(' end 
			+'['+NAME+']'+
			case when system_type_id IN (40,41,42,43,58,61,189) then ',126)' +','+QUOTENAME('''','''''')+')'
			when system_type_id IN (173) then ',2)' 
			when system_type_id IN (167,231,239) then ', '''''''','''''''''''') +''''''''  '
			else +','+QUOTENAME('''','''''')+')'
			 end
			 +',''NULL'''   +')+'','''+'+' FROM sys.all_columns 
		 WHERE OBJECT_ID=OBJECT_ID(@TABLE_NAME) AND 
		 is_identity!=1 FOR XML PATH('')
		),1,1,''
	)
	set @order_file= (select top 1 '['+name+']' FROM sys.all_columns 
		 WHERE OBJECT_ID=OBJECT_ID(@TABLE_NAME) AND 
		 is_identity!=1 )
	
	SELECT @TEXT='SELECT case when ROW_NUMBER() OVER(ORDER BY '+@order_file+') =1 then ''INSERT INTO ['+@schema+'].['+@TABLE_NAME+']('+@CSV_COLUMN+') VALUES'' else '','' end + '' ('''+'+'+SUBSTRING(@QUOTED_DATA,1,LEN(@QUOTED_DATA)-5)+'+'+''')'''+' Insert_Scripts, ROW_NUMBER() OVER(ORDER BY '+@order_file+') as [orden]FROM '+@TABLE_NAME




insert into @backup_table_aux	
EXECUTE (@TEXT)


select replace(replace(STUFF((
select query+char(13)+char(10) from @backup_table_aux order by [orden] asc
FOR XML PATH('')
         ), 1, 0, ''),'&#x0D;',CHAR(13) ),'&gt;','>')  as code

