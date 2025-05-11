#!/bin/bash

# Configuración
archivoRegistros="/var/log/logsUSB.log"
direccionUDEV="/etc/udev/rules.d/99-usb-custom.rules"
ubicacionScript="/usr/local/bin/scriptUSB.sh"

# Verificar si el script ya existe, si no, crearlo
if [[ ! -f $ubicacionScript ]] ; then
    sudo tee "$ubicacionScript" > /dev/null <<'EOF'
#!/bin/bash

archivoRegistros="/var/log/logsUSB.log"
puertoID=$(basename "$(dirname "$DEVNAME")")
fecha=$(date "+%Y/%m/%d %a %I:%M %p")

# Verificar si el puertoID es válido
if [ -z "$puertoID" ] ; then
	exit 0
fi
if [ "$puertoID" = "." ] ; then
    exit 0
fi

case "$1" in
    "1")
        # USB conectado
        echo "PUERTO$puertoID | $fecha | " | column -t -s " " >> "$archivoRegistros" ;;
    "0")
        # Verificacion de desconexión
		# Verificar si el puertoID ya tiene una entrada en el log
        ultimoRegistro=$(cat "$archivoRegistros" | grep "PUERTO$puertoID |.*| $" | tail -n 1)
		numeracionLineaUltimoRegistro=$(cat -n "$archivoRegistros" | grep "PUERTO$puertoID |.*| $" | tail -n 1 )
		numeroLineaUltimoRegistro=$(echo "$numeracionLineaUltimoRegistro" | awk '{print $1}')
		
        if [ -n "$ultimoRegistro" ] ; then
            # Completar la entrada existente
            archivoTemporal=$(mktemp)
			# Extraer la fecha de conexión y puertoID
			puerto=$(echo "$ultimoRegistro" | awk -F'|' '{print $1}' | xargs)
			fechaConexion=$(echo "$ultimoRegistro" | awk -F'|' '{print $2}' | xargs)
			# Editar el registro existente con la fecha de desconexión
			sed -i '$numeroLineaUltimoRegistros/.*/PUERTO$puertoID | $fechaConexion | $fecha/' "$archivoRegistros"
			cat "$archivoRegistros" > "$archivoTemporal"
			sudo mv "$archivoTemporal" "$archivoRegistros"
        else
            # Registrar desconexión sin conexión previa
            echo "PUERTO$puertoID | | $fecha" | column -t -s " " >> "$archivoRegistros"
        fi
        ;;
esac
EOF

    sudo chmod +x "$ubicacionScript"
fi

# Crear archivo de reglas udev si no existe
if [ ! -f "$UDEV_RULES_PATH" ] ; then
    sudo tee "$direccionUDEV" > /dev/null <<'EOF'
ACTION=="add", SUBSYSTEM=="usb", RUN+="/usr/local/bin/scriptUSB.sh 1"
ACTION=="remove", SUBSYSTEM=="usb", RUN+="/usr/local/bin/scriptUSB.sh 0"
EOF
    sudo udevadm control --reload-rules
    sudo udevadm trigger
fi

if [[ ! -f $archivoRegistros ]] ; then
    # Crear archivo de log y dar permisos
    sudo touch "$archivoRegistros"
    sudo chmod 666 "$archivoRegistros"
    echo "PUERTOS | FECHA_CONEXION | FECHA_DESCONEXION" | column -t >> $archivoRegistros

fi