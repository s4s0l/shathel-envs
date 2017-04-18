provider "digitalocean" {
  token = "${var.SHATHEL_ENV_DO_TOKEN}"
}

resource "digitalocean_ssh_key" "shathel" {
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-key"
  public_key = "${file(format("%s/id_rsa.pub",var.SHATHEL_ENVPACKAGE_KEY_DIR ) )}"
}

//resource "digitalocean_tag" "shathel_tag" {
//  name = "shathel"
//}

resource "digitalocean_tag" "shathel_solution" {
  name = "shathel-${var.SHATHEL_ENV_SOLUTION_NAME}"
}
//
//resource "digitalocean_tag" "shathel_worker" {
//  name = "shathel-worker"
//}
//
//resource "digitalocean_tag" "shathel_manager" {
//  name = "shathel-manager"
//}

