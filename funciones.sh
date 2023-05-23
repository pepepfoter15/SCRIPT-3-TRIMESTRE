#!/bin/bash
#Fichero de funciones

#Autor: José Carlos (Pepe) Rodríguez Cañas
#Descripción: Este proyecto de script trata sobre un script de detecta los errores de la interfaz cableada que tu quieras y las corrige para que funcione correctamente tanto la cableada, como el DNS, como la conectividad a Internet.


# Función 1: Para comprobar que somos root.
function f_somosroot {
    if [ $UID -eq 0 ]; then
        return 0
    else
        echo "Para ejecutar este script es necesario que seas superusuario"
        return 1
    fi
}

#Función 2: Comprobar conectividad con el dominio de Google.
function f_ping_google {
    if ping -c 4 www.google.com > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}


#Función 3: Comprobamos la conectividad con Internet.
function f_conexion {
    if ping -c 1 -q 8.8.8.8 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

#Función 4: Comprobar el ping al gateway de mi red local.
function f_ping_gateway {
    gateway=$(sudo ip route show dev $interfaz | grep default | awk '{print $3}' | head -n 1)
    if ping -c 4 $gateway > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

#Función 5: comprobamos que la tarjeta cableada si existe o no.
function f_comprobar_interfaz() {
    interfaz="$1"
    if ip a show "$interfaz" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

#Función 6: Comprobar que la ip que nos muestra es una apipa.

function f_apipa_dhcp {
    if [ $(ip addr show | awk '/inet / {split($2, a, "."); if(a[1] == "169") print $2}') ] ; then
        return 0
    else 
        return 1
    fi
}

#Función 7: Subir la tarjeta cableada.

function f_subir_tarjeta_cableada() {
    interfaz="$1"
    if ifup $interfaz > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
