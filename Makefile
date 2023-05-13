#colores
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

COlOR=$(purpura_resaltado)



#servidores sobre los que se ejecuta ansible
SERVER=CENTOS8

#nombre db
NOMBRE_DB=db1

#usuario
NAME_USER=pepe
PASSW=123456

PERMISOS=ALL
OBJETOS=public
TIPO=schema
SUPER=true


#dump y restore
RUTA_CARPETA=/tmp/


#query
ACCION=SELECT version();


.PHONY: help
help:  ## Muestra la ayuda
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'


instalar_postgresql: ## Instalacion de postgresql
	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Incluir servidor en plantilla"$(normal)
	cat plantilla.yml | sed 's/: rol/: instalar_postgresql/g' | sed 's/all/$(SERVER)/g' > playbook.yml
	
	@echo "********************************************************************************************************************"	
	@echo -e $(COlOR)"Ejecutar playbook"$(normal)
	ansible-playbook playbook.yml -i inventory/hosts


crear_db: ## Creacion de db
	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Incluir servidor en plantilla"$(normal)
	cat plantilla.yml | sed 's/: rol/: crear_db/g' | sed 's/all/$(SERVER)/g' > playbook.yml

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Añadir nombre db a variable de ansible"$(normal)
	cat roles/crear_db/vars/plantilla_vars.yml | sed 's/nombre/$(NOMBRE_DB)/g' > roles/crear_db/vars/main.yml 

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Ejecutar playbook"$(normal)
	ansible-playbook playbook.yml -i inventory/hosts


crear_usuarios: ## Creacion usuarios en db
	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Incluir servidor en plantilla"$(normal)
	cat plantilla.yml | sed 's/: rol/: crear_usuarios/g' | sed 's/all/$(SERVER)/g' > playbook.yml

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Añadir variables necesarias al fichero de variables de ansible"$(normal)
	cat roles/crear_usuarios/vars/plantilla_vars.yml | sed 's/name_user/$(NAME_USER)/g' | sed 's/contraseña/$(PASSW)/g' | sed 's/permisos/$(PERMISOS)/g' | sed 's/nombre_db/$(NOMBRE_DB)/g' | sed 's/objetos/$(OBJETOS)/g' | sed 's/tipo/$(TIPO)/g' | sed 's/super/$(SUPER)/g' > roles/crear_usuarios/vars/main.yml

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Ejecutar playbook"$(normal)
	ansible-playbook playbook.yml -i inventory/hosts


copia_seguridad: ## Crear copia seguridad
	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Incluir servidor en plantilla"$(normal)
	cat plantilla.yml | sed 's/: rol/: copia_seguridad/g' | sed 's/all/$(SERVER)/g' > playbook.yml

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Añadir variables necesarias al fichero de variables de ansible"$(normal)
	cat roles/copia_seguridad/vars/plantilla_vars.yml | sed 's/nombre/$(NOMBRE_DB)/g' > roles/copia_seguridad/vars/main.yml
	echo "path: $(RUTA_CARPETA)" >> roles/copia_seguridad/vars/main.yml

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Ejecutar playbook"$(normal)
	ansible-playbook playbook.yml -i inventory/hosts


restore_db: ## Crear copia seguridad
	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Incluir servidor en plantilla"$(normal)
	cat plantilla.yml | sed 's/: rol/: restore_db/g' | sed 's/all/$(SERVER)/g' > playbook.yml

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Añadir variables necesarias al fichero de variables de ansible"$(normal)
	cat roles/restore_db/vars/plantilla_vars.yml | sed 's/nombre/$(NOMBRE_DB)/g' > roles/restore_db/vars/main.yml
	echo "path: $(RUTA_CARPETA)" >> roles/restore_db/vars/main.yml

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Ejecutar playbook"$(normal)
	ansible-playbook playbook.yml -i inventory/hosts


query: ## Realizar query
	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Incluir servidor en plantilla"$(normal)	
	cat plantilla.yml | sed 's/: rol/: query/g' | sed 's/all/$(SERVER)/g' > playbook.yml

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Añadir variables necesarias al fichero de variables de ansible"$(normal)
	cat roles/query/vars/plantilla_vars.yml | sed 's/nombre/$(NOMBRE_DB)/g' | sed 's/accion/{{ accion }}/g' > roles/query/vars/main.yml
	echo "accion: $(ACCION)" >> roles/query/vars/main.yml

	@echo "********************************************************************************************************************"
	@echo -e $(COlOR)"Ejecutar playbook"$(normal)
	ansible-playbook playbook.yml -i inventory/hosts


ejec_all: ## Ejecuta todos los roles en el siguiente orden: \
		  ## instalar_postgresql \
		  ## crear_db \
		  ## crear_usuarios \
		  ## copia_seguridad \
		  ## restore_db \
		  ## query 
		  
	$(MAKE) instalar_postgresql
	$(MAKE) crear_db
	$(MAKE) crear_usuarios
	$(MAKE) copia_seguridad
	$(MAKE) restore_db
	$(MAKE) query