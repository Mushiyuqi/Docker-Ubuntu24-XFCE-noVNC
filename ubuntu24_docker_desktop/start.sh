#!/bin/bash
set -e

# -----------------------------
# 修复 /tmp 权限
# -----------------------------
sudo mkdir -p /tmp/.X11-unix /tmp/.ICE-unix
sudo chown root:root /tmp/.X11-unix /tmp/.ICE-unix
sudo chmod 1777 /tmp/.X11-unix /tmp/.ICE-unix

# -----------------------------
# 清理残留的锁文件
# -----------------------------
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# -----------------------------
# 设置显示环境
# -----------------------------
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime-$USER
mkdir -p $XDG_RUNTIME_DIR
export DBUS_SESSION_BUS_ADDRESS=""

# -----------------------------
# 启动虚拟显示（1280x720, 24位色）
# -----------------------------
Xvfb $DISPLAY -screen 0 1280x720x24 &

# 等待 Xvfb 启动
sleep 3

# -----------------------------
# 启动 XFCE 桌面环境
# -----------------------------
dbus-launch xfce4-session &

# 等 XFCE 完全启动
sleep 5

# -----------------------------
# 自动选择空闲 VNC 端口
# -----------------------------
VNC_PORT=5901
while netstat -tln | grep -q $VNC_PORT; do
    VNC_PORT=$((VNC_PORT+1))
done
echo "Using VNC port: $VNC_PORT"

# -----------------------------
# 启动 x11vnc server
# -----------------------------
x11vnc -display $DISPLAY -rfbport $VNC_PORT -nopw -forever -shared -noxdamage &

# -----------------------------
# 启动 noVNC WebSocket 代理
# -----------------------------
NOVNC_PORT=6080
/opt/novnc/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NOVNC_PORT

echo "VNC desktop is running on port $VNC_PORT"
echo "noVNC web interface: http://$(hostname -I | awk '{print $1}'):$NOVNC_PORT/vnc.html?host=$(hostname -I | awk '{print $1}')&port=$NOVNC_PORT"

