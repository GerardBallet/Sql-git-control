import os

def writeFileContent(path,content):
    main_directory = os.getcwd()
    file=os.path.join(main_directory, path)
    f = open(file, "a")
    f.write(content)
    f.close()

def writeSqlScriptContent(file,content):
    path ='results/'+file
    return writeFileContent(path,content)




    