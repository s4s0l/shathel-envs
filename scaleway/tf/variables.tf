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
variable "SHATHEL_ENVPACKAGE_IMAGE_ID" {
  default = "this should be set by prepare.groovy"
}
variable "SHATHEL_ENV_SCALEWAY_REGION" {
  default = "par1"
}
variable "SHATHEL_ENV_SCALEWAY_ORGANISATION" { // ACCESS token
}
variable "SHATHEL_ENV_SCALEWAY_SIZE" {
  default = "VC1S"
}
variable "SHATHEL_ENV_DOCKER_VERSION" {
  default = "17.06.0"
}

variable "SHATHEL_ENVPACKAGE_USER" {
  default = "root"
}

variable "SHATHEL_ENV_SCALEWAY_VOLUME_MANAGER_SIZE" {
  default = "10"
}

variable "SHATHEL_ENV_SCALEWAY_VOLUME_MANAGER_TYPE" {
  default = "l_ssd"
}

variable "SHATHEL_ENV_SCALEWAY_VOLUME_WORKER_SIZE" {
  default = "10"
}

variable "SHATHEL_ENV_SCALEWAY_VOLUME_WORKER_TYPE" {
  default = "l_ssd"
}

variable "SHATHEL_ENV_SCALEWAY_PRIVATE_KEY" { // this is a key added mannualy on https://cloud.scaleway.com/#/credentials
}