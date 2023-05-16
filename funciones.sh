#!/bin/bash
#Fichero de funciones


#Función 1: comprobamos que la tarjeta cableada si esta UP o DOWN y si existe
function f_estado_cableada {
    nombre_tarjeta_cableada=$(ip link | awk '/\<UP\>/ {sub(/:$/, "", $2); if ($2 ~ /^e/ && $9 == "UP") print $2}' | grep -e '^e')
    if [ $? ] ; then
        return 0
    else
        echo -e "La tarjeta cableada no ha sido encontrada."
    return 1
    fi
}


#Función 2: comprobamos el estado de la tarjeta de WIFI.

#Función : comprobamos la conectividad
function f_conexion {
    if ping -c 1 -q 8.8.8.8 > /dev/null; then
        return 0
    else
        echo -e "Para ejecutar este script es necesario que disponga de conexion a internet."
        echo -e "Para ello, deberá tener la cableada subida y perfectamente configurada."
    return 1
    fi
}