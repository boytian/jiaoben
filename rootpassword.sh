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
