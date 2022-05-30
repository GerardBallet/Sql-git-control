
from sqlTools.SqlTablesUtils import getTablesList 
from sqlTools.conexion import BackupConnection
print(getTablesList(BackupConnection))

