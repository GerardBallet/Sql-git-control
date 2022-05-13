import os

def readFileContent(path):
    main_directory = os.getcwd()
    file=os.path.join(main_directory, path)
    text_file = open(file, "r")
    
    #read whole file to a string
    data = text_file.read()
    
    #close file
    text_file.close()
    return data

def readSqlScriptContent(file):
    path ='src/sqlTools/helpers/sql/'+file
    return readFileContent(path)
    