from sqlTools.readFile  import readSqlScriptContent
#Tables ordered by hyerarchy
sql_script_for_get_tables =readSqlScriptContent('getTables.sql')

def getTables(connexion):
    cursor = connexion.cursor()    
    cursor.execute(sql_script_for_get_tables) 
    return cursor.fetchall()
