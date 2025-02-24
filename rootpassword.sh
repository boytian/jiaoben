#!/bin/bash

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用sudo运行此脚本！"
    exit 1
fi

# 备份SSH配置文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 配置允许root登录
sed -i -E 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
grep -q '^PermitRootLogin yes' /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# 重启SSH服务
systemctl restart ssh

# 设置root密码
while : 
do
    echo -n "请设置root密码: "
    read -s root_pass
    echo
    echo -n "请确认root密码: "
    read -s root_pass_confirm
    echo

    if [ "$root_pass" != "$root_pass_confirm" ]; then
        echo "密码不匹配，请重新输入！"
    elif [ -z "$root_pass" ]; then
        echo "密码不能为空！"
    else
        break
    fi
done

echo "root:$root_pass" | chpasswd

# 显示结果
echo "root账户已启用，密码设置成功！"
echo "警告：允许root远程登录存在安全风险，建议："
echo "1. 仅在内网环境使用此配置"
echo "2. 定期更换复杂密码"
echo "3. 建议使用SSH密钥认证代替密码登录"

# 3. 重启sshd服务
systemctl restart sshd

