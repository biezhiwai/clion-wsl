#!/bin/bash
set -e
SUDOERS_FILE=/etc/sudoers
SYSCTL_FILE=/etc/sysctl.conf
LIB_FILE=/etc/ld.so.conf
REDIS_VERSION=7.0.5

# 内核允许超量使用内存直到用完为止
sudo echo "%sudo ALL=(ALL) NOPASSWD:ALL" | sudo tee -a $SUDOERS_FILE
sudo echo "vm.overcommit_memory = 1" | sudo tee -a $SYSCTL_FILE
sudo sysctl vm.overcommit_memory=1

# 配置大内存页面
sudo cat << 'EOF' >> ~/.bashrc
sudo sysctl vm.overcommit_memory=1
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
sudo echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
fi
EOF

# 关闭内存交换空间
swapoff -a

# 安装redis
cd ~
mkdir redis && cd redis
mkdir bin conf data run log tls
cd ~
wget http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz
tar -xzvf redis-${REDIS_VERSION}.tar.gz
cd ~/redis-${REDIS_VERSION}
make -j 2
make install PREFIX=~/redis
cp ~/redis-${REDIS_VERSION}/redis.conf ~/redis/conf/
sudo cat << 'EOF' >> ~/.bashrc
export PATH="~/redis/bin:$PATH"
EOF

# 安装hiredis
cd ~
git clone https://github.com/redis/hiredis.git
cd ~/hireis
make
sudo make install
sudo echo "/usr/local/lib" | sudo tee -a $LIB_FILE
sudo ldconfig

# 安装redis++
cd ~
git clone https://github.com/sewenew/redis-plus-plus.git
cd redis-plus-plus
mkdir build && cd build
cmake ..
make
make install


# 然后修改redis.conf完成配置
# ----------------参考配置----------------
# bind 0.0.0.0 #主机 IP
# protected-mode no #保护模式设成 no
# port 6379 #Redis 端口
# pidfile "/home/cxk/redis/run/redis_6379.pid" #进程文件
# logfile "/home/cxk/redis/log/redis_6379.log" #日志文件
# daemonize yes #守护模式
# save 3600 1 #rdb 配置
# save 300 100
# save 60 10000
# dbfilename "dump_6379.rdb" #rdb 文件
# appendonly no #aof 配置
# appendfilename "appendonly_6379.aof" #aof 文件
# appenddirname "appendonlydir_6379" #aof 文件夹
# dir "/home/cxk/redis/data" #数据文件目录
# cluster-enabled no #非集群模式
# cluster-config-file nodes-6379.conf #集群配置文件
