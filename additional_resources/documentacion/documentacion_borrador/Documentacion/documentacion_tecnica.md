


https://github.com/ragrahari/elkf-helm-openshift.git
https://vocore.io/

https://github.com/OpenDevin/OpenDevin

sudo chmod -R 755 /var/lib/libvirt/images/roky_linux_mininal_isos/Rocky-9.3-x86_64-minimal.iso


sudo setenforce 0
sudo setenforce 0  # Pone SELinux en modo permisivo


[victory@server cluster_openshift_kvm_terraform]$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
[victory@server cluster_openshift_kvm_terraform]$

sudo dnf install arp-scan


sudo virsh net-list --all
sudo virsh net-start default

sudo virsh net-autostart default



sudo virsh list --all
sudo virsh undefine Golden_Rocky_9_2-TF
sudo virsh destroy Golden_Rocky_9_2-TF



default

sudo virsh net-dhcp-leases default
 Expiry Time           dirección MAC       Protocol   IP address           Hostname       Client ID or DUID
----------------------------------------------------------------------------------------------------------------
 2024-05-10 16:19:17   52:54:00:66:1a:d0   ipv4       192.168.122.167/24   rockylinux92   01:52:54:00:66:1a:d0


 To list all volumes in the default pool:
bash
Copy code
virsh vol-list default
To delete an existing volume if it's no longer needed:
bash
Copy code
virsh vol-delete --pool default rocky9_cloudinit_disk.iso


sudo chmod +x mv_03_show_terraform_configs.sh



Listar los dominios existentes: Primero, asegúrate de que el dominio bastion1 está presente y verifica su estado.

bash
Copy code
sudo virsh list --all
Detener el dominio: Si el dominio está en ejecución, debes detenerlo antes de poder eliminarlo.

bash
Copy code
sudo virsh destroy bastion1
Eliminar el dominio: Una vez detenido, puedes eliminarlo completamente.

bash
Copy code
sudo virsh undefine bastion1
Este proceso libera el nombre bastion1, permitiéndote crear un nuevo dominio con ese nombre sin conflictos. Si también necesitas eliminar los recursos de almacenamiento asociados con ese dominio (como volúmenes de disco), puedes hacerlo con el siguiente comando:

Eliminar los volúmenes de disco (opcional): Si también deseas eliminar los discos asociados a este dominio, asegúrate de conocer la ubicación y el nombre de los discos antes de eliminarlos.
bash
Copy code
sudo virsh vol-delete --pool default nombre_del_disco



sudo virsh list --all

sudo systemctl enable openvswitch.service
sudo systemctl start openvswitch.service
sudo systemctl status openvswitch.service


sudo virsh list --all

sudo virsh net-list --all
sudo virsh net-dhcp-leases default