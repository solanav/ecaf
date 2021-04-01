#!/bin/bash

# This is the first time setup for a clean ubuntu server 20.04LTS server 
# Run as sudo

# Install Erlang and Elixir
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && dpkg -i erlang-solutions_2.0_all.deb
rm erlang-solutions_2.0_all.deb
apt update
apt install -y esl-erlang
apt install -y elixir
apt install inotify-tools
apt install npm

# Install nginx for reverse proxy setup
apt install nginx

# Create the default website space
mkdir -p /var/www/apuntes.seif.es/html
chown -R $USER:$USER /var/www/apuntes.seif.es/html
chmod -R 775 /var/www/apuntes.seif.es

# Add an index 
touch /var/www/apuntes.seif.es/html/index.html
echo "Web no disponible en estos momentos, intentelo más tarde." > /var/www/apuntes.seif.es/html/index.html

# Add config block
touch /etc/nginx/sites-available/apuntes.seif.es
echo "server {
        listen 80;
        listen [::]:80;

        root /var/www/apuntes.seif.es/html;
        index index.html index.htm index.nginx-debian.html;

        server_name apuntes.seif.es www.apuntes.seif.es;

        location / {
                try_files $uri $uri/ =404;
        }
}" > /etc/nginx/sites-available/apuntes.seif.es
ln -s /etc/nginx/sites-available/apuntes.seif.es /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# Install the certificates
apt install certbot python3-certbot-nginx
nginx -t
systemctl reload nginx
certbot --nginx -d apuntes.seif.es -d www.apuntes.seif.es --register-unsafely-without-email

echo "Look at the config and modify the nginx configuration."
### Metemos lo siguiente en la configuracion de NGINX para que funcione con Phoenix
### Arriba del todo en el archivo de config
# upstream phoenixapp {
#         server localhost:1312;
# }
#
### Dentro de Server, el de 443
# location / {
#         allow all;
# 
#         proxy_http_version 1.1;
#         proxy_set_header X-Real-IP $remote_addr;
#         proxy_set_header Host $http_host;
#         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#         proxy_set_header X-Cluster-Client-Ip $remote_addr;
# 
#         # Websocket stuff
#         proxy_set_header Upgrade $http_upgrade;
#         proxy_set_header Connection "upgrade";
# 
#         proxy_pass http://phoenixapp;
# }
# 
# location ~* ^.+\.(css|cur|gif|gz|ico|jpg|jpeg|js|png|svg|woff|woff2)$ {
#         root /home/<USERNAME>/ecaf/priv/static;
#         etag off;
#         expires max;
#         add_header Cache-Control public;
# }