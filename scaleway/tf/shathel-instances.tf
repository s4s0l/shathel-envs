resource "scaleway_server" "shathel_manager" {
  count = "${var.SHATHEL_ENV_MANAGERS}"
  type  = "${var.SHATHEL_ENV_DO_SIZE}"
  image = "${var.SHATHEL_ENVPACKAGE_IMAGE_ID}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-manager-${count.index+1}"
  enable_ipv6=true
  dynamic_ip_required=true

//  volume {
//    size_in_gb = 20
//    type       = "l_ssd"
//  }

  tags = [
    "shathel-${var.SHATHEL_ENV_SOLUTION_NAME}"
  ]
}


resource "scaleway_server" "shathel_worker" {
  count = "${var.SHATHEL_ENV_WORKERS}"
  type  = "${var.SHATHEL_ENV_DO_SIZE}"
  image = "${var.SHATHEL_ENVPACKAGE_IMAGE_ID}"
  name = "${var.SHATHEL_ENV_SOLUTION_NAME}-worker-${count.index+1}"
  enable_ipv6=true
  dynamic_ip_required=true

  //  volume {
  //    size_in_gb = 20
  //    type       = "l_ssd"
  //  }

  tags = [
    "shathel-${var.SHATHEL_ENV_SOLUTION_NAME}"
  ]
}





//  This is a hack for adding shathel keys to hosts
//    for this to work you have to firstly add your own public key to scaleway's site
//    https://cloud.scaleway.com/#/credentials
resource "null_resource" "shathel_manager" {
  depends_on = [
    "scaleway_server.shathel_manager"
  ]

  count = "${scaleway_server.shathel_manager.count}"

  triggers = {
    manager_ids = "${join(",",scaleway_server.shathel_manager.*.id)}"
  }

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file(var.SHATHEL_ENV_SCALEWAY_PRIVATE_KEY)}"
    host = "${element(scaleway_server.shathel_manager.*.public_ip,count.index)}"
  }

  provisioner "file" {
    source      = "./docker-shathel.sh"
    destination = "~/docker-shathel.sh"
  }

  provisioner "file" {
    source      = "${format("%s/id_rsa.pub",var.SHATHEL_ENVPACKAGE_KEY_DIR )}"
    destination = "/tmp/id_rsa_key.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/id_rsa_key.pub >> ~/.ssh/instance_keys",
      "scw-fetch-ssh-keys --upgrade",
      "rm -f /tmp/id_rsa_key.pub",
      "chmod +x ~/docker-shathel.sh",
      "~/docker-shathel.sh ${var.SHATHEL_ENV_DOCKER_VERSION}"
    ]
  }
}


resource "null_resource" "shathel_worker" {
  depends_on = [
    "scaleway_server.shathel_worker"
  ]

  count = "${scaleway_server.shathel_worker.count}"

  triggers = {
    manager_ids = "${join(",",scaleway_server.shathel_worker.*.id)}"
  }

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file(var.SHATHEL_ENV_SCALEWAY_PRIVATE_KEY)}"
    host = "${element(scaleway_server.shathel_worker.*.public_ip,count.index)}"
  }

  provisioner "file" {
    source      = "./docker-shathel.sh"
    destination = "~/docker-shathel.sh"
  }

  provisioner "file" {
    source      = "${format("%s/id_rsa.pub",var.SHATHEL_ENVPACKAGE_KEY_DIR )}"
    destination = "/tmp/id_rsa_key.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/id_rsa_key.pub >> ~/.ssh/instance_keys",
      "scw-fetch-ssh-keys --upgrade",
      "rm -f /tmp/id_rsa_key.pub",
      "chmod +x ~/docker-shathel.sh",
      "~/docker-shathel.sh ${var.SHATHEL_ENV_DOCKER_VERSION}"
    ]
  }
}
