
netstat -rn


route add -net 10.17.3.0/24 192.168.0.101
route add -net 10.17.4.0/24 192.168.0.101



iptables -t nat -A POSTROUTING -s 10.17.3.0/24 -o enp4s0f0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.17.4.0/24 -o enp4s0f0 -j MASQUERADE
