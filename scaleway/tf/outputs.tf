data "template_file" "manager-details" {
  count = "${scaleway_ip.manager_public_ip.count}"
  template = <<-EOF
              ${element(scaleway_ip.manager_public_ip.*.ip, count.index)} private_ip=${element(scaleway_server.shathel_manager.*.private_ip, count.index)} public_ip=${element(scaleway_ip.manager_public_ip.*.ip, count.index)} shathel_name=${element(scaleway_server.shathel_manager.*.name, count.index)} shathel_role=manager
              EOF
}
data "template_file" "worker-details" {
  count = "${scaleway_ip.worker_public_ip.count}"
  template = <<-EOF
              ${element(scaleway_ip.worker_public_ip.*.ip, count.index)} private_ip=${element(scaleway_server.shathel_worker.*.private_ip, count.index)} public_ip=${element(scaleway_ip.worker_public_ip.*.ip, count.index)} shathel_name=${element(scaleway_server.shathel_worker.*.name, count.index)} shathel_role=worker
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

