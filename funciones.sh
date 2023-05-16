#!/bin/bash
#Fichero de funciones

#Función 1: comprobamos la conectividad
function f_conexion {
    if ping -c 1 -q 8.8.8.8 > /dev/null; then
    return 0
    else
    echo -e "Para ejecutar este script es necesario que disponga de conexion a internet"
    return 1
    fi
}

#Función 2: comprobamos que la tarjeta cableada si esta UP o DOWN
function f_estado_cableada {

}