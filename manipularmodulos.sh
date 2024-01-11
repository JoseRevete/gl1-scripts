#!/bin/bash

blue='\e[0;34m'
NC='\e[0m'

function activarmod
{
	result=$(cat /proc/modules | grep $1)
        modulo=$(echo $result | awk '{print $1}')
        if [ "$modulo" == "$1" ] ; then
		echo "El modulo $1 ya esta activado"
	else
		sudo modprobe $1
                echo "El modulo $1 ha sido activado"
	fi
}

function desactivarmod
{
	result=$(cat /proc/modules | grep $1)
        modulo=$(echo $result | awk '{print $1}')
        if [ "$modulo" == "$1" ] ; then
		sudo modprobe -r $1
                echo "El modulo $1 ha sido desactivado"
        else
                echo "El modulo $1 ya esta desactivado"
        fi
}

function ayuda
{
	echo -e "${blue}MANIPULAR MODULOS\n\nEste script tiene la funcion de ayudarte a activar y desactivar los modulos de tu ordenador, empleandolo como un comando (ejecutandolo con flags o el nombre del modulo).${NC}"
	echo -e "flags:\n-a    Se encarga de verificar si el modulo esta desactivado y, en ese caso, activarlo\n\nSintasis: ./manipularmodulos.sh -a [nombre modulo]\n\n-r    Se encarga de verificar si el modulo esta activado y, en ese caso, desactivarlo\n\nSintasis: ./manipularmodulos.sh -r [nombre modulo]\n\n-help    Se encarga de proporcionar informacion de como usar el script\n\nSintasis: ./manipularmodulos.sh -help\n\n[nombre modulo]    Se encarga proporcionar informacion acerca del modulo, sabiendo si esta cativado o desactivado\n\nSintasis: ./manipularmodulos.sh [nombre modulo]"
}

function infomodl
{
	result=$(cat /proc/modules | grep $1)
        modulo=$(echo $result | awk '{print $1}')
        if [ "$modulo" == "$1" ] ; then
	        echo "El modulo $1 esta activado"
        else
                echo "El modulo $1 esta desactivado"
        fi

}
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
