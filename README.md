Experimentos práticos para aprender o "Feijão com Arroz" de Terraform:

Feijão com o Arroz #1:
 - Subir 1 container Docker
 - e destruí-lo

Feijão com o Arroz #2:
 - Subir 2 containers Docker iguais e um terceiro de outro tipo

Feijão com o Arroz #3:
 - Subir 2 containers Docker iguais usando count e um terceiro de outro tipo

Feijão com o Arroz #4:
 - Criar uma network
 - Subir dois containers na mesma network

Feijão com o Arroz #5:
 - Criar uma network
 - Subir dois containers na mesma network
 - Criar um volume
 - Vincular o volume aos dois containers

Feijão com o Arroz #6:
 - Criar uma network
 - Subir dois containers na mesma network
 - Subir um terceiro container com o HAProxy mapeando a configuração do diretório local

Feijão com o Arroz #7:
 - Organizar o projeto separando variáveis e resources

Feijão com o Arroz #8:
 - Empacotar todo o projeto anterior na forma de módulo

Feijão com o Arroz #9:
 - Configurar backend para armazenamento do estado no S3

Feijão com o Arroz #10:
 - Criar imagem qcow2 do Debian
 - Subir VM domain baseado em imagem .qcow2 do Debian com o Libvirt
 - Acessar o SSH

Feijão com o Arroz #11:
 - Criar imagem qcow2 do Debian com o cloudinit instalado
 - Subir VM domain baseado em imagem .qcow2 do Debian com o Libvirt
   e com configurações de cloudinit para acesso SSH por chave pública

Feijão com o Arroz #12:
 - Subir duas VMs: uma Debian e outra Ubuntu na network default

Feijão com o Arroz #13:
 - Criar uma network
 - e destruí-la

Feijão com o Arroz #14:
 - Criar uma network
 - Vincular Domain Debian e Ubuntu nesta network
 - Subir terceira VM com FreeBSD pertecendo a network
   default e network privada

Feijão com o Arroz #15:
 - Subir uma VM e executar um comando através de um provisioner

Feijão com o Arroz #16:
 - Usar o provisioner para configurar o HAProxy no FreeBSD
   e configurar um Apache nas duas VMs

Feijão com o Arroz #17:
 - Configurar backend para armazenamento do estado no S3

Feijão com o Arroz #18:
 - Subir uma instância EC2 na AWS
 - Definir nome "terraform_ec2_instance"

Feijão com o Arroz #19:
 - Criar uma VPC com todos os elementos necessários:
   * VPC
   * Subnet pública
   * Subnet privada
   * Internet Gateway
   * Route Table com rota default para o IG associado a subnet pública
   * Route Table somente com a rota local associada a subnet privada
   * Criar security group liberando porta 22
 - Definir nome "terraform_vpc"

Feijão com o Arroz #20:
 - Reaproveitando o mesmo código anterior como módulo
 - Subir duas instâncias EC2, cada uma em uma subnet diferente

Feijão com o Arroz #21:
 - Reaproveitando o mesmo código anterior
 - Subir duas instâncias EC2, cada uma em uma subnet diferente
 - Colocar um ALB na frente

Feijão com o Arroz #22:
 - Reaproveitando o mesmo código anterior
 - Subir duas instâncias EC2, cada uma em uma subnet diferente
 - Colocar um ALB na frente
 - Configurar zona Route53
 - Configurar ACM (com certificado SSL correto)

Feijão com o Arroz #23:
 - Configurar backend para armazenamento do estado no S3

Feijão com o Arroz #24:
 - Configurar cluster EKS

Feijão com o Arroz #25:
 - Organizar código segundo boas práticas (como estrutura de átomos e moléculas)

Feijão com o Arroz #24:
 - Versionar código da infra AWS em repositório privado no GitHub

Feijão com o Arroz #25:
 - Configurar pipeline para deploy de infra AWS no CircleCI

Feijão com o Arroz #26:
 - Versionar código da infra AWS em repositório privado no Gitlab

Feijão com o Arroz #27:
 - Configurar pipeline para deploy de infra AWS no CI/CD do Gitlab










## Anotações

Links:
* https://github.com/dmacvicar/terraform-provider-libvirt
* https://github.com/dmacvicar/terraform-provider-libvirt/blob/main/examples/v0.13/ubuntu/ubuntu-example.tf
* https://sumit-ghosh.com/articles/create-vm-using-libvirt-cloud-images-cloud-init/
* https://docs.openstack.org/image-guide/ubuntu-image.html
* https://blog.ruanbekker.com/blog/2020/10/08/using-the-libvirt-provisioner-with-terraform-for-kvm/

```bash
sudo wget -O /var/lib/libvirt/boot/debian-mini.iso \
  https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.3.0-amd64-netinst.iso

sudo chown libvirt-qemu:kvm /var/lib/libvirt/boot/debian-mini.iso

sudo qemu-img create -f qcow2 /var/lib/libvirt/images/debian.qcow2 10G

sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/debian.qcow2

virt-install --virt-type kvm --name debian --ram 1024 \
  --cdrom=/var/lib/libvirt/boot/debian-mini.iso \
  --disk /var/lib/libvirt/images/debian-cloudinit.qcow2,bus=virtio,size=10,format=qcow2 \
  --network network=default \
  --graphics vnc,listen=0.0.0.0 --noautoconsole \
  --os-type=linux --os-variant=debian9

virt-install --name=debian-cloudinit \
--vcpus=1 \
--memory=1024 \
--network bridge=virbr0,model=virtio \
--disk /var/lib/libvirt/images/debian-cloudinit.qcow2,bus=virtio,size=10,format=qcow2 \
--import \
--os-variant=debian9

virt-install \
--name=debian-cloudinit \
--ram=2048 \
--vcpus=1 \
--import \
--disk path=/var/lib/libvirt/images/debian-cloudinit.qcow2,format=qcow2 \
--disk path=/tmp/cloudinit/cidata.iso,device=cdrom \
--os-variant=ubuntu20.04 \
--network bridge=virbr0,model=virtio \
--graphics vnc,listen=0.0.0.0 \
--noautoconsole

virsh net-list
virsh net-dhcp-leases default
```