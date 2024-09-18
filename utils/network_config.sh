#!/bin/bash

# Leer entradas del usuario
echo "IP Address:"
read -e ip

echo "Netmask (CIDR, e.g., /24):"
read -e netmask

echo "Gateway:"
read -e gateway

echo "DNS (comma separated):"
read -e dns

echo "Domain (comma separated):"
read -e domain

echo "Hostname:"
read -e hostname

echo "Interface"
read -e interface

# Asignar el hostname
echo "$hostname" > /etc/hostname
hostnamectl set-hostname "$hostname"

# Dividir las entradas de DNS y Domain
IFS=',' read -ra dns_list <<< "$dns"
IFS=',' read -ra domain_list <<< "$domain"

# Construir el archivo YAML
netplan_file="/etc/netplan/01-netcfg.yaml"

cat <<EOF > $netplan_file
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
      dhcp6: no
      addresses:
        - $ip$netmask
      gateway4: $gateway
      nameservers:
        addresses:
EOF

# Agregar DNS al archivo YAML
for dns_entry in "${dns_list[@]}"; do
    echo "          - $dns_entry" >> $netplan_file
done

# Agregar dominios de búsqueda al archivo YAML
echo "        search:" >> $netplan_file
for domain_entry in "${domain_list[@]}"; do
    echo "          - $domain_entry" >> $netplan_file
done

echo "Archivo YAML generado en $netplan_file"

# Aplicar la configuración de netplan
netplan apply