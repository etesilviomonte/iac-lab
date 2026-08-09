terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "ubuntu" {
  name = "ubuntu:22.04"
}

resource "docker_container" "servidor" {
  name    = "ubuntu-server"
  image   = docker_image.ubuntu.image_id
  command = ["sleep", "infinity"]
    ports {
    internal = 3000
    external = 3000
  }
}