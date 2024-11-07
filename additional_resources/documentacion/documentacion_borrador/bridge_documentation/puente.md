Para configurar el adaptador de bridge en el nodo "bastion1" y establecer la conectividad de red en el proyecto utilizando Terraform y libvirt, seguirás un conjunto de pasos que garantizarán que "bastion1" actúe como un puente entre tu red local y las máquinas virtuales internas. Aquí te dejo una guía detallada sobre cómo proceder:

## Paso 1: Configurar el Bridge en el Servidor Host
Antes de configurar Terraform, asegúrate de que tu sistema Linux (en este caso, un servidor que ejecuta Rocky Linux) tenga configurado y habilitado correctamente Open vSwitch o cualquier otro software de bridge. Asumiendo que usas Open vSwitch, los comandos básicos serían:

```bash
sudo ovs-vsctl add-br br0
sudo ip link set dev br0 up
```

Estos comandos crean un bridge llamado br0 y lo activan.

## Paso 2: Asignar IP al Bridge (Opcional)
Si necesitas que el bridge br0 tenga una dirección IP en tu red local (para facilitar el acceso directo, por ejemplo), puedes asignarle una dirección IP estática. Sin embargo, esto puede ser gestionado externamente a Terraform si es necesario para no complicar los scripts de Terraform:

```bash
sudo ip addr add 192.168.0.27/24 dev br0
```



sudo ovs-vsctl del-br br0

sudo systemctl stop openvswitch

sudo systemctl disable openvswitch


sudo systemctl restart network
sudo systemctl restart NetworkManager
sudo systemctl restart NetworkManager



resource "null_resource" "ovs_setup" {
  # Asigna comandos para configurar el bridge con Open vSwitch
  provisioner "local-exec" {
    command = <<-EOF
      sudo ovs-vsctl --may-exist add-br br0
      sudo ip addr add 192.168.0.30/24 dev br0
      sudo ip link set br0 up
    EOF
  }
}


# Crear un puente llamado br0
sudo ip link add name br0 type bridge

# Conectar interfaces al puente
sudo ip link set enp3s0f1 master br0

# Asignar dirección IP al puente (si es necesario)
sudo ip addr add 192.168.0.24/24 dev br0

# Activar el puente y las interfaces
sudo ip link set br0 up
sudo ip link set enp3s0f1 up

# Verificar la configuración
sudo ovs-vsctl show



ovs-vsctl list-ports br0


sudo virsh net-autostart kube_network_01

sudo virsh net-info kube_network_01


sudo yum install bridge-utils net-tools      # CentOS/RHEL




sudo dnf install bridge-utils net-tools      # Fedora/Rocky Linux

To use `lshw -class network`, you need to ensure `lshw` is installed. If it's not, you can install it with the following command:

```sh
sudo dnf install lshw -y
```
After installing lshw, you can execute the following command:

sudo lshw -class network