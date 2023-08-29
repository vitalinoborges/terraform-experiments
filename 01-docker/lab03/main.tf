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

# Pulls the image
resource "docker_image" "app01_image" {
  build {
    path = "."
    tag  = ["app:1.0"]
  }

  name = "app:1.0"
}

resource "docker_image" "ubuntu_image" {
  name = "ubuntu:latest"
}

# Create a container
resource "docker_container" "app01_container" {
  count = 2
  image = docker_image.app01_image.latest
  name  = "terraform_app01_${count.index}"

  ports {
    internal = 8000
    external = "808${count.index}"
  }
}

resource "docker_container" "ubuntu_image" {
  image = docker_image.ubuntu_image.latest
  name  = "terraform_ubuntu"

  command = ["sleep", "1000"]

}
