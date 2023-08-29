terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "private_network" {
  name      = "private"
  mode      = "none"
  domain    = "private.local"
  addresses = ["192.168.200.0/24"]
}

resource "libvirt_volume" "debian" {
  name   = "debian.qcow2"
  pool   = "default"
  source = "/var/lib/libvirt/images/debian-cloudinit.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloudinit/user-data")
}

data "template_file" "meta_data" {
  template = file("${path.module}/cloudinit/meta-data")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "cloudinit_2.iso"
  user_data = data.template_file.user_data.rendered
  meta_data = data.template_file.meta_data.rendered
}

resource "libvirt_domain" "domain-debian" {
  name   = "debian-terraform"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "private"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.debian.id
  }


  provisioner "remote-exec" {
    inline = [
      "echo 'Hello World'"
    ]

    connection {
      type        = "ssh"
      user        = "terraform"
      host        = libvirt_domain.domain-debian.network_interface[0].addresses[0]
      private_key = file(var.ssh_private_key)
      #bastion_host        = "ams-kvm-remote-host"
      #bastion_user        = "deploys"
      #bastion_private_key = file("~/.ssh/id_rsa")
      timeout = "2m"
    }
  }

}
