#!/bin/bash
#====================开启root登录================================

# 1. 设置root用户密码
read -p "请设置root密码 ：" rootpass
echo "您的root密码是：$rootpass"
read -p "请确认您输入的root密码 [y/n]：" confirm

# 确认用户输入是否正确
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "您输入的不是'y'，脚本将退出。"
  exit 1
fi

echo "root:$rootpass" | chpasswd

# 提示用户输入 NodeID 的值
read -p "请输入 NodeID 的值：" node_id
# 监控密钥
read -p "请输入监控密钥：" cmd


# 2. 修改 /etc/ssh/sshd_config，允许root用户通过ssh登录
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# 3. 重启sshd服务
systemctl restart sshd

#=========================开启BBR加速内核============================
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf

# 重新加载sysctl.conf配置文件
sudo sysctl -p

#=========================XrayR============================

# 下载并运行 XrayR 的安装脚本
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

#修改配置信息
sed -i 's/ApiHost: "http:\/\/127.0.0.1:667"/ApiHost: "https:\/\/vip.boytian.wiki"/g' /etc/XrayR/config.yml
sed -i 's/ApiKey: "123"/ApiKey: "SDFWEFWSGDSDFWFWFW"/g' /etc/XrayR/config.yml
sed -i 's|# /etc/XrayR/route.json| /etc/XrayR/route.json|g'  /etc/XrayR/config.yml
sed -i 's|# /etc/XrayR/custom_inbound.json| /etc/XrayR/custom_inbound.json|g' /etc/XrayR/config.yml
sed -i 's|# /etc/XrayR/custom_outbound.json| /etc/XrayR/custom_outbound.json|g' /etc/XrayR/config.yml
sed -i "s|NodeID:.*|NodeID: $node_id|" /etc/XrayR/config.yml


#支持chatgpt代理设置

echo '{
           "domainStrategy": "IPOnDemand",
           "rules": [
                {
                     "domain": [
                          "chat.openai.com",
                          "openai.com",
                          "platform.openai.com"
                     ],
                     "outboundTag": "netflix_proxy",
                     "type": "field"
                },
                {
                     "inboundTag": [
                          "api"
                     ],
                     "outboundTag": "api",
                     "type": "field"
                },
                {
                     "ip": [
                          "geoip:private"
                     ],
                     "outboundTag": "blocked",
                     "type": "field"
                },
                {
                     "outboundTag": "blocked",
                     "protocol": [
                          "bittorrent"
                     ],
                     "type": "field"
                }
           ]
      }' > /etc/XrayR/route.json
echo '[
        {
                              "listen": "0.0.0.0",
                              "port": 80,
                              "protocol": "socks",
                              "sniffing": {
                                      "enabled": true,
                                      "destOverride": ["http", "tls"]
                              }
                      }
      ]' > /etc/XrayR/custom_inbound.json
echo '[
           {
                "protocol": "freedom",
                "settings": {},
                "tag": "IPv4_out"
           },
           {
                "protocol": "freedom",
                "settings": {
                     "domainStrategy": "UseIPv6"
                },
                "tag": "IPv6_out"
           },
           {
                "protocol": "socks",
                "settings": {
                     "servers": [
                          {
                               "address": "127.0.0.1",
                               "port": 1080
                          }
                     ]
                },
                "tag": "socks5-warp"
           },
           {
                "protocol": "blackhole",
                "tag": "block"
           },
           {
                "mux": {
                     "concurrency": -1,
                     "enabled": false
                },
                "protocol": "vmess",
                "settings": {
                     "vnext": [
                          {
                               "address": "20.210.57.171",
                               "port": 80,
                               "users": [
                                    {
                                         "alterId": 0,
                                         "email": "t@t.tt",
                                         "id": "b09c7355-bbe1-4177-883b-6704bc1d285f",
                                         "security": "none"
                                    }
                               ]
                          }
                     ]
                },
                "streamSettings": {
                     "network": "ws",
                     "wsSettings": {
                          "path": ""
                     }
                },
                "tag": "netflix_proxy"
           }
      ]' > /etc/XrayR/custom_outbound.json

#重启XrayR
sudo XrayR restart


#================================安装监控==========================================
curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh install_agent nz.boytian.com 5555 $cmd
