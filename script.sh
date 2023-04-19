#!/bin/bash


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



instalar_postgresql(){

    cat plantilla.yml | sed 's/rol$/instalar_postgresql/g' > playbook.yml

    if [ $? -eq 0 ]
    then
        ansible-playbook playbook.yml -i inventory/hosts
    else
        echo -e $rojo"Se ha producido un error al introducir el rol en playbook.yml"
    fi

}


crear_db(){

    cat plantilla.yml | sed 's/rol$/crear_db/g' > playbook.yml

    if [ $? -eq 0 ]
    then

        echo -e $amarillo"____________________________________"
        echo -e $azul"Variables para crear la db"
        echo " "
        echo -en $amarillo"Nombre de la base de datos: "$normal
        read nombre_db

        cat roles/crear_db/vars/plantilla_vars.yml | sed 's/nombre/'$nombre_db'/g' > roles/crear_db/vars/main.yml
        
        if [ $? -eq 0 ]
        then
            ansible-playbook playbook.yml -i inventory/hosts
        else
            echo -e $rojo"Se ha producido un error al pasar las variables al fichero roles/crear_db/vars/main.yml"
        fi
    
    else
        echo -e $rojo"Se ha producido un error al introducir el rol en playbook.yml"
    fi

}


crear_usuarios(){

    cat plantilla.yml | sed 's/rol$/crear_usuarios/g' > playbook.yml

    if [ $? -eq 0 ]
    then

        echo -e $amarillo"____________________________________"
        echo -e $azul"Variables para crear usuarios"
        echo " "
        echo -en $amarillo"Nombre de usuario: "$normal
        read name_user
        echo -en $amarillo"Contraseña: "$normal
        read pass
        echo -en $amarillo"Permisos: "$normal
        read permisos
        echo -en $amarillo"Nombre base de datos: "$normal
        read nombre_db
        echo -en $amarillo"Objetos: "$normal
        read objetos
        echo -en $amarillo"Tipo: "$normal
        read tipo
        echo -en $amarillo"Grant option [true|false]: "$normal
        read super

        cat roles/crear_usuarios/vars/plantilla_vars.yml | sed 's/name_user/'$name_user'/g' | sed 's/contraseña/'$pass'/g' \
        | sed 's/permisos/'$permisos'/g' | sed 's/nombre_db/'$nombre_db'/g' | sed 's/objetos/'$objetos'/g' \
        | sed 's/tipo/'$tipo'/g' | sed 's/super/'$super'/g' > roles/crear_usuarios/vars/main.yml

        if [ $? -eq 0 ]
        then
            ansible-playbook playbook.yml -i inventory/hosts
        else
            echo -e $rojo"Se ha producido un error al pasar las variables al fichero roles/crear_usuarios/vars/main.yml"$normal
        fi

    else
        echo -e $rojo"Se ha producido un error al introducir el rol en playbook.yml"
    fi

}

copia_seguridad(){

    cat plantilla.yml | sed 's/rol$/copia_seguridad/g' > playbook.yml

    if [ $? -eq 0 ]
    then    

        echo -e $amarillo"____________________________________"
        echo -e $azul"Variables para backup"
        echo " "
        echo -en $amarillo"Nombre de la db: "$normal
        read nombre
        echo -en $amarillo"Ruta donde ubicar el backup: "$normal
        read ruta_carpeta


        cat roles/copia_seguridad/vars/plantilla_vars.yml | sed 's/nombre/'$nombre'/g' > roles/copia_seguridad/vars/main.yml

        if [ $? -eq 0 ]
        then   
            echo "path: $ruta_carpeta" >> roles/copia_seguridad/vars/main.yml

            if [ $? -eq 0 ]
            then
                ansible-playbook playbook.yml -i inventory/hosts
            else
                echo -e $rojo"Se ha producido un error al pasar la variables con la ruta de destino al fichero roles/copia_seguridad/vars/main.yml"$normal
            fi

        else
            echo -e $rojo"Se ha producido un error al pasar las variables al fichero roles/copia_seguridad/vars/main.yml"$normal
        fi

    else
        echo -e $rojo"Se ha producido un error al introducir el rol en playbook.yml"
    fi

}


restore_db(){

    cat plantilla.yml | sed 's/rol$/restore_db/g' > playbook.yml

    ansible-playbook playbook.yml -i inventory/hosts

}


query(){

    cat plantilla.yml | sed 's/rol$/query/g' > playbook.yml

    ansible-playbook playbook.yml -i inventory/hosts

}



while true :
do
    echo -e $azul"Elige el rol a ejecutar:"
    echo -e $cyan"================================"
    echo -e "1. Instalar Postgresql"
    echo -e "2. Crear db"
    echo -e "3. Crear usuario en la db"
    echo -e "4. Crear backup"
    echo -e "5. Restaurar db"
    echo -e "6. Realizar una query"
    echo -e "7. Salir"
    echo -e "================================="$normal
    echo -ne $verde"Dime opcion: "$normal
    read opcion

    case $opcion in

        1)  instalar_postgresql;;

        2)  crear_db;;

        3)  crear_usuarios;;

        4)  copia_seguridad;;

        5)  restore_db;;

        6)  query;;

        7)  echo -e $purpura"Hasta pronto!!"$normal
        
            break;;

        *)  echo -e $rojo"Opcion incorrecta"$normal
            sleep 2;;

    esac



done