terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

locals {
  directory_files = "${path.cwd}"
}

locals {
  name_app = "apezinho"
}

resource "docker_network" "private_network" {
  name = var.name_app_network
}

resource "docker_volume" "shared_volume" {
  name = var.name_app_volume
}

resource "docker_image" "app01_image" {
  build {
    path = "./haproxy_module"
    tag  = [var.name_app_image_tag]
  }

  name = var.name_app_image_tag
}

resource "docker_image" "haproxy_image" {
  name = "haproxy:latest"
}

resource "docker_container" "app01_container" {
  count = 2
  image = docker_image.app01_image.latest
  name  = "${local.name_app}_${count.index}"

  networks = ["${docker_network.private_network.name}"]
  volumes {
    container_path = "/var/www/html/"
    read_only      = false
    host_path      = "${local.directory_files}"
  }

}

resource "docker_container" "terraform_haproxy" {
  image = docker_image.haproxy_image.latest
  name  = "${local.name_app}_haproxy"

  networks = ["${docker_network.private_network.name}"]

  ports {
    internal = 80
    external = 80
  }

  volumes {
    container_path = "/usr/local/etc/haproxy/haproxy.cfg"
    read_only      = true
    host_path      = "${local.directory_files}/haproxy_module/haproxy.cfg"
  }
}
