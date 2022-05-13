# este script se debe de ejecutar desde la raiz del proyecto

import os

main_directory = os.getcwd()
dir=os.path.join(main_directory, 'results')


def create_file_sql(file_name,file_content ):    
    file_rout=os.path.join(dir, file_name+'.sql')
    f = open(file_rout, "a")
    f.write(file_content)
    f.close()

if __name__=='__main__':
    create_file_sql('test', """
    SELECT @@version
    SELECT 1 as ok
    """)
