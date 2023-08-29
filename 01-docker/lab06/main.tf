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

resource "docker_network" "private_network" {
  name = "terraform_network_app01"
}

resource "docker_volume" "shared_volume" {
  name = "shared_volume"
}

# Pulls the image
resource "docker_image" "app01_image" {
  build {
    path = "."
    tag  = ["app:1.0"]
  }

  name = "app:1.0"
}

resource "docker_image" "haproxy_image" {
  name = "haproxy:latest"
}

# Create a container
resource "docker_container" "app01_container" {
  count = 2
  image = docker_image.app01_image.latest
  name  = "terraform_app01_${count.index}"

  networks = ["${docker_network.private_network.name}"]
  volumes {
    container_path = "/var/www/html/"
    read_only      = false
    host_path      = path.cwd
  }

}

resource "docker_container" "terraform_haproxy" {
  image = docker_image.haproxy_image.latest
  name  = "terraform_haproxy"

  networks = ["${docker_network.private_network.name}"]

  ports {
    internal = 80
    external = 80
  }

  volumes {
    container_path = "/usr/local/etc/haproxy/haproxy.cfg"
    read_only      = true
    host_path      = "${path.cwd}/haproxy.cfg"
  }
}
