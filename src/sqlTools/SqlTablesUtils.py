
from sqlTools.FilesManage  import readSqlScriptContent,writeSqlScriptContent,checkDir
from sqlTools.conexion import BackupConnection




sql_script_for_get_tables =readSqlScriptContent('getTables.sql')

def getTablesList(connexion):
    cursor = connexion.cursor()    
    cursor.execute(sql_script_for_get_tables) 
    return cursor.fetchall()


#Tables ordered by hyerarchy
sql_script_for_generate_insert_script =readSqlScriptContent('crate_inserts_registers_script.sql')

def create_script_tables_registers(connexion,tableSchemaName, tableName, outputfile=True):
    cursor = connexion.cursor()    
    cursor.execute(sql_script_for_generate_insert_script.replace('${0}',tableName).replace('${1}',tableSchemaName)) 
    if outputfile:
        checkDir('Tables')
        checkDir('Tables/Registers')
        try:
            content =cursor.fetchall()[0][0]
            if not content:
                return
            writeSqlScriptContent(f"""Tables/Registers/{tableSchemaName}.{tableName}.sql""",content)
        except:
            print(content)
            raise
        return
    return cursor.fetchall()


sql_script_for_generate_definition_script =readSqlScriptContent('getTableDefinition.sql')

def create_script_tables_definition(connexion,tableSchemaName,tableName, outputfile=True):
    cursor = connexion.cursor()    
    cursor.execute(sql_script_for_generate_definition_script.replace('${0}',tableName).replace('${1}',tableSchemaName)) 
    if outputfile:
        checkDir('Tables')
        checkDir('Tables/Definition')
        try:
            content =cursor.fetchall()[0][0]
            if not content:
                return
            writeSqlScriptContent(f'Tables/Definition/{tableSchemaName}.{tableName}.sql',content)
        except:
            print(content)
            raise
        return
    return cursor.fetchall()


def generateTablesScripts():
    print('creating inserts scripts')
    print('#'*60)
    
    tables = getTablesList(BackupConnection)
    for i in range(len(tables)):    
        try:
            create_script_tables_registers(BackupConnection,tables[i][0],tables[i][1])
            create_script_tables_definition(BackupConnection,tables[i][0],tables[i][1])
            print(f'script for table [{tables[i][0]}].[{tables[i][1]}] done')
        except:
            print(f'!!!! Error when doing script for table [{tables[i][0]}].[{tables[i][1]}] !!!!!')
            
            raise    
    print('Task finished')

