data "template_file" "manager-details" {
  count = "${digitalocean_droplet.shathel_manager.count}"
  template = <<-EOF
              ${element(digitalocean_droplet.shathel_manager.*.ipv4_address, count.index)} private_ip=${element(digitalocean_droplet.shathel_manager.*.ipv4_address_private, count.index)} public_ip=${element(digitalocean_droplet.shathel_manager.*.ipv4_address, count.index)} shathel_name=${element(digitalocean_droplet.shathel_manager.*.name, count.index)} shathel_role=manager
              EOF
}
data "template_file" "worker-details" {
  count = "${digitalocean_droplet.shathel_worker.count}"
  template = <<-EOF
              ${element(digitalocean_droplet.shathel_worker.*.ipv4_address, count.index)} private_ip=${element(digitalocean_droplet.shathel_worker.*.ipv4_address_private, count.index)} public_ip=${element(digitalocean_droplet.shathel_worker.*.ipv4_address, count.index)} shathel_name=${element(digitalocean_droplet.shathel_worker.*.name, count.index)} shathel_role=worker
              EOF
}


resource "null_resource" "ansible" {
  triggers {
    managers_template = "${join("\nxx", data.template_file.manager-details.*.rendered)}"
    workers_template = "${join("\nxx", data.template_file.worker-details.*.rendered)}"
  }

  provisioner "local-exec" {
    command = <<-EOF
              echo "" > ${var.SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY}
              echo "[shathel_manager_hosts]" >> ${var.SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY}
              echo "${join("\n", data.template_file.manager-details.*.rendered)}" >> ${var.SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY}
              echo "[shathel_worker_hosts]" >> ${var.SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY}
              echo "${join("\n", data.template_file.worker-details.*.rendered)}" >> ${var.SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY}
              EOF
  }
}


output "shathel_terraform_output" {
  value = "ok"
}

