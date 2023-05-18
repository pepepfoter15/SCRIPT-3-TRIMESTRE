#!/bin/bash
#Fichero de funciones

# Función : para comprobar que somos root.

function f_somosroot {
    if [ $UID -eq 0 ]; then
        return 0
    else
        echo "Para ejecutar este script es necesario que seas superusuario"
        return 1
    fi
}

#Función : Comprobar conectividad

function f_ping_google {
    if ping -c 4 www.google.com > /dev/null; then
        return 0
    else
        return 1
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

function f_ping_s {
    gateway=$(ip route show dev nombre_tarjeta_cableada | grep default | awk '{print $3}')
    if ping -c 4 $gateway > /dev/null; then
        return 0
    else
        return 1
}

#Función : comprobamos que la tarjeta cableada si esta UP o DOWN y si existe.

function f_estado_cableada {
    nombre_tarjeta_cableada=$(ip link | awk '{sub(/:$/, "", $2); if ($2 ~ /^e/) print $2}' | grep -e '^e')
    if [ $(ip link | awk '/\<UP\>/ {sub(/:$/, "", $2); if ($2 ~ /^e/ && $9 == "UP") print $2}' | grep -e '^e') ] ; then
        return 0
    else
        echo -e "La tarjeta cableada $nombre_tarjeta_cableada no ha sido encontrada."
        echo -e "Subo automáticamente la tarjeta cableada."
        return 1
    fi
}

#Función : Subir la tarjeta cableada.

function f_subir_tarjeta_cableada {
    sudo ifup $nombre_tarjeta_cableada > /dev/null 2>&1
}

#Función : Comprobar que el estado del DHCP 

function f_comprobacion_dhcp {
    if [ $(ip addr show | awk '/inet / {split($2, a, "."); if(a[1] == "169") print $2}') ] ; then
        return 1
    else 
        return 0
    fi
}


#Función : comprobamos el estado de la tarjeta de WIFI.
function f_estado_inalambrica {
    nombre_tarjeta_wifi=$(ip link | awk '/\<UP\>/ {sub(/:$/, "", $2); if ($2 ~ /^w/) print $2}' | grep -e '^w')
    if [ $? ] ; then
        return 0
    else
        echo -e "La tarjeta WIFI no ha sido encontrada."
        echo -e "Subo automáticamente la tarjeta de WIFI."
        sudo ifup $nombre_tarjeta_wifi
    return 1
    fi
}

#Función : Comprobar si es dinámica la ip.
function f_ip_dinamica {
    info_network_interfaces=$(grep -E '^(auto|iface)' /etc/network/interfaces)
    echo -e "En el fichero /etc/network/interfaces podemos ver que esta configurado dinámico por lo siguiente:"
    echo -e $info_network_interfaces
    info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')
    info_ip_wifi=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '3p;')
    echo -e "Estos son las ips que vienen dadas por DHCP:"
    echo -e "Cableada: "$info_ip_cableada
    echo -e "WIFI: "$info_ip_wifi
}

