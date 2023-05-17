#!/bin/bash
#Fichero de funciones


#Función 1: comprobamos que la tarjeta cableada si esta UP o DOWN y si existe
function f_estado_cableada {
    nombre_tarjeta_cableada=$(ip link | awk '{sub(/:$/, "", $2); if ($2 ~ /^e/) print $2}' | grep -e '^e')
    
    if [ $(ip link | awk '/\<UP\>/ {sub(/:$/, "", $2); if ($2 ~ /^e/ && $9 == "UP") print $2}' | grep -e '^e') ] ; then
        return 0
    else
        echo -e "La tarjeta cableada $nombre_tarjeta_cableada no ha sido encontrada."
        echo -e "¿Quiere usted subir la tarjeta? [Y/N]"
    return 1
    fi
}

#Función 2: comprobamos el estado de la tarjeta de WIFI.
function f_estado_inalambrica {
    nombre_tarjeta_wifi=$(ip link | awk '/\<UP\>/ {sub(/:$/, "", $2); if ($2 ~ /^w/) print $2}' | grep -e '^w')
    if [ $? ] ; then
        return 0
    else
        echo -e "La tarjeta WIFI no ha sido encontrada."
    return 1
    fi
}


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