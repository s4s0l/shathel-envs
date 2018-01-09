resource "scaleway_server" "shathel_manager" {
  count = "${var.SHATHEL_ENV_MANAGERS}"
  type  = "${var.SHATHEL_ENV_SCALEWAY_SIZE}"
  image = "${var.SHATHEL_ENVPACKAGE_IMAGE_ID}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-manager-${count.index+1}"
  security_group = "${scaleway_security_group.security.id}"

  volume {
    size_in_gb = "${var.SHATHEL_ENV_SCALEWAY_VOLUME_MANAGER_SIZE}"
    type       = "${var.SHATHEL_ENV_SCALEWAY_VOLUME_MANAGER_TYPE}"
  }

  tags = [
    "shathel-${var.SHATHEL_ENV_SOLUTION_NAME}"
  ]
}


resource "scaleway_server" "shathel_worker" {
  count = "${var.SHATHEL_ENV_WORKERS}"
  type  = "${var.SHATHEL_ENV_SCALEWAY_SIZE}"
  image = "${var.SHATHEL_ENVPACKAGE_IMAGE_ID}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-worker-${count.index+1}"
  security_group = "${scaleway_security_group.security.id}"

  volume {
    size_in_gb = "${var.SHATHEL_ENV_SCALEWAY_VOLUME_WORKER_SIZE}"
    type       = "${var.SHATHEL_ENV_SCALEWAY_VOLUME_WORKER_TYPE}"
  }

  tags = [
    "shathel-${var.SHATHEL_ENV_SOLUTION_NAME}"
  ]
}


// Additional information about ip -> server relationship

resource "scaleway_ip" "manager_public_ip" {
  count = "${var.SHATHEL_ENV_MANAGERS}"
  server = "${element(scaleway_server.shathel_manager.*.id, count.index)}"
}

resource "scaleway_ip" "worker_public_ip" {
  count = "${var.SHATHEL_ENV_WORKERS}"
  server = "${element(scaleway_server.shathel_worker.*.id, count.index)}"
}

