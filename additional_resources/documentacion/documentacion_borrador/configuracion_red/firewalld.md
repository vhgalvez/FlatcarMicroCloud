1. Verificar firewalld
Si estás utilizando firewalld, puedes verificar su estado y listar las reglas configuradas de la siguiente manera:

Verificar el estado de firewalld:
bash
Copiar código
sudo systemctl status firewalld
Listar las reglas de firewalld:
bash
Copiar código
sudo firewall-cmd --list-all
Para obtener una lista más detallada de todas las zonas:

bash
Copiar código
sudo firewall-cmd --list-all-zones