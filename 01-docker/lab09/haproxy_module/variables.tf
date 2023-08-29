variable "name_app" {
  type        = string
  default     = "terraform_app"
  description = "Nome da imagem da aplicação Docker"
}

variable "name_app_image_tag" {
  type        = string
  default     = "app:1.0"
  description = "Nome da imagem da aplicação Docker"
}

variable "name_app_network" {
  type        = string
  default     = "terraform_network_app"
  description = "Nome da network da aplicação Docker"
}

variable "name_app_volume" {
  type        = string
  default     = "name_app_volume"
  description = "Nome do volume da aplicação Docker"
}

variable "directory_files" {
  type        = string
  default     = "."
  description = "Nome do diretório que contém a config do HAProxy e index dos microserviços"
}
