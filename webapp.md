###############################

Change *hwcping.com.br* to your onw domain name or deploy it to the default.

Ref.: https://docs.nginx.com/nginx/deployment-guides/setting-up-nginx-demo-environment/

###############################

Install stress to simulate some load to the webserver

1. apt install stress -y

Install & Configuring Nginx:

1. apt install nginx -y
2. mkdir -p /var/www/hwcping.com.br/html
3. chown -R $USER:$USER /var/www/hwcping.com.br/html
4. chmod -R 755 /var/www/hwcping.com.br
5. deploy as-demo directory content to /var/www/hwcping.com.br/html/
6. configure nginx app server: nano /etc/nginx/sites-available/hwcping.com.br
````
server {
    listen 80 ;
    server_name app_server www.hwcping.com.br hwcping.com.br;
    
    root /var/www/hwcping.com.br/html;
    error_log /var/log/nginx/app-server-error.log notice;
    index demo-index.html index.html;
    expires -1;

    sub_filter_once off;
    sub_filter 'server_hostname' '$hostname';
    sub_filter 'server_address'  '$server_addr:$server_port';
    sub_filter 'server_url'      '$request_uri';
    sub_filter 'remote_addr'     '$remote_addr:$remote_port';
    sub_filter 'server_date'     '$time_local';
    sub_filter 'client_browser'  '$http_user_agent';
    sub_filter 'request_id'      '$request_id';
    sub_filter 'nginx_version'   '$nginx_version';
    sub_filter 'document_root'   '$document_root';
    sub_filter 'proxied_for_ip'  '$http_x_forwarded_for';

    location / {
                try_files $uri $uri/ =404;
        }
}
````
7. ln -s /etc/nginx/sites-available/hwcping.com.br /etc/nginx/sites-enabled/
8. configure nginx server: nano /etc/nginx/nginx.conf
````
...
http {
    ...
    server_names_hash_bucket_size 64;
    ...
}
...
````
9. nginx -t
10. systemctl enable nginx && systemctl restart nginx