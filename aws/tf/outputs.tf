data "template_file" "manager-details" {
  count = "${aws_eip.shathel_manager_ip.count}"
//  depends_on = [
//    "aws_eip.shathel_manager_ip",
//  ]
  template = <<-EOF
              ${element(aws_eip.shathel_manager_ip.*.public_ip, count.index)} private_ip=${element(aws_eip.shathel_manager_ip.*.private_ip, count.index)} public_ip=${element(aws_eip.shathel_manager_ip.*.public_ip, count.index)} shathel_name=${element(aws_instance.shathel_manager.*.tags.Name, count.index)} shathel_role=manager
              EOF
}
data "template_file" "worker-details" {
  count = "${aws_instance.shathel_worker.count}"
  template = <<-EOF
              ${element(aws_instance.shathel_worker.*.public_dns, count.index)} private_ip=${element(aws_instance.shathel_worker.*.private_ip, count.index)} public_ip=${element(aws_instance.shathel_worker.*.public_dns, count.index)} shathel_name=${element(aws_instance.shathel_worker.*.tags.Name, count.index)} shathel_role=worker
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

