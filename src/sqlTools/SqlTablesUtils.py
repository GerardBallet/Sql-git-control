
from sqlTools.FilesManage  import readSqlScriptContent,writeSqlScriptContent,checkDir
from sqlTools.conexion import BackupConnection




sql_script_for_get_tables =readSqlScriptContent('getTables.sql')

def getTablesList(connexion):
    cursor = connexion.cursor()    
    cursor.execute(sql_script_for_get_tables) 
    return cursor.fetchall()


#Tables ordered by hyerarchy
sql_script_for_generate_insert_script =readSqlScriptContent('crate_inserts_registers_script.sql')

def create_script_tables_registers(connexion,tableName, outputfile=True):
    cursor = connexion.cursor()    
    cursor.execute(sql_script_for_generate_insert_script.replace('${0}',tableName)) 
    if outputfile:
        checkDir('Tables')
        checkDir('Tables/Registers')
        try:
            content =cursor.fetchall()[0][0]
            if not content:
                return
            writeSqlScriptContent('Tables/Registers/'+tableName+'.sql',content)
        except:
            print(content)
            raise
        return
    return cursor.fetchall()



def generateTablesRegistersScript():
    print('creating inserts scripts')
    print('#'*60)
    
    tables = getTablesList(BackupConnection)
    for i in range(len(tables)):    
        try:
            create_script_tables_registers(BackupConnection,tables[i][0])
            print(f'script for table {tables[i][0]} done')
        except:
            print(f'!!!! Error when doing script for table {tables[i][0]} !!!!!')
            
            raise    
    print('Task finished')
