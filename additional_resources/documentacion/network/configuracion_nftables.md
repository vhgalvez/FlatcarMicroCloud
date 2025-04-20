✅ Instalar libvirt-nft-ruler en 1, 2, 3
1️⃣ Clonar y copiar archivos necesarios
bash
Copiar
Editar
# Clonar el repositorio
git clone https://github.com/clemensschlipfinger/libvirt-nft-ruler.git

# Crear carpeta de hooks de red si no existe
sudo mkdir -p /etc/libvirt/hooks/network.d/

# Copiar el script principal
sudo cp libvirt-nft-ruler/libvirt-nft-ruler /etc/libvirt/hooks/network.d/
sudo chmod +x /etc/libvirt/hooks/network.d/libvirt-nft-ruler

# Copiar las plantillas de reglas nftables
sudo mkdir -p /etc/libvirt-nft-ruler/
sudo cp -r libvirt-nft-ruler/templates /etc/libvirt-nft-ruler/
2️⃣ Cambiar libvirt a usar nftables
Busca y reemplaza firewall_backend = "none" por "nftables" en todos los .conf:

bash
Copiar
Editar
sudo find /etc/libvirt -type f -name "*.conf" -exec sed -i 's/firewall_backend = "none"/firewall_backend = "nftables"/g' {} \;
Verifica el resultado:

bash
Copiar
Editar
sudo grep -Ri firewall_backend /etc/libvirt/
3️⃣ Reiniciar servicios de libvirt
bash
Copiar
Editar
sudo systemctl restart virtqemud.service virtnetworkd.service virtproxyd.service virtstoraged.service
🧪 ¿Cómo usarlo?
Crea una red virtual con nombre como:

Copiar
Editar
redprivada-nft-ruler-nat
Eso usará la plantilla nat.json.

Cuando arranques esa red con virsh:

bash
Copiar
Editar
virsh net-start redprivada-nft-ruler-nat
🔁 Se aplicarán automáticamente las reglas nftables.

Cuando detengas la red:

bash
Copiar
Editar
virsh net-destroy redprivada-nft-ruler-nat
🧹 Se eliminarán automáticamente las reglas.

✅ Verificar que todo funciona
bash
Copiar
Editar
sudo nft list ruleset | less
Deberías ver reglas como LIBVIRT_INP, LIBVIRT_FWX, etc., aplicadas por el hook.




  #bridge    = "virbr_kube03"
  #domain    = "kube.internal"