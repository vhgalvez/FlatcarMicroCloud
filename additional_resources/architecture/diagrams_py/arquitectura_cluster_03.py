from diagrams import Cluster, Diagram
from diagrams.onprem.compute import Server
from diagrams.onprem.client import User
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.monitoring import Grafana, Prometheus
from diagrams.generic.os import RedHat
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.network import Nginx
from diagrams.onprem.queue import Kafka
from diagrams.elastic.elasticsearch import Elasticsearch, Kibana
from diagrams.onprem.network import Bind9, Traefik

with Diagram(name="Detailed Cluster Architecture", show=False):
    with Cluster("Core Infrastructure"):
        with Cluster("Server ProLiant DL380 (Rocky Linux 9.3)"):
            with Cluster("Virtualization Layer"):
                kvm = Server("KVM/QEMU")
                
                with Cluster("OpenShift Nodes"):
                    bootstrap = Server("Bootstrap Node")
                    masters = [Server(f"Master Node {i+1}") for i in range(3)]
                    workers = [Server(f"Worker Node {i+1}") for i in range(3)]
                    
                    bootstrap >> masters
                    for master in masters:
                        master >> workers

            with Cluster("Network Configuration"):
                vpn = User("VPN (WireGuard) - Public IP")
                ovs = RedHat("Open vSwitch")
                vpn >> ovs
                ovs >> bootstrap

            with Cluster("Monitoring Tools"):
                prometheus = Prometheus("Prometheus")
                grafana = Grafana("Grafana")
                prometheus >> grafana

            with Cluster("Service Applications"):
                freeipa = RedHat("FreeIPA")
                load_balancer = Traefik("Load Balancer (Traefik)")
                nfs = Server("NFS Server")
                db = PostgreSQL("PostgreSQL")
                elasticsearch = Elasticsearch("Elasticsearch")
                kibana_instance = Kibana("Kibana")
                dns = Bind9("DNS Server (BIND)")

                freeipa >> load_balancer
                nfs >> load_balancer
                db >> load_balancer
                elasticsearch >> kibana_instance
                load_balancer >> [elasticsearch, kibana_instance, dns]

            kafka = Kafka("Apache Kafka")
            nginx = Nginx("Nginx Web Server")
            fail2ban = RedHat("Fail2Ban")

            with Cluster("Security & Access"):
                firewall = Server("Firewall Configuration")
                vpn >> firewall
                for master in masters:
                    firewall >> master
                for worker in workers:
                    firewall >> worker

            redis = Redis("Redis Cache")
            for master in masters:
                redis >> master
            for worker in workers:
                redis >> worker

            # External Connections
            vpn >> [master for master in masters]
            vpn >> [worker for worker in workers]
            load_balancer >> [master for master in masters]
            load_balancer >> [worker for worker in workers]
            prometheus >> workers
            grafana >> kibana_instance