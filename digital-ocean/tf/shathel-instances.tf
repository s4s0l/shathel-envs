resource "digitalocean_droplet" "shathel_manager" {
  count = "${var.SHATHEL_ENV_MANAGERS}"
  image = "${var.SHATHEL_ENVPACKAGE_IMAGE_ID}"
  region = "${var.SHATHEL_ENV_DO_REGION}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-manager-${count.index+1}"
  size = "${var.SHATHEL_ENV_DO_SIZE}"
  backups = "${var.SHATHEL_ENV_DO_BACKUPS}"
  ssh_keys = [
    "${digitalocean_ssh_key.shathel.id}"]
  private_networking = true
  tags = [
    //see https://github.com/hashicorp/terraform/issues/9099
    //    "${digitalocean_tag.shathel_tag.id}",
    //    "${digitalocean_tag.shathel_manager.id}",
    "${digitalocean_tag.shathel_solution.id}"
  ]
  lifecycle {
    ignore_changes = ["volume_ids"]
  }
}

resource "digitalocean_droplet" "shathel_worker" {
  count = "${var.SHATHEL_ENV_WORKERS}"
  image = "${var.SHATHEL_ENVPACKAGE_IMAGE_ID}"
  region = "${var.SHATHEL_ENV_DO_REGION}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-worker-${count.index+1}"
  size = "${var.SHATHEL_ENV_DO_SIZE}"
  backups = "${var.SHATHEL_ENV_DO_BACKUPS}"
  ssh_keys = [
    "${digitalocean_ssh_key.shathel.id}"]
  private_networking = true
  tags = [
    //see https://github.com/hashicorp/terraform/issues/9099
    //    "${digitalocean_tag.shathel_worker.id}",
    //    "${digitalocean_tag.shathel_tag.id}"
    "${digitalocean_tag.shathel_solution.id}",
  ]
  lifecycle {
    ignore_changes = ["volume_ids"]
  }
}





