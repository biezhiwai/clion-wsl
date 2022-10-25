# 内核允许超量使用内存直到用完为止
sudo echo "%sudo ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
sudo echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl vm.overcommit_memory=1

# 配置大内存页面
sudo cat << 'EOF' >> ~/.bashrc
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
sudo echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
fi
EOF

# 关闭内存交换空间
swapoff -a

# 安装redis 7.0.5
cd ~
mkdir redis && cd redis
mkdir bin conf data run log tls

wget http://download.redis.io/releases/redis-7.0.5.tar.gz
tar -xzvf redis-7.0.5.tar.gz
cd redis-7.0.5
make -j 2
make install PREFIX=~/redis
cp redis-7.0.5/redis.conf redis/conf/
# 然后修改redis.conf完成配置
