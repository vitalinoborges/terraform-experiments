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
  name      = "cloudinit.iso"
  user_data = data.template_file.user_data.rendered
  meta_data = data.template_file.meta_data.rendered
}

resource "libvirt_domain" "domain-debian" {
  name   = "debian-terraform"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
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

}