from sqlTools.readFile  import readSqlScriptContent
from sqlTools.writeFile  import writeSqlScriptContent
#Tables ordered by hyerarchy
sql_script_for_generate_insert_script =readSqlScriptContent('crate_inserts_registers_script.sql')

def create_script(connexion,tableName, outputfile=True):
    cursor = connexion.cursor()    
    cursor.execute(sql_script_for_generate_insert_script.replace('${0}',tableName)) 
    if outputfile:
        try:
            content =cursor.fetchall()[0][0]
            if not content:
                return
            writeSqlScriptContent(tableName+'.sql',content)
        except:
            print(content)
            raise
        return
    return cursor.fetchall()
