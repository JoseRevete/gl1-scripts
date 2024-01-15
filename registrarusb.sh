
#!/bin/bash

#Ruta del archivo donde se guardaran los logs
SCRIPT_PATH="$0"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
LOG_FILE="$SCRIPT_DIR/registro.log"
#Ruta del archivo regla udev
reglaudev="/etc/udev/rules.d/99-usb-custom.rules"

#Verificando si las reglas udev ya existen, si no se crean
if [ ! -e "$reglaudev" ] ; then
	sudo touch "$reglaudev"
	sudo chmod 666 "$reglaudev"
	echo "#Al conectar un usb en los puertos usb, se ejecuta el script" >> "$reglaudev"

	actionadd='ACTION=="add",'
	sub='SUBSYSTEMS=="usb",'
	envi='ENV{DEVTYPE}=="usb_device",'
	bin='"/bin/bash'
	ruta='/registrarusb.sh"'

	echo "$actionadd $sub $envi RUN+=$bin $HOME$ruta" >> "$reglaudev"

	actionrem='ACTION=="remove",'

	echo "" >> "$reglaudev"
	echo "#Al retirar un usb en los puertos usb, se ejecuta el script" >> "$reglaudev"
	echo "$actionrem $sub $envi RUN+=$bin $HOME$ruta" >> "$reglaudev"
	sudo chmod 644 "$reglaudev"
	sudo service udev restart
fi

#Verificando si el archivo con los logs ya tiene el encabezado
if [ ! -e "$LOG_FILE" ] ; then
	echo " PUERTO   |    FECHA/HORA CONEXION     |  FECHA/HORA DESCONEXION" > "$LOG_FILE"
else
	echo ""
fi

#Puerto ingresado por un usb
devpath1="$DEVPATH"
devpath=$(basename "$devpath1")
porto=$(echo "$devpath" | cut -d "-" -f2)

port1=$(lsusb -tv | grep "Port 1" | grep -i "usb" | awk '{print $2}')

port3=$(lsusb -tv | grep "Port 3" | grep -i "usb" | awk '{print $2}')

port4=$(lsusb -tv | grep "Port 4" | grep -i "usb" | awk '{print $2}')

#Modificando la fecha a como lo pide la tarea
fecha=$(date)
ano=$(echo "$fecha" | awk '{print $6}')
dia=$(echo "$fecha" | awk '{print $3}')
diasem=$(echo "$fecha" | awk '{print $1}')
mes=$(echo "$fecha" | awk '{print $2}')
case "$mes" in
	"Ene")mes="01";;
	"Feb")mes="02";;
	"Mar")mes="03";;
	"Abr")mes="04";;
	"May")mes="05";;
	"Jun")mes="06";;
	"Jul")mes="07";;
	"Ago")mes="08";;
	"Sep")mes="09";;
	"Oct")mes="10";;
	"Nov")mes="11";;
	"Dic")mes="12";;
esac

hora=$(echo "$fecha" | awk '{print $4}')
primhor=$(echo "$hora" | cut -d ":" -f1)
seghor=$(echo "$hora" | cut -d ":" -f2)
if [ "$primhor" -ge 12 ] ; then
	phor="PM"
	if [ "$primhor" -gt 12 ] ; then
		hor=$(($primhor - 12))

	else
		hor="12"
	fi
else
	phor="AM"
	hor=$primhor
fi

tiempo="$ano/$mes/$dia $diasem $hor:$seghor $phor"
#Casos de conexion en puertos
case "$porto" in
	"1")
	#Comprobando en el archivo de los logs si el usb se esta ingresando o no
	if [ "$port1" == "Port" ] ; then
		echo " PUERTO1  |  $tiempo  |  ------" >> "$LOG_FILE"
	else
		complastlog=$(cat "$LOG_FILE" | grep "PUERTO1" | tail -1 | awk '{print $8}')
		complastnum=$(cat -n "$LOG_FILE" | grep "PUERTO1" | tail -1 | awk '{print $1}')
		#Como el puerto no se estaba ingresando, se comprueba si al retirar en ese puerto ya habia un log que no se cerro o el log se hizo cuando la pc estaba apagada
		if [ "$complastlog" == "------" ] ; then
			timebef=$(cat "$LOG_FILE" | grep "PUERTO1" | tail -1 | cut -d "|" -f2)
			echo " PUERTO1  |$timebef|  $tiempo  " >> "$LOG_FILE"
			sed -i "$complastnum d" "$LOG_FILE"
		else
			#Log cuando la pc estaba apagada
			echo " PUERTO1  |           ------           |  $tiempo" >> "$LOG_FILE"
		fi
	fi;;
	"3")
	#Comprobando en el archivo de los logs si el usb se esta ingresando o no
	if [ "$port3" == "Port" ] ; then
                echo " PUERTO3  |  $tiempo  |  ------" >> "$LOG_FILE"
        else
                complastlog=$(cat "$LOG_FILE" | grep "PUERTO3" | tail -1 | awk '{print $8}')
                complastnum=$(cat -n "$LOG_FILE" | grep "PUERTO3" | tail -1 | awk '{print $1}')
		#Como el puerto no se estaba ingresando, se comprueba si al retirar en ese puerto ya habia un log que no se cerro o el log se hizo cuando la pc estaba apagada
                if [ "$complastlog" == "------" ] ; then
			timebef=$(cat "$LOG_FILE" | grep "PUERTO3" | tail -1 | cut -d "|" -f2)
                        echo " PUERTO3  |$timebef|  $tiempo  " >> "$LOG_FILE"
                        sed -i "$complastnum d" "$LOG_FILE"

               	else
			#Log cuando la pc estaba apagada
                       	echo " PUERTO3  |           ------           |  $tiempo" >> "$LOG_FILE"

		fi
	fi;;

	"4")
	#Comprobando en el archivo de los logs si el usb se esta ingresando o no
        if [ "$port4" == "Port" ] ; then
                echo " PUERTO4  |  $tiempo  |  ------" >> "$LOG_FILE"
        else
                complastlog=$(cat "$LOG_FILE" | grep "PUERTO4" | tail -1 | awk '{print $8}')
                complastnum=$(cat -n "$LOG_FILE" | grep "PUERTO4" | tail -1 | awk '{print $1}')
		#Como el puerto no se estaba ingresando, se comprueba si al retirar en ese puerto ya habia un log que no se cerro o el log se hizo cuando la pc estaba apagada
                if [ "$complastlog" == "------" ] ; then
                        timebef=$(cat "$LOG_FILE" | grep "PUERTO4" | tail -1 | cut -d "|" -f2)
                        echo " PUERTO4  |$timebef|  $tiempo  " >> "$LOG_FILE"
                        sed -i "$complastnum d" "$LOG_FILE"
                else
			#Log cuando la pc estaba apagada
                        echo " PUERTO4  |           ------           |  $tiempo" >> "$LOG_FILE"
		fi
	fi;;
	esac
