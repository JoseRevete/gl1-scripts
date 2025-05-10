#!/bin/bash

blue='\e[0;34m'
NC='\e[0m'

#Funcion para activar el modulo dado
function activarmod
{
	#Verificar si el modulo esta desactivado o no
	result=$(lsmod | awk '{print $1}' | grep -w $1)
    if [ "$modulo" == "$1" ] ; then
		echo "El modulo $1 ya esta activado"
	else
		sudo modprobe $1
        echo "El modulo $1 ha sido activado"
	fi
}

#Funcion para desactivar el modulo dado
function desactivarmod
{
	#Verificar si el modulo esta desactivado o no
	result=$(lsmod | awk '{print $1}' | grep -w $1)
    if [ "$result" == "$1" ] ; then
	sudo modprobe -r $1
        echo "El modulo $1 ha sido desactivado"
    else
        echo "El modulo $1 ya esta desactivado"
    fi
}

#Funcion para explicar el script y dar ayuda
function ayuda
{
	echo -e "${blue}MANIPULAR MODULOS\n\nEste script tiene la funcion de ayudarte a activar y desactivar los modulos de tu ordenador, empleandolo como un comando (ejecutandolo con flags o el nombre del modulo).${NC}"
	echo -e "	flags:\n		-a    Se encarga de verificar si el modulo esta desactivado y, en ese caso, activarlo\n		Sintasis: ./manipularmodulos.sh -a [nombre modulo]\n\n\n		-r    Se encarga de verificar si el modulo esta activado y, en ese caso, desactivarlo\n		Sintasis: ./manipularmodulos.sh -r [nombre modulo]\n\n\n		-help    Se encarga de proporcionar informacion de como usar el script\n		Sintasis: ./manipularmodulos.sh -help\n\n\n		[nombre modulo]    Se encarga proporcionar informacion acerca del modulo, sabiendo si esta activado o desactivado\n		Sintasis: ./manipularmodulos.sh [nombre modulo]"
}

#Funcion para saber el estado de un modulo
function infomodl
{
	result=$(lsmod | awk '{print $1}' | grep -w $1)
    if [ "$result" == "$1" ] ; then
	    echo "El modulo $1 esta activado"
    else
        echo "El modulo $1 esta desactivado"
    fi

}
#Verificar si los parametros de entrada necesarios para cada caso estan dados
if [ -n "$1" ] ; then
	if [ -n "$2" ] ; then
		case "$1" in
			"-a"|"-A") activarmod $2;;
			"-r"|"-R") desactivarmod $2;;
			*) echo "Error: El parametro ingresado es incorrecto. Recomendacion: usar flag -help";;
		esac
	else
		case "$1" in
			"-a"|"-A"|"-r"|"-R") echo "Error: No  olvides proporcionar el nombre del modulo al que deseas efectuarle la accion";;
			"-help") ayuda ;;
			*) infomodl $1 ;;
		esac
	fi
else
	echo "Error: No has ingresado ningun parametro. Recomendacion: usar flag -help"
fi
