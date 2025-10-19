# 基础镜像
FROM ubuntu:24.04

# 设置非交互模式
ENV DEBIAN_FRONTEND=noninteractive

# 更新源为国内镜像
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.ustc.edu.cn/ubuntu/|g' /etc/apt/sources.list && \
    apt-get update && apt-get upgrade -y

# 安装基本工具和 XFCE + VNC + unzip
RUN apt-get install -y \
    sudo \
    wget \
    curl \
    unzip \
    xfce4 xfce4-goodies \
    dbus-x11 \
    xfce4-terminal \
    x11vnc \
    xvfb \
    novnc \
    net-tools \
    python3 \
    python3-pip \
    supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 创建普通用户 ubuntu 并加入 sudo
RUN id -u ubuntu &>/dev/null || useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    usermod -aG sudo ubuntu

# 设置工作目录
WORKDIR /home/ubuntu

# 复制 noVNC 和 websockify 压缩包
COPY noVNC.zip .
COPY websockify.zip .

# 解压并整理目录
RUN unzip noVNC.zip -d /opt && \
    unzip websockify.zip -d /opt && \
    rm noVNC.zip websockify.zip && \
    mv /opt/noVNC-1.6.0 /opt/novnc && \
    mkdir -p /opt/novnc/utils && \
    mv /opt/websockify-0.13.0 /opt/novnc/utils/websockify

# 暴露 VNC 和 noVNC 端口
EXPOSE 5900 6080

# 拷贝启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 设置默认用户
USER ubuntu

# 启动容器时运行 start.sh
CMD ["/start.sh"]

