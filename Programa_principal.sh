#!/bin/bash
#Fichero con el programa principal

#Enlazar programa funcional con el de funciones
. ./funciones.sh

#1.Comprobamos si somsos root.

f_somosroot
if [ $? -ne 0 ]; then
    exit 1
fi

f_ping_gateway
if [ $? -eq 0 ]
    echo -e "Usted tiene bien configurada la ip porque llega el ping al gateway."
    f_conexion
    if [ $? -eq 0]; then
        echo -e "Tienes conectividad con Internet."
        f_ping_google
        if [ $? -eq 0 ]; then
            echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
            exit 0
        else
            echo -e "Error al conectar con la servidor DNS."
            echo -e "Tienes error con el DNS. Añadiendo el DNS de Google..."
            echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf > /dev/null
            systemctl restart systemd-resolved
            f_ping_google
            echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
            exit 0
        fi
    else
        echo -e "No tienes conectividad con ordenador ya que el router al que estás conectado, no tiene conectividad con Internet (8.8.8.8)"
        echo -e "El problema lo tiene el router que no esta bien enrutado."
        echo -e "No puedes hacer nada :)."
        exit 1
    fi
    sleep 1
else
    f_encontrar_cableada
    echo -e "Interfaz encontrada: " $nombre_tarjeta_cableada
    f_subir_tarjeta_cableada
    if [ $? -eq 1 ] ; then
        echo -e "Tienes mal configurada la interfaz "$nombre_tarjeta_cableada
        echo -e "Configuración de IP estática inválida. Aplicando automáticamente IP por DHCP..."
        echo -e "auto "$nombre_tarjeta_cableada | sudo tee /etc/network/interfaces > /dev/null
        echo -e "iface "$nombre_tarjeta_cableada" inet dhcp" | sudo tee -a /etc/network/interfaces > /dev/null
        f_subir_tarjeta_cableada
        f_apipa_dhcp
        if [ $? -eq 1 ]; then
            echo -e 'La ip por dhcp esta mal configurada. Mira si tienes el cable RJ45 conectado.'
            exit 1
        fi
        echo -e "Pasamos a la prueba del ping al gateway..."
        f_ping_gateway
        if [ $? -eq 0 ]
            echo -e "Usted tiene bien configurada la ip porque llega el ping al gateway."
            f_conexion
            if [ $? -eq 0]; then
                echo -e "Tienes conectividad con Internet."
                f_ping_google
                if [ $? -eq 0 ]; then
                    echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                    exit 0
                else
                    echo -e "Error al conectar con la servidor DNS."
                    echo -e "Tienes error con el DNS. Añadiendo el DNS de Google..."
                    echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf > /dev/null
                    systemctl restart systemd-resolved
                    f_ping_google
                    echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                    exit 0
                fi
            else
                echo -e "No tienes conectividad con ordenador ya que el router al que estás conectado, no tiene conectividad con Internet (8.8.8.8)"
                echo -e "El problema lo tiene el router que no esta bien enrutado."
                echo -e "No puedes hacer nada :)."
                exit 1
            fi
        fi
    else
        f_apipa_dhcp
        if [ $? -eq 1 ]; then
            echo -e 'La ip por dhcp esta mal configurada. Mira si tienes el cable RJ45 conectado.'
            exit 1
        fi
        echo -e "Pasamos a la prueba del ping al gateway..."
        f_ping_gateway
        if [ $? -eq 0 ]
            echo -e "Usted tiene bien configurada la ip porque llega el ping al gateway."
            f_conexion
            if [ $? -eq 0]; then
                echo -e "Tienes conectividad con Internet."
                f_ping_google
                if [ $? -eq 0 ]; then
                    echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                    exit 0
                else
                    echo -e "Error al conectar con la servidor DNS."
                    echo -e "Tienes error con el DNS. Añadiendo el DNS de Google..."
                    echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf > /dev/null
                    systemctl restart systemd-resolved
                    f_ping_google
                    echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                    exit 0
                fi
            else
                echo -e "No tienes conectividad con ordenador ya que el router al que estás conectado, no tiene conectividad con Internet (8.8.8.8)"
                echo -e "El problema lo tiene el router que no esta bien enrutado."
                echo -e "No puedes hacer nada :)."
                exit 1
            fi
        fi
    fi
fi


echo -e "Esta es la ip de la tarjeta cableada que vienen dadas por DHCP:"
echo -e "Cableada: "$info_ip_cableada
echo -e "Puerta de enlace: "$gateway
