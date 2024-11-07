

# Test Maquinas Virtuales

```bash
ping -c 1 192.168.0.20
ping -c 1 10.17.4.20
ping -c 1 10.17.3.11
ping -c 1 10.17.4.1
ping -c 1 10.17.3.1
ping -c 1 10.17.3.0
ping -c 1 10.17.4.0
ping -c 1 8.8.8.8
ip addr
sudo ip route
hostnamectl
```



ping -c 4 192.168.0.20
ping -c 4 10.17.4.20
ping -c 4 10.17.3.11
ping -c 4 10.17.4.1
ping -c 4 10.17.3.1
ping -c 4 10.17.3.0
ping -c 4 10.17.4.0
ping -c 4 8.8.8.8
ip addr
sudo ip route
hostnamectl



ping -c 1 192.168.0.20
ping -c 1 10.17.4.20
ping -c 1 10.17.3.11
ping -c 1 10.17.4.1
ping -c 1 10.17.3.1
ping -c 1 10.17.3.0
ping -c 1 10.17.4.0
ping -c 1 8.8.8.8
ip addr
sudo ip route
hostnamectl


ping -c 2 192.168.0.20
ping -c 2 10.17.4.20
ping -c 2 10.17.3.11
ping -c 2 10.17.4.1
ping -c 2 10.17.3.1
ping -c 2 8.8.8.8
ip addr
sudo ip route
hostnamectl




ping -c 4 192.168.0.20
ping -c 4 10.17.4.20
ping -c 4 10.17.3.11
ping -c 4 10.17.4.1
ping -c 4 10.17.3.1
ping -c 4 8.8.8.8
ip addr
sudo ip route
hostnamectl
ip addr
sudo ip route
hostnamectl



cat /etc/iptables/rules.v4
ip addr
sudo ip route
hostnamectl
sudo firewall-cmd --list-all-zones

sudo iptables-save | sudo tee /etc/iptables/rules.v4

sudo systemctl disable iptables-restore.service




sudo systemctl daemon-reload
sudo systemctl enable iptables-restore.service
sudo systemctl start iptables-restore.service
sudo systemctl restart iptables-restore.service
sudo systemctl status iptables-restore.service