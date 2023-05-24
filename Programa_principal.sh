#!/bin/bash
#Fichero con el programa principal

#Autor: José Carlos (Pepe) Rodríguez Cañas
#Descripción: 
#Este proyecto de script trata sobre un programa de detecta los errores de la interfaz cableada que tu quieras. 
#Este script las corrige (es decir, si esta subida comprueba su conectividad, sino, la sube). 
#Además, si la ip que nos otorga es una ip apipa, nos saldrá del programa notificándonos del error que no tiene el cable RJ45 conectado salta un error.
#Tras el correcto funcionamiento de la cableada, nos comprobará la conectividad a Internet (viendo si hace ping a 8.8.8.8 o Internet y si no, nos saldrá del programa ya que el problema está en el router que no sale a Internet.).
#Por último, si los pasos anteriores con válidos, probaremos el ping al DNS (sino está el dominio añadido al sistema, le añadimos el DNS de google por defecto en el fichero de configuración /etc/systemd/resolved.conf y probamos otra vez el ping).

#Fecha: 24-05-2023 - Última modificación.

#Enlazar programa funcional con el de funciones.
. ./funciones.sh

#Colores:
verde="\e[32m"
amarillo="\e[33m"
rojo="\e[31m"
cierre="\e[0m"

interfaz=$1
info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')
dns=$(cat /etc/resolv.conf | grep nameserver | awk {'print $2'} | head -n 1)

#1.Comprobar que me ha introducido un parámetro solamente.
if [ $# -ne 1 ]; then
    echo -e "Para utilizar este script, debes introducir un único valor y este debe ser el nombre de la interfaz cableada."
    echo -e "${amarillo}Uso: $0 <nombre_interfaz_cableada> ${cierre}"
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
    echo -e "La interfaz${verde} $interfaz ${cierre}existe."
else
    echo -e "La interfaz $interfaz no existe."
    exit 1
fi

gateway=$(sudo ip route show dev $interfaz | grep default | awk '{print $3}' | head -n 1)

echo -e "${amarillo}Espere unos instantes...${cierre}"

#4.Ejecución del programa principal.
f_subir_tarjeta_cableada "$interfaz"
if [ $? -eq 0 ]; then
    echo -e "La tarjeta${verde} $interfaz ${cierre}ha sido levantada ${verde}exitosamente${cierre}."
    f_ping_gateway
    if [ $? -eq 0 ]; then
        echo -e "${verde}Conexión al gateway completada.${cierre}"
        f_conexion
        if [ $? -eq 0 ]; then
            echo -e "${verde}Tienes conectividad con Internet.${cierre}"
            f_ping_google
            if [ $? -eq 0 ]; then
                echo -e "${verde}Perfecto, usted tiene conectividad con el servidor DNS.${cierre}"
                info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')
                echo -e "Esta es la información de la tarjeta cableada (dada por DHCP):"
                echo -e "Cableada: ${verde}$info_ip_cableada${cierre}"
                echo -e "Puerta de enlace: ${verde}$gateway${cierre}"
                echo -e "DNS principal: ${verde}$dns${cierre}"
                exit 0
            else
                echo -e "${rojo}Error al conectar con el servidor DNS.${cierre}"
                echo -e "Tienes error con el DNS. ${amarillo}Añadiendo el DNS de Google...${cierre}"
                echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf > /dev/null
                systemctl restart systemd-resolved
                f_ping_google
                echo -e "${verde}Perfecto, usted tiene conectividad con el servidor DNS.${cierre}"
                exit 0
            fi
        else
            echo -e "${rojo}No tienes conectividad a Internet, el router no está bien enrutado.${cierre}"
            echo -e "No puedes hacer nada :(."
            exit 1
        fi
    else
        echo -e "Tienes mal configurada la interfaz ${rojo}$interfaz.${cierre}"
        echo -e "Configuración de IP estática inválida. ${amarillo}Aplicando automáticamente IP por DHCP...${cierre}"
        echo "auto $interfaz" | sudo tee /etc/network/interfaces > /dev/null
        echo "iface $interfaz inet dhcp" | sudo tee -a /etc/network/interfaces > /dev/null
        f_subir_tarjeta_cableada "$interfaz"
        f_ping_gateway
        if [ $? -eq 0 ]; then
            echo -e "${verde}Conexión al gateway completada.${cierre}"
            f_conexion
            if [ $? -eq 0 ]; then
                echo -e "${verde}Tienes conectividad con Internet.${cierre}"
                f_ping_google
                if [ $? -eq 0 ]; then
                    echo -e "${verde}Perfecto, usted tiene conectividad con el servidor DNS.${cierre}"
                    info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')
                    echo -e "Esta es la información de la tarjeta cableada (dada por DHCP):"
                    echo -e "Cableada: ${verde}$info_ip_cableada${cierre}"
                    echo -e "Puerta de enlace: ${verde}$gateway${cierre}"
                    echo -e "DNS principal: ${verde}$dns${cierre}"
                    echo 
                    exit 0
                else
                    echo -e "${rojo}Error al conectar con el servidor DNS.${cierre}"
                    echo -e "Tienes error con el DNS. ${amarillo}Añadiendo el DNS de Google...${cierre}"
                    echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf > /dev/null
                    systemctl restart systemd-resolved
                    f_ping_google
                    echo -e "${verde}Perfecto, usted tiene conectividad con el servidor DNS.${cierre}"
                    exit 0
                fi
            else
                echo -e "${rojo}No tienes conectividad a Internet, el router no está bien enrutado.${cierre}"
                echo -e "No puedes hacer nada :(."
                exit 1
            fi
        else
            f_apipa_dhcp
            if [ $? -eq 0 ]; then
                echo -e "${rojo}La IP por DHCP está mal configurada.${cierre} ${amarillo}Verifica si tienes el cable RJ45 conectado.${cierre}"
                exit 0
            fi
        fi
    fi
else
    echo -e "No se pudo levantar la tarjeta ${rojo}$interfaz${cierre}."
    echo -e "Tienes mal configurada la interfaz ${rojo}$interfaz${cierre}."
    echo -e "Configuración de IP estática inválida. ${amarillo}Aplicando automáticamente IP por DHCP...${cierre}"
    echo "auto $interfaz" | sudo tee /etc/network/interfaces > /dev/null
    echo "iface $interfaz inet dhcp" | sudo tee -a /etc/network/interfaces > /dev/null
    f_subir_tarjeta_cableada "$interfaz"
    f_ping_gateway
    if [ $? -eq 0 ]; then
        echo -e "${verde}Conexión al gateway completada.${cierre}"
        f_conexion
        if [ $? -eq 0 ]; then
            echo -e "${verde}Tienes conectividad con Internet.${cierre}"
            f_ping_google
            if [ $? -eq 0 ]; then
                echo -e "${verde}Perfecto, usted tiene conectividad con el servidor DNS.${cierre}"
                info_ip_cableada=$(ip a | grep "scope global dynamic" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sed -n '1p;')
                echo -e "Esta es la información de la tarjeta cableada (dada por DHCP):"
                echo -e "Cableada: ${verde}$info_ip_cableada${cierre}"
                echo -e "Puerta de enlace: ${verde}$gateway${cierre}"
                echo -e "DNS principal: ${verde}$dns${cierre}"
                exit 0
            else
                echo -e "${rojo}Error al conectar con el servidor DNS.${cierre}"
                echo -e "Tienes error con el DNS. ${amarillo}Añadiendo el DNS de Google...${cierre}"
                echo "DNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf > /dev/null
                systemctl restart systemd-resolved
                f_ping_google
                echo -e "${verde}Perfecto, usted tiene conectividad con el servidor DNS.${cierre}"
                exit 0
            fi
        else
            echo -e "${rojo}No tienes conectividad a Internet, el router no está bien enrutado.${cierre}"
            echo -e "No puedes hacer nada :(."
            exit 1
        fi
    else
        f_apipa_dhcp
        if [ $? -eq 0 ]; then
            echo -e "${rojo}La IP por DHCP está mal configurada.${cierre} ${amarillo}Verifica si tienes el cable RJ45 conectado.${cierre}"
            exit 0
        fi
    fi
fi
