#!/bin/bash
#Fichero con el programa principal

#Autor: José Carlos (Pepe) Rodríguez Cañas
#Descripción: Este proyecto de script trata sobre un script de detecta los errores de la interfaz cableada que tu quieras y las corrige para que funcione correctamente tanto la cableada, como el DNS, como la conectividad a Internet.

#Enlazar programa funcional con el de funciones
. ./funciones.sh

interfaz=$1
gateway=$(sudo ip route show dev $interfaz | grep default | awk '{print $3}' | head -n 1)
info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')

#1.Comprobamos si somos root.
f_somosroot
if [ $? -ne 0 ]; then
    exit 1
fi

#2.Comprobamos que existe la tarjeta.
f_comprobar_interfaz "$interfaz"
if [ $? -eq 0 ]; then
    echo -e "La interfaz $interfaz existe."
else
    echo -e "La interfaz $interfaz no existe."
    exit 1
fi

#3.Ejecución del programa principal.
f_subir_tarjeta_cableada "$interfaz"
if [ $? -eq 0 ]; then
    echo -e "La tarjeta $interfaz ha sido levantada exitosamente."
    f_ping_gateway
    if [ $? -eq 0 ]; then
        echo -e "Usted tiene bien configurada la IP porque llega el ping al gateway."
        f_conexion
        if [ $? -eq 0 ]; then
            echo -e "Tienes conectividad con Internet."
            f_ping_google
            if [ $? -eq 0 ]; then
                echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')
                echo -e "Esta es la IP de la tarjeta cableada que viene dada por DHCP:"
                echo -e "Cableada: $info_ip_cableada"
                echo -e "Puerta de enlace: $gateway"
                exit 0
            else
                echo -e "Error al conectar con el servidor DNS."
                echo -e "Tienes error con el DNS. Añadiendo el DNS de Google..."
                echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf > /dev/null
                systemctl restart systemd-resolved
                f_ping_google
                echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                exit 0
            fi
        else
            echo -e "No tienes conectividad con Internet ya que el router al que estás conectado no tiene conectividad con Internet (8.8.8.8)."
            echo -e "El problema lo tiene el router que no está bien enrutado."
            echo -e "No puedes hacer nada :)."
            exit 1
        fi
    else
        echo -e "Tienes mal configurada la interfaz $interfaz."
        echo -e "Configuración de IP estática inválida. Aplicando automáticamente IP por DHCP..."
        echo "auto $interfaz" | sudo tee /etc/network/interfaces > /dev/null
        echo "iface $interfaz inet dhcp" | sudo tee -a /etc/network/interfaces > /dev/null
        f_subir_tarjeta_cableada "$interfaz"
        f_ping_gateway
        if [ $? -eq 0 ]; then
            echo -e "Usted tiene bien configurada la IP porque llega el ping al gateway."
            f_conexion
            if [ $? -eq 0 ]; then
                echo -e "Tienes conectividad con Internet."
                f_ping_google
                if [ $? -eq 0 ]; then
                    echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                    info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')
                    echo -e "Esta es la IP de la tarjeta cableada que viene dada por DHCP:"
                    echo -e "Cableada: $info_ip_cableada"
                    echo -e "Puerta de enlace: $gateway"
                    exit 0
                else
                    echo -e "Error al conectar con el servidor DNS."
                    echo -e "Tienes error con el DNS. Añadiendo el DNS de Google..."
                    echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf > /dev/null
                    systemctl restart systemd-resolved
                    f_ping_google
                    echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                    exit 0
                fi
            else
                echo -e "No tienes conectividad con Internet ya que el router al que estás conectado no tiene conectividad con Internet (8.8.8.8)."
                echo -e "El problema lo tiene el router que no está bien enrutado."
                echo -e "No puedes hacer nada :)."
                exit 1
            fi
        else
            f_apipa_dhcp
            if [ $? -eq 0 ]; then
                echo -e "La IP por DHCP está mal configurada. Verifica si tienes el cable RJ45 conectado."
                echo -e "No se pudo levantar la tarjeta $interfaz."
                exit 0
            fi
        fi
    fi
else
    echo -e "No se pudo levantar la tarjeta $interfaz."
    echo -e "Tienes mal configurada la interfaz $interfaz."
    echo -e "Configuración de IP estática inválida. Aplicando automáticamente IP por DHCP..."
    echo "auto $interfaz" | sudo tee /etc/network/interfaces > /dev/null
    echo "iface $interfaz inet dhcp" | sudo tee -a /etc/network/interfaces > /dev/null
    f_subir_tarjeta_cableada "$interfaz"
    f_ping_gateway
    if [ $? -eq 0 ]; then
        echo -e "Usted tiene bien configurada la IP porque llega el ping al gateway."
        f_conexion
        if [ $? -eq 0 ]; then
            echo -e "Tienes conectividad con Internet."
            f_ping_google
            if [ $? -eq 0 ]; then
                echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')
                echo -e "Esta es la IP de la tarjeta cableada que viene dada por DHCP:"
                echo -e "Cableada: $info_ip_cableada"
                echo -e "Puerta de enlace: $gateway"
                exit 0
            else
                echo -e "Error al conectar con el servidor DNS."
                echo -e "Tienes error con el DNS. Añadiendo el DNS de Google..."
                echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf > /dev/null
                systemctl restart systemd-resolved
                f_ping_google
                echo -e "Perfecto, usted tiene conectividad con el servidor DNS."
                exit 0
            fi
        else
            echo -e "No tienes conectividad con Internet ya que el router al que estás conectado no tiene conectividad con Internet (8.8.8.8)."
            echo -e "El problema lo tiene el router que no está bien enrutado."
            echo -e "No puedes hacer nada :)."
            exit 1
        fi
    else
        f_apipa_dhcp
        if [ $? -eq 0 ]; then
            echo -e "La IP por DHCP está mal configurada. Verifica si tienes el cable RJ45 conectado."
            echo -e "No se pudo levantar la tarjeta $interfaz."
            exit 0
        fi
    fi
fi
