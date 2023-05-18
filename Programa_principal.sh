#!/bin/bash
#Fichero con el programa principal

#Enlazar programa funcional con el de funciones
. ./funciones.sh

#1.Comprobamos si somsos root.

f_somosroot
if [ $? -ne 0 ]; then
    exit 1
fi

echo -e '1.- Comprobación de las tarjetas.'

#2.Comprobar que esta la cableada correctamente configurada.

f_estado_cableada
if [ $? -ne 0 ]; then
    sleep 1
fi

#3 y 4.Subir la tarjeta y comprobar que el dhcp esta perfectamente.

f_subir_tarjeta_cableada
if [ $? -eq 0 ] ; then
    f_comprobacion_dhcp
    if [ $? -eq 0 ] ; then
        echo -e  $nombre_tarjeta_cableada 'está bien configurada.'
    else
        echo -e 'La ip por dhcp esta mal configurada. Mira si tienes el cable RJ45 conectado.'
        exit 1
    fi
else
    echo -e 'No hemos conseguido subir tu tarjeta. Mira si tienes el cable RJ45 conectado.'
fi


echo -e ' '
echo -e '2.- Comprobación que el DHCP condfigurando.'

#5.Comprobar que es dinámica la ip
f_ip_dinamica


#. Comprobar si tenemos conexion a internet 
#f_conexion
#if [ $? -ne 0 ]; then
#    exit 1
#fi
#echo 'Usted tiene conectividad con la red.'