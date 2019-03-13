variable "SHATHEL_ENV_AWS_ACCESSKEY" {
}
variable "SHATHEL_ENV_AWS_SECRETKEY" {
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

variable "SHATHEL_ENV_AWS_REGION" {
  default = "eu-central-1"
}
variable "SHATHEL_ENV_AWS_VPCCIDR" {
  default = "10.0.0.0/16"
}
variable "SHATHEL_ENV_AWS_ZONES" {
  type = "list"
  default = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]
}
variable "SHATHEL_ENV_AWS_AVZONECIDR" {
  type = "map"
  default = {
    "eu-central-1a" = "10.0.0.0/20",
    "eu-central-1b" = "10.0.16.0/20",
    "eu-central-1c" = "10.0.32.0/20"
  }
}
variable "SHATHEL_ENVPACKAGE_IMAGE_ID" {
  default = "this should be set by prepare.groovy"
}
variable "SHATHEL_ENVPACKAGE_USER" {
  default = "ubuntu"
}
variable "SHATHEL_ENV_AWS_INSTANCETYPE" {
  default = "t2.micro"
}