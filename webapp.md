# Install Webapp Demo
###############################
This web application has only the propouse to show Autoscaling features. It shows some information about the host server handles the request behind a LoadBalance (Layer 4 or 7)

For the propose of this demo I use a domain *hwcping.com.br*, but you can use your own or LB IP directly.

Nginx References:
Ref.: https://docs.nginx.com/nginx/deployment-guides/setting-up-nginx-demo-environment/
###############################

## Install stress to simulate some load to the webserver

1. apt install stress -y

## Install & Configuring Nginx:

1. apt install nginx -y
 Create a directory to your web application
2. mkdir -p /var/www/hwcping.com.br/html
 give right permission to run your application
3. chown -R $USER:$USER /var/www/hwcping.com.br/html
4. chmod -R 755 /var/www/hwcping.com.br
 from the as-demo directory move the content to the directory you created in the step. 2
5. deploy as-demo directory content to /var/www/hwcping.com.br/html/
 create a config file for your newly created web application. Remember in my case I chose hwcping.com.br
6. configure nginx app server: nano /etc/nginx/sites-available/hwcping.com.br
 copy&paste the content below to your file, make sure you do all your changes accordingly.
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
 create a symbolik link from your web application to the *sites-enabled*
7. ln -s /etc/nginx/sites-available/hwcping.com.br /etc/nginx/sites-enabled/
 run the command below to validate your Nginx modifications. If all went well, Done!
8. nginx -t
 run the command below to make nginx start the service at linux startup and restart the service.
9. systemctl enable nginx && systemctl restart nginx