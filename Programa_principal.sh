#!/bin/bash
#Fichero con el programa principal

#Enlazar programa funcional con el de funciones
. ./funciones.sh

#1. Comprobar que esta la cableada correctamente configurada
f_estado_cableada
if [ $? -ne 0 ]; then
    exit 1
fi
echo 'El nombre de la tarjeta cableada es: '$nombre_tarjeta_cableada

f_estado_inalambrica
if [ $? -ne 0 ]; then
    exit 1
fi
echo 'El nombre de la tarjeta WIFI es: '$nombre_tarjeta_wifi

#. Comprobar si tenemos conexion a internet 
#f_conexion
#if [ $? -ne 0 ]; then
#    exit 1
#fi
#echo 'Usted tiene conectividad con la red.'