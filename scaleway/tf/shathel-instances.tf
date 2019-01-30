data "scaleway_image" "img" {
  architecture = "x86_64"
  name         = "${var.SHATHEL_ENV_SCALEWAY_SIZE == "START1-XS" ? "Ubuntu Mini Xenial 25G" : var.SHATHEL_ENVPACKAGE_IMAGE_NAME}"
}


resource "scaleway_server" "shathel_manager" {
  count = "${var.SHATHEL_ENVPACKAGE_VOLUME_SIZE == 0 ? 0 : var.SHATHEL_ENV_MANAGERS}"
  type  = "${var.SHATHEL_ENV_SCALEWAY_SIZE}"
  image = "${data.scaleway_image.img.id}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-manager-${count.index+1}"
  security_group = "${scaleway_security_group.security.id}"

  volume {
    size_in_gb = "${var.SHATHEL_ENVPACKAGE_VOLUME_SIZE}"
    type       = "${var.SHATHEL_ENVPACKAGE_VOLUME_TYPE}"
  }

  tags = [
    "shathel-${var.SHATHEL_ENV_SOLUTION_NAME}"
  ]
}

resource "scaleway_server" "shathel_manager_small" {
  count = "${var.SHATHEL_ENVPACKAGE_VOLUME_SIZE != 0 ? 0 : var.SHATHEL_ENV_MANAGERS}"
  type  = "${var.SHATHEL_ENV_SCALEWAY_SIZE}"
  image = "${data.scaleway_image.img.id}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-manager-${count.index+1}"
  security_group = "${scaleway_security_group.security.id}"
  tags = [
    "shathel-${var.SHATHEL_ENV_SOLUTION_NAME}"
  ]
}


resource "scaleway_server" "shathel_worker" {
  count = "${var.SHATHEL_ENVPACKAGE_VOLUME_SIZE == 0 ? 0 : var.SHATHEL_ENV_WORKERS}"
  type  = "${var.SHATHEL_ENV_SCALEWAY_SIZE}"
  image = "${data.scaleway_image.img.id}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-worker-${count.index+1}"
  security_group = "${scaleway_security_group.security.id}"

  volume {
    size_in_gb = "${var.SHATHEL_ENVPACKAGE_VOLUME_SIZE}"
    type       = "${var.SHATHEL_ENVPACKAGE_VOLUME_TYPE}"
  }

  tags = [
    "shathel-${var.SHATHEL_ENV_SOLUTION_NAME}"
  ]
}

resource "scaleway_server" "shathel_worker_small" {
  count = "${var.SHATHEL_ENVPACKAGE_VOLUME_SIZE != 0 ? 0 : var.SHATHEL_ENV_WORKERS}"
  type  = "${var.SHATHEL_ENV_SCALEWAY_SIZE}"
  image = "${data.scaleway_image.img.id}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-worker-${count.index+1}"
  security_group = "${scaleway_security_group.security.id}"
  tags = [
    "shathel-${var.SHATHEL_ENV_SOLUTION_NAME}"
  ]
}


// Additional information about ip -> server relationship

resource "scaleway_ip" "manager_public_ip" {
  count = "${scaleway_server.shathel_manager.count + scaleway_server.shathel_manager_small.count}"
  server = "${element(concat(scaleway_server.shathel_manager.*.id,scaleway_server.shathel_manager_small.*.id), count.index)}"
}

resource "scaleway_ip" "worker_public_ip" {
  count = "${scaleway_server.shathel_worker.count + scaleway_server.shathel_worker_small.count}"
  server = "${element(concat(scaleway_server.shathel_worker.*.id,scaleway_server.shathel_worker_small.*.id), count.index)}"
}

