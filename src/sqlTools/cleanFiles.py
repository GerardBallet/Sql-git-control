# este script se debe de ejecutar desde la raiz del proyecto

import os

main_directory = os.getcwd()
dir=os.path.join(main_directory, 'results')

def clean_scripts_folder():    
    for f in os.listdir(dir):
        os.remove(os.path.join(dir, f))

if __name__=='__main__':
    clean_scripts_folder()
