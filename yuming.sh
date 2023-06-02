#!/bin/bash

# 检查是否安装了nginx和certbot，如果没有则安装
if ! command -v nginx &> /dev/null
then
    echo "nginx 未安装，正在安装..."
    apt-get update
    apt-get install nginx -y
fi

if ! command -v certbot &> /dev/null
then
    echo "certbot 未安装，正在安装..."
    apt-get update
    apt-get install certbot -y
fi

# 检查 python-certbot-nginx 是否已经安装
if ! dpkg -l python3-certbot-nginx &> /dev/null
then
    # 如果没有安装，则执行安装命令
    echo "python3-certbot-nginx 未安装，正在安装..."
    sudo apt-get update
    sudo apt-get install python3-certbot-nginx
fi

# 提示用户输入域名
while true; do
    echo "请输入您的域名："
    read domain
    if [[ "$domain" =~ ^[a-zA-Z0-9]+([-.][a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$ ]]; then
        break
    else
        echo "无效的域名，请重新输入。"
    fi
done

# 提示用户输入是否需要反向代理
while true; do
    echo "是否需要反向代理？(y/n)"
    read need_proxy
    if [[ "$need_proxy" =~ ^[ynYN]$ ]]; then
        break
    else
        echo "无效的输入，请重新输入。"
    fi
done

if [ ! -f /etc/letsencrypt/live/$domain/fullchain.pem ]; then
     sudo certbot --nginx -d $domain --email d1376537549@126.com --agree-tos --non-interactive
fi



# 配置nginx
if [ "$need_proxy" = "y" ] || [ "$need_proxy" = "Y" ]; then
    # 提示用户输入反向代理的端口
    while true; do
        echo "请输入反向代理的端口号："
        read proxy_port
        if [[ "$proxy_port" =~ ^[1-9][0-9]*$ ]]; then
            break
        else
            echo "无效的端口号，请重新输入。"
        fi
    done
    # 配置nginx
    cat > /etc/nginx/sites-available/$domain.conf << EOF
server {
    listen 443 ssl;
    server_name $domain;
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    location / {
        proxy_pass http://127.0.0.1:$proxy_port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
else
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
fi

# 启用配置文件
if [ ! -L /etc/nginx/sites-enabled/$domain.conf ]; then
    ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/
fi

# 检查nginx是否正在运行
if sudo systemctl is-active --quiet nginx; then
    # 重启nginx
    sudo systemctl restart nginx
else
    # 启动nginx
    sudo systemctl start nginx
fi

# 检查nginx是否启动成功
if ! sudo systemctl is-active --quiet nginx; then
    echo "nginx 启动失败，请检查配置文件是否正确。"
    exit 1
fi

# 打印配置文件的存放地址
echo "配置文件已保存在 /etc/nginx/sites-available/$domain.conf"
