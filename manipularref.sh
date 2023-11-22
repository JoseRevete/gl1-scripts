#!/bin/bash

echo -e "Deseas...\n1. Imprimir la direccion de un archivo\n2. Agregar una referencia\n3. Eliminar una referencia\n4. Cambiar la permisologia de un archivo" 
read opcion

echo " "
read -p "Indicame el nombre del archivo: " namearch

ref="$HOME/ref"
if [ ! -e "$ref" ] ; then
	touch "$ref"
else
	echo ""
fi

if [ "$opcion" -eq "1" ] ; then
	echo " "
	compdir=$(cat "$ref" | grep "$namearch: Direccion: " | cut -d ' ' -f1 | head -n 1)
	if [ "$namearch:" == "$compdir" ] ; then
		echo "$(cat "$ref" | grep "$namearch: Direccion: ")"
	else
		echo "Error: no existe referencia direccion de este archivo, debe agregarla primero"
	fi

elif [ "$opcion" -eq "2" ] ; then
	echo " "
	read -p "¿Desea agregar la direccion de un archivo? (s/n) " respdir
	echo " "
	if [[ "$respdir" == "s" || "$respdir" == "S" || "$respdir" == "y" || "$respdir" == "Y" ]] ; then
		read -p "Indicame la direccion del archivo de esta forma: ./direccion/del/archivo   : " dirarch
		echo "$namearch: Direccion: $dirarch" >> "$ref"
	else
		read -p "¿El archivo a referenciar es un dispositivo? (s/n) " respdis
		if [[ "$respdis" == "s" || "$respdis" == "S" || "$respdis" == "y" || "$respdis" == "Y" ]] ; then
			echo "Error: no se puede refenciar un dispositivo"
		else
			read -p "Indicame el nombre de la referencia que deseas agregar para el archivo: " namerefarch
			compnameref=$(cat "$ref" | grep "$namearch: $namerefarch: " | cut -d ' ' -f2 | head -n 1)
			if [ "$compnameref" == "$namerefarch:" ] ; then
				echo " "
				echo "Error: la referencia que intenta agregar ya existe"
			else
				echo " "
	        		read -p "Indicame la referencia que deseas agregar para el archivo: " addrefarch
				echo "$namearch: $namerefarch: $addrefarch" >> "$ref"
			fi
		fi
	fi

elif [ "$opcion" -eq "3" ] ; then
	echo " "
	read -p "Indicame el nombre de la referencia que deseas eliminar del archivo: " namerefarch
	compdir=$(cat "$ref" | grep "$namearch: $namerefarch: " | cut -d ' ' -f2 | head -n 1)
	if [ "$compdir" == "$namerefarch:" ] ; then
		numberpri=$(cat -n "$ref" | grep "$namearch: $namerefarch: ")
		echo "$numberpri"
		read -p "Indicame el numero a la izquierda de la referencia que deseas eliminar:  " numberoref
		sed -i "$numberoref d" "$ref"
	else
		echo "Error: la referencia del archivo que intentas eliminar no existe"
	fi

else
	echo " "
	compdir=$(cat "$ref" | grep "$namearch: Direccion: " | cut -d ' ' -f1 | head -n 1)
	if [ "$compdir" == "$namearch:" ] ; then
		compperdir=$(cat "$ref" | grep "$namearch: Direccion: " | cut -d ' ' -f3 | head -n 1)
		read -p "¿Desea 1, 2 o 3 permisos para el archivo?(1/2/3)  " numper
		if [ "$numper" -eq "1" ] ; then
			read -p "¿Desea permiso de lectura(r), escritura(w) o ejecucion(x)?(r/w/x)   " perind
			sudo chmod +"$perind" "$compperdir"
		elif [ "$numper" -eq "2" ] ; then
			read -p "Escoga la pareja de permisos que desea: lectura(r), escritura(w) y ejecucion(x)...(rw/wx/rx)   " perind
                        sudo chmod +"$perind" "$compperdir"
		else
			sudo chmod +rwx "$compperdir"
		fi

	else
		echo "Error: el archivo al que intenta otorgarle permisos no esta referenciado"
	fi
fi
