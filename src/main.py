from sqlTools.conexion import BackupConnection
from sqlTools.getBackupTables import getTables
from sqlTools.createInsertsScript import create_script
from sqlTools.cleanFiles import clean_scripts_folder

print('creating inserts scripts')
print('#'*60)
clean_scripts_folder()
tables = getTables(BackupConnection)
for i in range(len(tables)):    
    try:
        create_script(BackupConnection,tables[i][0])
        print(f'script for table {tables[i][0]} done')
    except:
        print(f'!!!! Error when doing script for table {tables[i][0]} !!!!!')
        
        raise
print('#'*60)
print('Task finished')

