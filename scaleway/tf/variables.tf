variable "SHATHEL_ENV_SCALEWAY_TOKEN" {
}
variable "SHATHEL_ENV_CF_EMAIL" {
}
variable "SHATHEL_ENV_CF_TOKEN" {
}
variable "SHATHEL_ENV_DOMAIN" {
}
variable "SHATHEL_ENV_CF_DOMAIN" {
}
variable "SHATHEL_ENV_CF_DOMAINS" {
  default = ""
}
variable "SHATHEL_ENV_SOLUTION_NAME" {
}
variable "SHATHEL_ENVPACKAGE_KEY_DIR" {
}
variable SHATHEL_ENV_MANAGERS {
}
variable SHATHEL_ENV_WORKERS {
}
variable SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY {
}
variable "SHATHEL_ENVPACKAGE_IMAGE_NAME" {
  default = "Ubuntu Xenial"
}
variable "SHATHEL_ENV_SCALEWAY_REGION" {
  default = "par1"
}
variable "SHATHEL_ENV_SCALEWAY_ORGANISATION" { // ACCESS token
}
variable "SHATHEL_ENV_SCALEWAY_SIZE" {
  default = "START1-S"
}

variable "SHATHEL_SOLUTION_DOCKER_PACKAGE" {
  default = "5:18.09.1~3-0~ubuntu-xenial"
}

variable "SHATHEL_ENVPACKAGE_USER" {
  default = "root"
}

variable "SHATHEL_ENVPACKAGE_VOLUME_SIZE" {
  default = "0"
}

variable "SHATHEL_ENVPACKAGE_VOLUME_TYPE" {
  default = "l_ssd"
}

variable "SHATHEL_ENV_SCALEWAY_PRIVATE_KEY" { // this is a key added mannualy on https://cloud.scaleway.com/#/credentials
}