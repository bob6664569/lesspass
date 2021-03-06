#!/usr/bin/env bash

create_wildcard_certificate () {
  openssl req -x509 -newkey rsa:4096 -nodes -keyout ${1}.key -out ${1}.crt -days 365 -subj "/C=FR/ST=Gironde/L=Bordeaux/O=LessPass/OU=LessPass/CN=*.${1}"
}

if [[ ! -f /opt/app/ssl/${FQDN}.crt || ! -f /opt/app/ssl/${FQDN}.key ]]; then
  echo "${FQDN}.crt or ${FQDN}.key not found! Generate wildcard certificate"
  cd /opt/app/ssl
  create_wildcard_certificate ${FQDN}
fi

mkdir -p /etc/httpd/ssl
chmod 755 /etc/httpd/ssl
cp /opt/app/ssl/${FQDN}.crt /etc/httpd/ssl/
chmod 644 /etc/httpd/ssl/${FQDN}.crt

mkdir -p /etc/httpd/ssl/private
chmod 710 /etc/httpd/ssl/private
cp /opt/app/ssl/${FQDN}.key /etc/httpd/ssl/private/
chmod 640 /etc/httpd/ssl/private/${FQDN}.key

/opt/app/venv/bin/python /opt/app/generate_apache_conf.py

cat /etc/httpd/conf.d/lesspass.conf

exec "$@"