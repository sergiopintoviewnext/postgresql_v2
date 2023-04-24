import os


negro='\033[0;30m'
gris_oscuro='\033[1;30m'
azul='\033[0;34m'
azul_resaltado='\033[1;34m'
verde='\033[0;32m'
verde_resaltado='\033[1;32m'
cyan='\033[0;36m'
cyan_resaltado='\033[1;36m'
rojo='\033[0;31m'
rojo_resaltado='\033[1;31m'
purpura='\033[0;35m'
purpura_resaltado='\033[1;35m'
cafe='\033[0;33m'
amarillo='\033[1;33m'
gris='\033[0;37m'
blanco='\033[1;37m'
normal='\033[0;39m'



def server():
    
    print(f"{amarillo}____________________________________")
    print(" ")
    print(f"{azul}Servidores:")
    print(f"{purpura} ")
    
    os.system("cat inventory/hosts")
    
    global servidor
    servidor = (input(f"{amarillo} Elige servidore/es: {normal}"))
    
    print(f"{amarillo}____________________________________{normal}")
    


def instalar_postgresql():
         
    os.system(f"cat plantilla.yml | sed 's/rol$/instalar_postgresql/g' | sed 's/all/{servidor}/g' > playbook.yml")        
    
    if os.system("echo $? >/dev/null") == 0:
        os.system("ansible-playbook playbook.yml -i inventory/hosts")        
    else:
        print(f"{rojo}Se ha producido un error al introducir el rol en playbook.yml{normal}")
            
 
            
def crear_db():
    
    os.system(f"cat plantilla.yml | sed 's/rol$/crear_db/g' | sed 's/all/{servidor}/g' > playbook.yml")
    
    if os.system("echo $? >/dev/null") == 0:        
        print(f"{amarillo}____________________________________")
        print(" ")
        print(f"{azul}Variables para crear la db")
        print(" ")
        nombre_db=input(f"{amarillo}Nombre de la base de datos: {normal}")
        
        os.system(f"cat roles/crear_db/vars/plantilla_vars.yml | sed 's/nombre/{nombre_db}/g' > roles/crear_db/vars/main.yml;")
        
        if os.system("echo $? >/dev/null") == 0:
            os.system("ansible-playbook playbook.yml -i inventory/hosts")
        else:
            print(f"{rojo}Se ha producido un error al pasar las variables al fichero roles/crear_db/vars/main.yml{normal}")
    else:
        print(f"{rojo}Se ha producido un error al introducir el rol en playbook.yml{normal}")
        
        
        
def crear_usuarios():
    
    os.system(f"cat plantilla.yml | sed 's/rol$/crear_usuarios/g' | sed 's/all/{servidor}/g' > playbook.yml")
    
    if os.system("echo $? >/dev/null") == 0:        
        print(f"{amarillo}____________________________________")
        print(" ")
        print(f"{azul}Variables para crear usuarios")
        print(" ")
        print()
        name_user=input(f"{amarillo}Nombre de usuario: {normal}")
        passw=input(f"{amarillo}Contraseña: {normal}")
        permisos=input(f"{amarillo}Permisos: {normal}")
        nombre_db=input(f"{amarillo}Nombre base de datos: {normal}")
        objetos=input(f"{amarillo}Objetos: {normal}")
        tipo=input(f"{amarillo}Tipo: {normal}")
        super=input(f"{amarillo}Gran option [true|false]: {normal}")
                
        os.system("cat roles/crear_usuarios/vars/plantilla_vars.yml | sed 's/name_user/'$name_user'/g' | sed 's/contraseña/'$passw'/g' \
        | sed 's/permisos/'$permisos'/g' | sed 's/nombre_db/'$nombre_db'/g' | sed 's/objetos/'$objetos'/g' \
        | sed 's/tipo/'$tipo'/g' | sed 's/super/'$super'/g' > roles/crear_usuarios/vars/main.yml")
        
        if os.system("echo $? >/dev/null") == 0:
            os.system("ansible-playbook playbook.yml -i inventory/hosts")
        else:
            print(f"{rojo}Se ha producido un error al pasar las variables al fichero roles/crear_usuarios/vars/main.yml{normal}")
    else:
        print(f"{rojo}Se ha producido un error al introducir el rol en playbook.yml{normal}")



def copia_seguridad():
    
    os.system(f"cat plantilla.yml | sed 's/rol$/copia_seguridad/g' | sed 's/all/{servidor}/g' > playbook.yml")
    
    if os.system("echo $? >/dev/null") == 0:        
        print(f"{amarillo}____________________________________")
        print(" ")
        print(f"{azul}Variables para backup")
        print(" ")
        nombre=input(f"{amarillo}Nombre de la db: {normal}")
        ruta_carpeta=input(f"{amarillo}Carpeta donde guardar el backup (ej. /home/user/): {normal}")
        
        os.system(f"cat roles/copia_seguridad/vars/plantilla_vars.yml | sed 's/nombre/{nombre}/g' > roles/copia_seguridad/vars/main.yml")
        
        if os.system("echo $? >/dev/null") == 0:
            os.system(f"echo path: {ruta_carpeta} >> roles/copia_seguridad/vars/main.yml")
            
            if os.system("echo $? >/dev/null") == 0:
                os.system("ansible-playbook playbook.yml -i inventory/hosts")
            else:
                print(f"{rojo}Se ha producido un error al pasar la variables con la ruta de destino al fichero roles/copia_seguridad/vars/main.yml{normal}")
        else:
            print(f"{rojo}Se ha producido un error al pasar las variables al fichero roles/copia_seguridad/vars/main.yml{normal}")
    else:
        print(f"Se ha producido un error al introducir el rol en playbook.yml{normal}")
        


def restore_db():
    
    os.system(f"cat plantilla.yml | sed 's/rol$/restore_db/g' | sed 's/all/{servidor}/g' > playbook.yml")
    
    if os.system("echo $? >/dev/null") == 0:
        print(f"{amarillo}____________________________________")
        print(" ")
        print(f"{azul}Variables para restarurar la db")
        print(" ")
        nombre=input(f"{amarillo}Nombre de la db: {normal}")
        ruta_carpeta=input(f"{amarillo}Carpeta donde esta el backup (ej. /home/user/): {normal}")

        os.system(f"cat roles/restore_db/vars/plantilla_vars.yml | sed 's/nombre/{nombre}/g' > roles/restore_db/vars/main.yml")
        
        if os.system("echo $? >/dev/null") == 0:
            os.system(f"echo path: {ruta_carpeta} >> roles/restore_db/vars/main.yml")            

            if os.system("echo $? >/dev/null") == 0:
                os.system("ansible-playbook playbook.yml -i inventory/hosts")
            else:
                print(f"{rojo}Se ha producido un error al pasar la variables con la ruta de destino al fichero roles/restore_db/vars/main.yml{normal}")
        else:
            print(f"{rojo}Se ha producido un error al pasar las variables al fichero roles/restore_db/vars/main.yml{normal}")
    else:
        print(f"{rojo}Se ha producido un error al introducir el rol en playbook.yml{normal}")


def query():
    
    
    
servidor = "all"


while True:
    print(f"{verde}===========================================")
    print(f"Servidor: {servidor}")
    print(f"==========================================={normal}")
    
    print(f"{azul}Elige el rol a ejecutar:")
    print(f"{cyan}===========================================")
    print("0. Elegir el servidor (all por defecto)")
    print("1. Instalar Postgresql")
    print("2. Crear db")
    print("3. Crear usuario en la db")
    print("4. Crear backup")
    print("5. Restaurar db")
    print("6. Realizar query")
    print("7. Salir")
    print(f"==========================================={normal}")
    
    opcion=input(f"{verde}Dime opcion: {normal}")
    print(" ")
    
    
    if opcion == '0':
        server()        
    elif opcion == '1':
        instalar_postgresql()        
    elif opcion == '2':
        crear_db()        
    elif opcion == '3':
        crear_usuarios()
    elif opcion == '4':
        copia_seguridad()
        pass
    elif opcion == '5':
        restore_db()
    elif opcion == '6':
        #query
        pass
    elif opcion == '7':
        print(f"{purpura}¡¡Hasta pronto!!{normal}")
        print(" ")
        break
    else:
        print(f"{rojo}Opcion incorrecta{normal}")
        os.system("sleep 2")
        print(" ")