#!/bin/bash

set -e

# 1. 设置root用户密码
read -rsp "请设置root密码：" rootpass
echo -e "\n您的root密码已设置。"

# 2. 确认root密码
read -rsp "请再次输入root密码：" confirmpass
echo

echo "$confirmpass"

# 检查密码是否匹配
if [[ "$rootpass" != "$confirmpass" ]]; then
  echo "密码不匹配，请重新运行脚本设置密码。"
  exit 1
fi

echo "root:$rootpass" | chpasswd



# 2. 修改 /etc/ssh/sshd_config，允许root用户通过ssh登录
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# 3. 重启sshd服务
systemctl restart sshd

