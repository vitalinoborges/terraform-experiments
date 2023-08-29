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

# Create a container
resource "docker_container" "app01_container" {
  image = docker_image.app01_image.latest
  name  = "app01"

  ports {
    internal = 8000
    external = 8000
  }
}

