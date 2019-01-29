//  This is a hack for adding shathel keys to hosts
//    for this to work you have to firstly add your own public key to scaleway's site
//    https://cloud.scaleway.com/#/credentials
resource "null_resource" "shathel_manager" {
  depends_on = [
    "scaleway_server.shathel_manager",
    "scaleway_server.shathel_manager_small",
    "scaleway_ip.manager_public_ip"
  ]

  count = "${scaleway_ip.manager_public_ip.count}"

  triggers = {
    manager_ids = "${join(",",scaleway_ip.manager_public_ip.*.id)}"
  }

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file(var.SHATHEL_ENV_SCALEWAY_PRIVATE_KEY)}"
    host = "${element(scaleway_ip.manager_public_ip.*.ip,count.index)}"
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
      "~/docker-shathel.sh ${var.SHATHEL_SOLUTION_DOCKER_PACKAGE}"
    ]
  }
}


resource "null_resource" "shathel_worker" {
  depends_on = [
    "scaleway_server.shathel_worker",
    "scaleway_server.shathel_worker_small",
    "scaleway_ip.worker_public_ip"
  ]

  count = "${scaleway_ip.worker_public_ip.count}"

  triggers = {
    manager_ids = "${join(",",scaleway_ip.worker_public_ip.*.id)}"
  }

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file(var.SHATHEL_ENV_SCALEWAY_PRIVATE_KEY)}"
    host = "${element(scaleway_ip.worker_public_ip.*.ip,count.index)}"
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
      "~/docker-shathel.sh ${var.SHATHEL_SOLUTION_DOCKER_PACKAGE}"
    ]
  }
}