import os,shutil

main_directory = os.getcwd()
output_dir =os.path.join(main_directory, 'results')

def checkDir(dir):
    path = os.path.join(output_dir, dir)    
    if not os.path.isdir(path):
        os.mkdir(path)


def readFileContent(path):    
    file=os.path.join(main_directory, path)
    text_file = open(file, "r",encoding='utf-8')
    
    #read whole file to a string
    data = text_file.read()
    
    #close file
    text_file.close()
    return data

def readSqlScriptContent(file):
    path ='src/sqlTools/helpers/sql/'+file
    return readFileContent(path)
    
def writeFileContent(path,content):    
    file=os.path.join(main_directory, path)
    f = open(file, "a",encoding='utf-8')
    f.write(content)
    f.close()

def writeSqlScriptContent(file,content):
    path ='results/'+file
    return writeFileContent(path,content)



def clean_scripts_folder():    
    for f in os.listdir(output_dir):
        path_file =os.path.join(output_dir, f)
        if os.path.isdir(path_file):
            shutil.rmtree(path_file)   
        else:
            os.remove(path_file)

if __name__=='__main__':
    clean_scripts_folder()
