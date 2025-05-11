#!/bin/bash

#Ubicamos el archivo de las referencias
ref="./ref"
#Verificamos si existe, si no existe se crea
if [ ! -e "$ref" ] ; then
	touch "$ref"
fi

blue='\e[0;34m'
NC='\e[0m'

#flag -help para ofrecer ayuda en el script
ayuda()
{
	echo -e "
${blue}MANIPULAR REFERENCIAS
	Este script tiene como funcion el imprimir direcciones previamente registradas de archivos,
	agregar referencias para archivos y eliminar referencias ya planteadas y dar permisos a un
	archivo al cual su direccion ya ha sido registrada.
	
	Recomendaciones:
		1. No agregar referencias a dispositivos.
		2. No imprimir o eliminar referencias que no han sido registradas.
		3. Usar unicamentes los flags suministraos a continuacion:${NC}
	"
	echo -e "	
		flags:\n		
		-i	Se encarga de imprimir la direccion del nombre de archivo suministrados.
		Sintasis: ./manipularref -i [nombre archivo]\n		
		
		-a	Se encarga de agregar una direccion y referencia del nombre de archivo suministrado.
		Sintasis: ./manipular -a [nombre archivo] [Direccion de archivo] [nombre de referencia de archivo]\n
		
		-r	Se encarga de eliminar una referencia ya agregada previamente con el nombre de archivo.
		Sintasis: ./manipularref -r [nombre archivo] [nombre de referencia de archivo]\n
		
		-p	Se encarga de dar permisos a un archivo al que previamente se le ha referenciado su direccion.
		Sintesis: ./manipularref.sh -p [numero de tres digitos de permisos] [nombre del archivo]\n
		
		Ahora, el numero de permisos depende lo del que se le quiera otorgar, el permiso de leer vale 4, el de escribir vale
		2 y el de ejecutar vale 1, la suma de estos numeros son los permisos a dar al archivo. Ademas encontramos los permisos
		especiales, en donde 1 son los atributos de eliminación, 2 es el ID de grupo configurado y 4 es el ID de usuario configurado.
		Deben ser dados cuatro digitos, el primer digito son los permisos especiales, el segundo son los permisos de usuario,
		el tercero los permisos de grupos y el cuarto son los permisos del resto. La forma correcta de dar los digitos es:
		7777 o 3254, por ejemplo. Cada digito debe estar entre 0 y 7.\n
		
		-i [null]	Si se le pasa el flag -i sin argmento, devolverá las referencias registradas en el archivo.
		Sintasis: ./manipularref -i
	"
}

imprimirref()
{
	echo "$(cat "$ref")"
	exit 1
}

# flag -i para imprimir direcciones
imprimir()
{
	# Tomamos el nombre de la primera aparicion del nombre en ref
	nombreRef=$(cat "$ref" | grep "$1: Direccion: " | cut -d ' ' -f1 | head -n 1 | cut -d ":" -f1)

	# Verificamos los casos, existe la referencia o no
	case "$1" in
		"$nombreRef") echo "$(cat "$ref" | grep "$1: Direccion: ")";;
		*) echo "Error: no existe referencia direccion de este archivo, debe agregarla primero";;
	esac
}

# Flag para agregar referencia: -a
agregarref() {
	# Verificamos en que carperta se encuentra, por si se encuentra en la carpeta /dev/
	valor3=$(realpath "$3" | cut -d '/' -f2)
	# Casos segun la flag dada
	case "$1" in
		"-a")	case "$valor3" in
					"dev") echo "Error: El archivo que intentaste referenciar en un dispositivo, esto no es permitido";;
					*) 
						# Verificamos el archivo ref por si ya existe ese nombre
						rutaAbsoluta=$(realpath "$3")
						nombreEnRef=$(cat "$ref" | grep "$2: " | cut -d ' ' -f1 | head -n 1 | cut -d ":" -f1)

						#    Si ya existe, no se agrega y se termina la ejecucion
						if [ "$2" == "$nombreEnRef" ] ; then
							echo "Error: Ya se encuentra registrado el archivo al que intentas referenciar."
							exit 0
						fi

						#	Se agrega a ref la direccion
						matchRutas=$(locate "$2" | grep -w "$rutaAbsoluta")
						if [ -z "$matchRutas" ]; then
							echo "Error: la ruta no es correcta, no se encuentra el archivo"
							exit 0
						else 
							echo "$2: Direccion: $rutaAbsoluta" >> "$ref"
							matchReferencia=$(cat "$ref" | grep ": $4" | cut -d ' ' -f2 | head -n 1)
							#	Se verifica si existe una referencia con el mismo nombre
							if [ "$matchReferencia" == "$4" ] ; then
								echo "Error: el nombre de referencia que intentas agregar ya existe."
								exit 0
							fi
							#	Se agrega la referencia
							echo "$2: $4" >> "$ref"
							echo "La direccion y a referencia del archivo $2 ha sido referenciada con exito"
						fi;;
				esac;;
	esac
}

# flag -r para eliminar referencia
eliminarref() {
	# Se filtan de ref las referencias que coincidan
	nombreRef=$(cat "$ref" | grep "$1: $2" | cut -d ' ' -f2 | head -n 1)

	# Se evaluan los casos si coinciden  o no
	case "$nombreRef" in
		"$2")	numeracionLineasRef=$(cat -n "$ref" | grep "$1: $2")
				numeroLineaRef=$(echo "$numeracionLineasRef" | awk '{print $1}')
				sed -i "$numeroLineaRef d" "$ref"
				numeracionLineasDireccion=$(cat -n "$ref" | grep "$1: Direccion: " | cut -d ' ' -f1 | head -n 1)
				numeroLineaDireccion=$(echo "$numeracionLineasDireccion" | awk '{print $1}')
				sed -i "$numeroLineaDireccion d" "$ref"
				echo "Referencia de $1 eliminada con exito." ;;
		*)	echo "Error: la referencia del archivo que intentas eliminar no existe.";;
	esac
}

# flag -p para dar permisos a un archivo el cual su direccion ya fue registrada
permisos()
{
	# Se compueba el primer argumento dado es distinto es distinto de un numero
    estaArchivoEnReferencias=$(cat "$ref" | grep "$2: " | head -1 | cut -d ':' -f1)
	  
	# Se evaluan los casos: 1 es que no es un numero el argumento, 2 es que si lo es
	case "$estaArchivoEnReferencias" in
		"$2")
			case "$1" in
				[0-7][0-7][0-7][0-7]) ;;
				[0-7][0-7][0-7]) ;;
				[0-7][0-7]) ;;
				[0-7]) ;;
				*) echo "Error: el argumento dado no es un numero o no es valido. Recuerda que los permisos son dados en octal, entre 0000 y 7777"
					exit 0;;
			esac
			direccionReferencia=$(cat "$ref" | grep "$2: Direccion: " | cut -d ' ' -f3 | head -n 1)
			sudo chmod "$1" "$direccionReferencia" 2> /dev/null
			echo "Los permisos para $2 han sido otorgados exitosamente";;
		*) echo "Error: el archivo al que intenta otorgarle permisos no esta referenciado";;
	esac
}


# Verificando si los argumentos necesarios dados existen para cada caso
if [[ -n "$2" ]] ; then
	if [[ -n "$3" ]] ; then
		case "$1" in
	        "-r"|"-p"|"-a" ) ;;
            *)	echo "Error: muchos argumentos suministrados. Recomendacion: usar -help como flag"
                exit 0;;
   	        esac
		if [[ -n "$4" ]] ; then
        	case "$1" in
	        	"-a") ;;
        	    *)	echo "Error: muchos argumentos suministrados. Recomendacion: usar -help como flag"
                    exit 0;;
   	        esac
		else
			case "$1" in
				"-a") echo "Error: faltan argumentos para el flag $1. Recomendacion: usar -help como flag"
					exit 0;;
				*) ;;
			esac
		fi
	else
        case "$1" in
            "-a"|"-r"|"-p") echo "Error: faltan argumentos para el flag $1. Recomendacion: usar -help como flag"
				exit 0;;
            *)	;;
		esac
	fi
else
	case "$1" in
		"-help") ;;
		"-i") imprimirref ;;
		*) echo "Error: faltan argumentos para el flag $1. Recomendacion: usar -help como flag"
			exit 0;;
	esac
fi

# Casos a evaluar segun el flag dado
flags=$1
case "$flags" in
        "-i") imprimir $2 ;;
        "-a") agregarref $1 $2 $3 $4;;
        "-r") eliminarref $2 $3;;
        "-p") permisos $2 $3;;
        "-help") ayuda ;;
        *) echo "Error: no usaste ninguna flag permitido al ejecutar. Recuerda que puedes usar -help para obtener ayuda" ;;
esac
