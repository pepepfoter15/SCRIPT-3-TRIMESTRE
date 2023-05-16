#!/bin/bash
#Fichero con el programa principal

#Enlazar programa funcional con el de funciones
. ./funciones.sh

#1. Comprobar que esta la cableada correctamente configurada
f_estado_cableada
if [ $? -ne 0 ]; then
    exit 1
fi

echo 'El nombre de la tarjeta es: '$nombre_tarjeta_cableada


#. Comprobar si tenemos conexion a internet 
f_conexion
if [ $? -ne 0 ]; then
    exit 1
fi

echo 'Usted tiene conectividad con la red.'