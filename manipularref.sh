#!/bin/bash

#Ubicamos el archivo de las referencias
ref="$HOME/ref"
#Verificamos si existe, si no existe se crea
if [ ! -e "$ref" ] ; then
	touch "$ref"
fi

blue='\e[0;34m'
NC='\e[0m'

#flag -help para ofrecer ayuda en el script
ayuda()
{
 echo -e "${blue}MANIPULAR REFERENCIAS\nEste script tiene como funcion el imprimir direcciones previamente registradas de archivos, agregar referencias para archivos y eliminar referencias ya planteadas y dar permisos a un archivo al cual su direccion ya ha sido registrada.\nRecomendaciones:\n1. No agregar referencias a dispositivos\n2. No imprimir o eliminar referencias que no han sido registradas\n3. Usar unicamentes los flags suministraos a continuacion:${NC}"
 echo -e "flags:\n-i	Se encarga de imprimir la direccion del nombre de archivo suministrados\n\nSintasis: ./manipularref -i [nombre archivo]\n\n-ad	Se encarga de agregar una direccion del nombre de archivo suministrado\n\n	 Sintasis: ./manipular -ad [nombre archivo] [Direccion de archivo]\n\n-an	Se encarga de agregar una referencia para el nombre de archivo suministrado\n\n   Sintasis: ./manipularref -an [nombre archivo] [nombre de referencia de archivo]\n\n-r	Se encarga de eliminar una referencia ya agregada previamente con el nombre de archivo\n\n	Sintasis: ./manipularref -r [nombre archivo] [nombre de referencia de archivo]\n\n-p	Se encarga de dar permisos a un archivo al que previamente se le ha referenciado su direccion\n\n	Sintesis: ./manipularref.sh -p [numero de tres digitos de permisos] [nombre del archivo]\n\n Ahora, el numero de permisos depende lo del que se le quiera otorgar, el permiso de leer vale 4, el de escribir vale 2 y el de ejecutar vale 1, la suma de estos numeros son los permisos a dar al archivo. Deben ser dados tres digitos, el primer digito son los permisos de usuario, el segundo los permisos de grupos y el tercero el del resto; la forma correcta de dar los digitos es: 777 o 254, por ejemplo. Cada digito debe estar entre 0 y 7.\n\n-i (sin argumento)		Si se le pasa el flag -i sin argmento, devolverá las referencias registradas en el archivo		Sintasis: ./manipularref -i\n"
}

imprimirref()
{
 echo "$(cat "$ref")"
 exit 1
}

#flag -i para imprimir direcciones
imprimir()
{
	#Tomamos el nombre de la primera aparicion del nombre en ref
	compdir=$(cat "$ref" | grep "$1: Direccion: " | cut -d ' ' -f1 | head -n 1 | cut -d ":" -f1)
	#Verificamos los casos, existe la referencia o no
	case "$1" in
		$compdir) echo "$(cat "$ref" | grep "$1: Direccion: ")";;
		*) echo "Error: no existe referencia direccion de este archivo, debe agregarla primero";;
	esac
}

#flag para agregar referencia: -ad -da -na -an
agregarref() {
	#Verificamos en que carperta se encuentra, por si se encuentra en la carpeta /dev/
	valor3=$(echo "$3" | cut -d "/" -f2)
	#Casos segun la flag dada
	case "$1" in
		"-a") echo -e "Error: no seleccionaste el flag correspondiente. Recuerda que\n-ad, es para referenciar la direccion de un archivo\n-an es para referenciar una archivo libremente";;
		"-ad"|"-da") case "$valor3" in
					"dev") echo "Error: El archivo que intentaste referenciar en un dispositivo, esto no es permitido";;
					*) #Verificamos el archivo ref por si ya existe esa direccion
					   compnamedir=$(cat "$ref" | grep "$2: Direccion: $3")
					   #Si ya existe, no se agrega y se termina la ejecucion
					   if [ "$2: Direccion: $3" == "$compnamedir" ] ; then
                		                echo "Error: El archivo al que intentas referenciar su direccion ya se encuentra registrado. Recomendacion: revisar si efectivamente esta en la direccion del archivo que intentas referenciar"
		                                exit 0
                		           else
						#No existe, entonces se sigue ejecutando
						echo ""
                        		   fi
					   #Se agrega a ref la direccion
					   echo "$2: Direccion: $3" >> "$ref"
		                	   echo "La direccion del archivo $namearch ha sido referenciada con exito";;
			     esac;;
		"-an"|"-na") #Filtramos y tomamos todos los nombres de /dev/ para comparar
			comprefdisp=$(ls -l /dev/ | grep '^[bc]' | awk '{print $10}' | grep -x "$2")
			#Casos: es un dispositivo y no lo es
			case "$2" in
				"$comprefdisp")
					echo "Error: El archivo que intentaste referenciar en un dispositivo, esto no es permitido"
					exit;;
				*) ;;
			esac
			#Verificando si existe mas archivos con  el mismo nombre y referencia
			compnameref=$(cat "$ref" | grep "$2: $3: " | cut -d ' ' -f2 | head -n 1)
		        if [ "$compnameref" == "$3:" ] ; then
				#Se encontraron otros archivos con el mismo nombre y referencia, entonces se da una lista se las direcciones y se pregunta si alguna de ellas es la del archivo que desea refeernciar
				#Si no esta la direccion en la lista, se sigue ejecutando. De lo contrario, termina la ejecucuion
		                compdir=$(cat -n "$ref" | grep "$2: Direccion: ")
		                echo -e "$compdir\n "
				read -p "Se han encontrado mas archivo(s) con el mismo nombre y referencia que intentas colocar. ¿Es (alguna de) la(s) Direccion(es) (de los) anterior(es) la del archivo que intentas referenciar? (s/n)    " retorno
		        else
		                retorno="nada"
		        fi
			#Evaluando casos, (nada) implica que no existe otro archivo con el mismo nombre y referencia
			#                 (s o n) implica que se encontraron otros archivos con el mismo nombre y referencia
			case "$retorno" in
				"nada") #Se pide la referencia a colocar
					read -p "Indicame la referencia que deseas agregar para el archivo: " addrefarch
        	                        echo "$2: $3: $addrefarch" >> "$ref"
                	                echo "El archivo $2 ha sido referenciado con exito";;
				S|SI|Si|s|si|sI|y|Y|YES|Yes|yes|yEs|yES|YEs|YeS) echo "Error: la referencia que intenta agregar ya existe"
										exit;;
                                n|no|No|NO|nO|Not|NOT|not|NOt|nOT|noT|NoT|nOt) read -p "Indicame la referencia que deseas agregar para el archivo: " addrefarch
                                              				       echo "$2: $3: $addrefarch" >> "$ref"
                                                                               echo "El archivo $2 ha sido referenciado con exito";;
                                     *) #se da una respuesta que no sea s o n
					echo "Error: solo debe dar como respuesta valida s o n";;
			esac;;
	esac
}

#flag -r para eliminar referencia
eliminarref() {
	#Se filtan de ref las refencias que coincidan
	compdir=$(cat "$ref" | grep "$1: $2: " | cut -d ' ' -f2 | head -n 1)
	#Se evaluan los casos si coinciden  o no
	case "$compdir" in
		"$2:")  #Se imprime la lista de referencias paraq eu el ususario indique cual eleiminar
			numberpri=$(cat -n "$ref" | grep "$1: $2: ")
			echo "$numberpri"
			#se guarda la lista de los numeros de lineas
			indices=$(echo "$numberpri" | awk '{print $1}')
			g=0
			read -p "Indicame el numero a la izquierda de la referencia que deseas eliminar:  " numberoref
			# se evalua una a una cada linea que coincide con el nombre y referencia
			for indice in $indices
				do
				#se evalua cada indice de linea hastaq ue coincida con el dado por el usuario
				case "$indice" in
					"$numberoref") sed -i "$numberoref d" "$ref"
		                        echo "Referencia de $1 eliminada con exito"
					exit 1;;
					*) g=$((g+1));;
				esac
				done
			#si el usuario da un inidce distinto a los datos, no es ejecuta nada
			if [[ "$g" -ge 1 ]] ; then
				echo "Error: el numero dado es distinto de los planteados en la lista"
			else
				echo ""
			fi;;
		*) echo "Error: la referencia del archivo que intentas eliminar no existe";;
	esac
}

#flag -p para dar permisos a un archivo el cual su direccion ya fue registrada
permisos()
{
	#se compueba el primer argumento dado es distinto es distinto de un numero
        archivo_palabra=$(cat "$ref" | grep "$1" | head -1 | awk '{print $1}' | cut -d ":" -f1)
        if [ "$1" == "$archivo_palabra" ]; then
                comprobar=1
        else
                comprobar=0
        fi
	# se evaluan los casos: 1 es que no es un numero el argumento, 2 es que si lo es
	case "$comprobar" in
		1) echo "Error: los parametros otrogados son incorrectos. Recomendacion: recordar que la sisntasis de ejecucion para el flag -p es  ./manipularref -p [numero de 3 digitos de permiso]  [nombre de archivo]";;
		0) #Se chequea su el nombre del archivo tiene una referencia de direccion registrada
		   compdir=$(cat "$ref" | grep "$2: Direccion: " | cut -d ' ' -f1 | head -n 1)
		   #perdon, es mi forma de colocar >cualquier vaina<
		   if [[ "$1" -le 077 ]] ; then
			S="S"
		   elif [[ "$1" -le 177 && "$1" -ge 100 ]] ; then
			S="S" 
                   elif [[ "$1" -le 277 && "$1" -ge 200 ]] ; then
			S="S" 
                   elif [[ "$1" -le 377 && "$1" -ge 300 ]] ; then
			S="S" 
                   elif [[ "$1" -le 477 && "$1" -ge 400 ]] ; then
			S="S" 
                   elif [[ "$1" -le 577 && "$1" -ge 500 ]] ; then
			S="S" 
                   elif [[ "$1" -le 677 && "$1" -ge 600 ]] ; then
			S="S" 
                   elif [[ "$1" -le 777 && "$1" -ge 700 ]] ; then
			S="S" 
		   else
			echo "Error: el numero de permiso suministrado no esta en el rango permitido"
			exit 0
		   fi
		   # se revisa que los 3 digitos de este entre 000 y 777
		   if [[ "$1" -ge 000 && "$1" -le 777 ]] ; then
			# se evaluan los casos en los que si tiene una direccion el archivo o no
			case "$compdir" in
				"$2:")
					i=0
					# se revisa ref para verificar si hay mas de una direccion (distinta) con el mismo nombre de archivo
					compperdir=$(cat -n "$ref" | grep "$2: Direccion: ")
					# se guardan los  numeros de linea de la lista
					compperdirr=$(echo "$compperdir" | awk '{print $1}')
					# se chequean cuantas direcciones hay en la lista
					for direcciones in $compperdirr
					do
						i=$((i+1))
					done
					# si el numero para los permisos en menor que 77 se convierte en 077
					if [[ "$1" -le 77 ]] ; then
						numeropara="0$1"
					else
						numeropara="$1"
					fi
					# si solo hay una direccion es directo
					if [ "$i" -eq 1 ] ; then
						direc=$(echo "$compperdir" | awk '{print $4}')
						sudo chmod "$numeropara" "$direc" 2> /dev/null
						echo "Los permisos para $2 han sido otorgados exitosamente"
					else
						# si se encuentra mas de una direccion para el mismo nombre de archivo, se le da la ususario la lista y dice cual es la direccion
						echo "$compperdir"
						read -p "Se han encontrado mas de una referencia direccion para un archivo $2. De la lista dada, indica el numero a la izquierda del archivo que intentas dar permisos:  " numeroizq
						# se evalua si el indice dado esta en la lsita dada
						for indice in $compperdir
			                                do
			                                #se evalua cada indice de linea hastaq ue coincida con el dado por el usuario
			                                case "$indice" in
			                                        "$numeroizq") direcarch=$(echo "$compperdir" | grep "$numeroizq" | awk '{print $4}')
		                                                	      sudo chmod "$numeropara" "$direcarch" 2> /dev/null
									      echo "Los permisos para $2 han sido otorgados exitosamente"
									      exit 0;;
			                                        *) g=$((g+1));;
			                                esac
			                                done
			                        #si el usuario da un inidce distinto a los datos, no es ejecuta nada
			                        if [[ "$g" -ge 1 ]] ; then
			                                echo "Error: el numero dado es distinto de los planteados en la lista"
                			        else
		                        	        echo ""
			                        fi
					fi;;
				*)
					echo "Error: el archivo al que intenta otorgarle permisos no esta referenciado";;
				esac
		   else
			echo "Error: el numero de permisos no es permitido. Recomedacion: recuerda que debe ser un numero no nulo entre 000 y 777"
			exit
	           fi;;
	esac
}
# verificando si los argumentos necesarios dados existen para cada caso
if [[ -n "$2" ]] ; then
	if [[ -n "$3" ]] ; then
        	case "$1" in
	        	"-an"|"-na"|"-ad"|"-da"|"-r"|"-p") ;;
        	        "-i")      echo "Error: no subministro un tercer argumento que no debia de ser dado. Recomendacion: usar -help como flag"
                        	exit 0;;
   	        esac
	else
        	case "$1" in
                        "-i") ;;
                        *)      echo "Error: no subministro el tercer argumento correspondiente. Recomendacion: usar -help como flag"
                                exit 0;;
		esac
	fi
else
	case "$1" in
		"-help") ;;
		"-i") imprimirref ;;
		*) echo "Error: no subministro el segundo argumento correspondiente. Recomendacion: usar -help como flag"
		   exit 0;;
	esac
fi

#casos a evaluar segun el flag dado
flags=$1
case "$flags" in
        "-i") imprimir $2 ;;
        "-an"|"-na"|"-ad"|"-da") agregarref $1 $2 $3;;
        "-r") eliminarref $2 $3;;
        "-p") permisos $2 $3;;
        "-help") ayuda ;;
        *) echo "Error: no usaste ninguna flag permitido al ejecutar. Recuerda que puedes usar -help para obtener ayuda" ;;
esac
