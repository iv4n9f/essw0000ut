#!/bin/bash

# Leer entradas del usuario
echo "IP Address:"
read ip

echo "Netmask (CIDR, e.g., /24):"
read netmask

echo "Gateway:"
read gateway

echo "DNS (comma separated):"
read dns

echo "Domain (comma separated):"
read domain

echo "Hostname:"
read hostname

echo "Interface"
read interface

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