#!/bin/bash

# 检测是否已安装 Docker
if command -v docker &> /dev/null; then
    echo "Docker 已经安装，跳过安装步骤。"
else
    # 安装 Docker
    echo "正在安装 Docker..."
    sudo apt update
    sudo apt install -y docker.io

    # 启动 Docker 服务
    sudo systemctl start docker

    # 将当前用户添加到 docker 组，以便无需 sudo 来运行 docker 命令
    sudo usermod -aG docker $USER

    # 设置 Docker 服务开机自动启动
    sudo systemctl enable docker

    echo "Docker 安装完成。"
fi

# 检测是否已安装 Docker Compose
if command -v docker-compose &> /dev/null; then
    echo "Docker Compose 已经安装，跳过安装步骤。"
else
    # 安装 Docker Compose
    echo "正在安装 Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # 设置 Docker Compose 服务开机自动启动（通过用户服务）
    mkdir -p ~/.config/systemd/user
    curl -L "https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose" -o ~/.config/systemd/user/docker-compose.service
    systemctl --user enable --now docker-compose.service

    echo "Docker Compose 安装完成。"
fi

# 设置别名 dc
if grep -q "alias dc='docker-compose'" ~/.bashrc || grep -q "alias dc='docker-compose'" ~/.zshrc; then
    echo "别名 'dc' 已经设置，跳过设置步骤。"
else
    echo "alias dc='docker-compose'" >> ~/.bashrc   # 或者使用 ~/.zshrc，根据你的终端配置
    source ~/.bashrc   # 或者使用 source ~/.zshrc，根据你的终端配置
    echo "别名 'dc' 设置完成。"
fi

# 显示安装信息
echo "Docker 和 Docker Compose 安装完成。请重新登录或执行 'newgrp docker' 以应用组更改。"

# 显示 Docker 和 Docker Compose 版本信息
docker --version
docker-compose --version
