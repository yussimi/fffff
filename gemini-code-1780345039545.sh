# 1. Instalar paquetes de emparentamiento y Samba
DEBIAN_FRONTEND=noninteractive sudo apt install samba winbind libpam-winbind libnss-winbind krb5-user -y

# 2. Configurar Kerberos
sudo tee /etc/krb5.conf << 'EOF'
[libdefaults]
    default_realm = TEST.LAN
    dns_lookup_realm = false
    dns_lookup_kdc = true
EOF

# 3. Configurar Samba para Active Directory
sudo tee /etc/samba/smb.conf << 'EOF'
[global]
   workgroup = TEST
   realm = TEST.LAN
   security = ADS
   winbind refresh tickets = Yes
   idmap config * : backend = tdb
   idmap config * : range = 3000-7999
   idmap config TEST : backend = rid
   idmap config TEST : range = 10000-999999
   template shell = /bin/bash
   winbind use default domain = true
   winbind offline logon = false
EOF

# 4. Unir Ubuntu al dominio (reemplaza 'ContraseñaAD' con la del Administrador de Windows)
sudo net ads join -U Administrador%Admin123

# 5. Configurar el cambio de nombres del sistema
sudo sed -i 's/passwd:.*/passwd:         files winbind/' /etc/nsswitch.conf
sudo sed -i 's/group:.*/group:          files winbind/' /etc/nsswitch.conf

# 6. Reiniciar y habilitar servicios
sudo systemctl restart smbd nmbd winbind
sudo systemctl enable smbd nmbd winbind

# 7. Crear directorio local de intercambio
sudo mkdir /izenaabizena
sudo chmod 777 /izenaabizena
