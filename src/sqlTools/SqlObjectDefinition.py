from sqlTools.conexion import BackupConnection

from sqlTools.FilesManage  import readSqlScriptContent, checkDir, writeSqlScriptContent

#Tables ordered by hyerarchy
sql_script_for_get_objects_definition =readSqlScriptContent('objects_definition.sql')



def createObjectScripts(object_type,path,sql_type):
    checkDir(object_type)
    checkDir(path)    
    cursor = BackupConnection.cursor()    
    cursor.execute(sql_script_for_get_objects_definition.replace('${0}',sql_type)) 
    result = cursor.fetchall()
    print(f"creating {object_type} definition scripts")
    print('#'*20)
    for object in result: 
        print(f"script for {object_type} definition {object[1]}")        
        writeSqlScriptContent(path+'/'+object[1]+'.sql',object[0])
    print('Task finished')
    return 





def create_script_functions_definition():
    object_type='Functions'
    sql_type="'IF','TF','FN'"
    path = f'{object_type}/Definition'
    createObjectScripts(object_type,path,sql_type)


def create_script_views_definition():
    object_type='Views'
    sql_type="'V'"
    path = f'{object_type}/Definition'
    createObjectScripts(object_type,path,sql_type)


def create_script_triggers_definition():
    object_type='Triggers'
    sql_type="'TR'"
    path = f'{object_type}/Definition'
    createObjectScripts(object_type,path,sql_type)


def create_script_procedures_definition():
    object_type='Procedures'
    sql_type="'P'"
    path = f'{object_type}/Definition'
    createObjectScripts(object_type,path,sql_type)
  