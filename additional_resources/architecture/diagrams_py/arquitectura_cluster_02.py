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

with Diagram(name="Detailed Clúster OpenShift Architecture", show=False):        
    with Cluster("Data Center Infrastructure"):        
        with Cluster("Physical Server: ProLiant DL380 (Rocky Linux)"):

            with Cluster("OpenShift Nodes"):
                bootstrap = Server("Bootstrap Node")
                masters = [Server(f"Master Node {i+1}") for i in range(3)]
                workers = [Server(f"Worker Node {i+1}") for i in range(3)]
                
                bootstrap >> masters
                for master in masters:
                    master >> workers

            with Cluster("Network Services"):
                vpn = User("VPN (Bastion1) - Public IP via Fiber Optic")
                ovs = RedHat("Open vSwitch")
                vpn >> ovs
                ovs >> bootstrap

            with Cluster("Monitoring"):
                prometheus = Prometheus("Prometheus")
                grafana = Grafana("Grafana")
                prometheus >> grafana

            with Cluster("Additional Services"):
                freeipa = RedHat("FreeIPA")
                load_balancer = Traefik("Load Balancer")
                nfs = Server("NFS Server")
                db = PostgreSQL("PostgreSQL Database")
                elasticsearch = Elasticsearch("Elasticsearch")
                kibana_instance = Kibana("Kibana")
                dns = Bind9("DNS Server")

                freeipa >> load_balancer
                nfs >> load_balancer
                db >> load_balancer
                elasticsearch >> kibana_instance
                load_balancer >> [elasticsearch, kibana_instance, dns]

            redis = Redis("Redis (Session HA)")
            # Correctly connect Redis to each master and worker node individually
            for master in masters:
                redis >> master
            for worker in workers:
                redis >> worker

            # Connections
            vpn >> [master for master in masters]
            vpn >> [worker for worker in workers]
            load_balancer >> [master for master in masters]
            load_balancer >> [worker for worker in workers]
            prometheus >> workers
            grafana >> kibana_instance
