#!/bin/bash
#Fichero con el programa principal

#Autor: José Carlos (Pepe) Rodríguez Cañas
#Descripción: 
#Este proyecto de script trata sobre un programa de detecta los errores de la interfaz cableada que tu quieras. 
#Este script las corrige (es decir, si esta subida comprueba su conectividad, sino, la sube). 
#Además, si la ip que nos otorga es una ip apipa, nos saldrá del programa notificándonos del error que no tiene el cable RJ45 conectado salta un error.
#Tras el correcto funcionamiento de la cableada, nos comprobará la conectividad a Internet (viendo si hace ping a 8.8.8.8 o Internet y si no, nos saldrá del programa ya que el problema está en el router que no sale a Internet.).
#Por último, si los pasos anteriores con válidos, probaremos el ping al DNS (sino está el dominio añadido al sistema, le añadimos el DNS de google por defecto en el fichero de configuración /etc/systemd/resolved.conf y probamos otra vez el ping).

#Fecha: 24-05-2023 - Última modificación

#Enlazar programa funcional con el de funciones
. ./funciones.sh

interfaz=$1
gateway=$(sudo ip route show dev $interfaz | grep default | awk '{print $3}' | head -n 1)
info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')

#1.Comprobar que me ha introducido un parámetro solamente.
if [ $# -ne 1 ]; then
    echo "Para utilizar este script, debes introducir un único valor y este debe ser el nombre de la interfaz cableada."
    echo "Uso: $0 <nombre_interfaz_cableada>"
    exit 1
fi

#2.Comprobamos si somos root.
f_somosroot
if [ $? -ne 0 ]; then
    exit 1
fi

#3.Comprobamos que existe la tarjeta.
f_comprobar_interfaz "$interfaz"
if [ $? -eq 0 ]; then
    echo -e "La interfaz $interfaz existe."
else
    echo -e "La interfaz $interfaz no existe."
    exit 1
fi

echo -e "Espere unos instantes..."

#4.Ejecución del programa principal.
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
