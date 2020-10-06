#!/bin/bash

SQUID_USER="semind"
SQUID_PASS="semind"

# Squid Installer

/bin/rm -rf /etc/squid
/usr/bin/apt update
/usr/bin/apt -y install apache2-utils squid
touch /etc/squid/passwd
/bin/rm -f /etc/squid/squid.conf
/usr/bin/touch /etc/squid/blacklist.acl
/usr/bin/wget --no-check-certificate -O /etc/squid/squid.conf https://raw.githubusercontent.com/NanoProxies/Proxy-Creator/master/squid.conf
/sbin/iptables -I INPUT -p tcp --dport SQUID_PORT -j ACCEPT
/sbin/iptables-save


# Get number of IP-addresses
IP_ALL=$(/sbin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}')
IP_ALL_ARRAY=($IP_ALL)

# when there are more the 3 (exrenal,interlan,localhost) aka more than 2 external
if (( ${#IP_ALL_ARRAY[@]} >= 3 ))
then
echo "Multiple External IPs"

SQUID_CONFIG="\n"
for IP_ADDR in ${IP_ALL_ARRAY[@]}; do
echo "adding ${IP_ADDR}"
ACL_NAME="proxy_ip_${IP_ADDR//\./_}"
SQUID_CONFIG+="acl ${ACL_NAME} myip ${IP_ADDR}\n"
SQUID_CONFIG+="tcp_outgoing_address ${IP_ADDR} ${ACL_NAME}\n\n"
done

echo "Saving changes"
echo -e $SQUID_CONFIG >> /etc/squid/squid.conf
echo "Restarting squid..."
#systemctl restart squid

fi


echo "Adding user ${SQUID_USER}"
/usr/bin/htpasswd -b -c /etc/squid/passwd $SQUID_USERNAME $SQUID_PASSWORD

systemctl enable squid
systemctl restart squid
echo "done"
systemctl status squid
