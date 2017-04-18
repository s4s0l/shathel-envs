provider "aws" {
  access_key = "${var.SHATHEL_ENV_AWS_ACCESSKEY}"
  secret_key = "${var.SHATHEL_ENV_AWS_SECRETKEY}"
  region = "${var.SHATHEL_ENV_AWS_REGION}"
}


resource "aws_key_pair" "shathel" {
  key_name_prefix = "${var.SHATHEL_ENV_SOLUTION_NAME}"
  public_key = "${file(format("%s/id_rsa.pub",var.SHATHEL_ENVPACKAGE_KEY_DIR))}"
}