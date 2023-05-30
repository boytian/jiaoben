#!/bin/bash
# 提示用户输入域名
echo "请输入您的域名："
read domain

certbot certonly --standalone -d $domain --agree-tos -n --email d1376537549@126.com

# 配置nginx
cat > /etc/nginx/sites-available/$domain.conf << EOF
server {
    listen 443 ssl;
        server_name $domain;

	    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
	    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;

		    location / {
		            root /var/www/html;
			            index index.html;
				        }
			}
EOF

# 启用配置文件
ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/

# 重启nginx
systemctl restart nginx

# 打印配置文件的存放地址
echo "配置文件已保存在 /etc/nginx/sites-available/$domain.conf"
