#!/bin/bash
#Fichero de funciones

nombre_tarjeta_cableada=$(ip link | awk '{sub(/:$/, "", $2); if ($2 ~ /^e/) print $2}' | grep -e '^e' | head -n 1)
gateway=$(ip route show dev $nombre_tarjeta_cableada | grep default | awk '{print $3}')
info_network_interfaces=$(grep -E '^(auto|iface)' /etc/network/interfaces)
info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')

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

function f_ping_gateway {
    if ping -c 4 $gateway > /dev/null; then
        return 0
    else
        return 1
    fi
}

#Función : comprobamos que la tarjeta cableada si esta UP o DOWN y si existe.

function f_estado_cableada {
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

function f_apipa_dhcp {
    if [ $(ip addr show | awk '/inet / {split($2, a, "."); if(a[1] == "169") print $2}') ] ; then
        return 1
    else 
        return 0
    fi
}


#Función : Comprobar si es dinámica la ip.
function f_ip_dinamica {
    echo -e "Esta es la ip de la tarjeta cableada que vienen dadas por DHCP:"
    echo -e "Cableada: "$info_ip_cableada
    echo -e "Puerta de enlace: "$gateway
}

