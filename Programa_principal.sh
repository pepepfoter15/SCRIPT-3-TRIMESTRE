#!/bin/bash
#Fichero con el programa principal

#Enlazar programa funcional con el de funciones
. ./funciones.sh

#1.Comprobar si tenemos conexion a internet 
f_conexion
if [ $? -ne 0 ]; then
    exit 1
fi

echo '1 ok --------------------------------------------------------------'

