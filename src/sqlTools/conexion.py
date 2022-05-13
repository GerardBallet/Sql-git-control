import pyodbc 
import json
  
import os

main_directory = os.getcwd()
settings_path=os.path.join(main_directory, 'settings/settings.json')


f = open(settings_path)
config_data = json.load(f)


class ConnectionHandler:
    """class for manage sql_conections"""
    def __init__(self, database_config):
            self.database = database_config['NAME']
            self.user = database_config['USER']
            self.password = database_config['PASSWORD']
            self.server = database_config['HOST']
            self.driver = database_config['OPTIONS']['driver']
            self.extra_params =database_config['OPTIONS'].get('extra_params', '')

    def createConnectionString(self):
        return f'DRIVER={{{self.driver}}};SERVER={self.server};DATABASE={self.database};UID={self.user};PWD={self.password};{self.extra_params}'

    def cursor(self):
        cnxn = pyodbc.connect(self.createConnectionString())
        cursor = cnxn.cursor()
        return cursor

BackupConnection=None        
RestoreConnection=None        

if config_data['DATABASES'].get('backup'):
    BackupConnection = ConnectionHandler(config_data['DATABASES']['backup'])
else:
    print('backup databse not defined')

if config_data['DATABASES'].get('restore'):
    RestoreConnection = ConnectionHandler(config_data['DATABASES']['restore'])
else:
    print('restore databse not defined')    



if __name__=='__main__':
    print(config_data['DATABASES'])
    if BackupConnection:
        cursor = BackupConnection.cursor()
        cursor.execute("SELECT @@version;") 
        row = cursor.fetchone() 
        print('Backup database version')
        print('#'*12)
        while row: 
            print(row[0])
            row = cursor.fetchone()

    if RestoreConnection:
        cursor = RestoreConnection.cursor()
        cursor.execute("SELECT @@version;") 
        row = cursor.fetchone() 
        print('Restore database version')
        print('#'*12)
        while row: 
            print(row[0])
            row = cursor.fetchone()
    

