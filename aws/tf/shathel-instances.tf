resource "aws_instance" "shathel_manager" {
  count = "${var.SHATHEL_ENV_MANAGERS}"
  ami = "${var.SHATHEL_ENVPACKAGE_IMAGE_ID}"
  instance_type = "${var.SHATHEL_ENV_AWS_INSTANCETYPE}"
  key_name = "${aws_key_pair.shathel.key_name}"
  availability_zone = "${element(var.SHATHEL_ENV_AWS_ZONES,count.index)}"
  subnet_id = "${element(aws_subnet.shathel.*.id, count.index)}"
  private_ip = "${cidrhost(element(aws_subnet.shathel.*.cidr_block, count.index ), 4+ count.index)}"
  vpc_security_group_ids = [
    "${aws_security_group.shathel_common.id}",
    "${aws_security_group.shathel_internal.id}",
    "${aws_security_group.shathel_www.id}",
    //    "${aws_security_group.shathel_docker.id}",
    //    "${aws_security_group.shathel_swarm.id}",
  ]
  //  Needed because otherwise provisioner will not be able to connect to instance
  //  Will be overriden by eip later on
  associate_public_ip_address = true
  connection {
    user = "${var.SHATHEL_ENVPACKAGE_USER}"
    private_key = "${file(format("%s/id_rsa",var.SHATHEL_ENVPACKAGE_KEY_DIR))}"
  }
  //dummy provisioninng to be sure instance is up
  provisioner "remote-exec" {
    inline = [
      "sudo echo Hello",
    ]
  }
  tags {
    Shathel = "true"
    ShathelSolution = "${var.SHATHEL_ENV_SOLUTION_NAME}"
    Name = "${var.SHATHEL_ENV_SOLUTION_NAME}-manager-${count.index+1}"
    Role = "manager"
  }
}

resource "aws_eip" "shathel_manager_ip" {
  count = "${var.SHATHEL_ENV_MANAGERS}"
  instance = "${element(aws_instance.shathel_manager.*.id, count.index)}"
  depends_on = [
    "aws_instance.shathel_manager"]
}


resource "aws_instance" "shathel_worker" {
  count = "${var.SHATHEL_ENV_WORKERS}"
  ami = "${var.SHATHEL_ENVPACKAGE_IMAGE_ID}"
  instance_type = "${var.SHATHEL_ENV_AWS_INSTANCETYPE}"
  key_name = "${aws_key_pair.shathel.key_name}"
  availability_zone = "${element(var.SHATHEL_ENV_AWS_ZONES,-count.index  )}"
  subnet_id = "${element(aws_subnet.shathel.*.id, -count.index )}"
  private_ip = "${cidrhost(element(aws_subnet.shathel.*.cidr_block, -count.index ), 4+ count.index + aws_instance.shathel_manager.count)}"
  vpc_security_group_ids = [
    "${aws_security_group.shathel_common.id}",
    "${aws_security_group.shathel_internal.id}",
    "${aws_security_group.shathel_www.id}",
    //    "${aws_security_group.shathel_docker.id}",
    //    "${aws_security_group.shathel_swarm.id}",
  ]
  //  Needed because otherwise provisioner will not be able to connect to instance
  //  Will be overriden by eip later on
  associate_public_ip_address = true
  connection {
    user = "${var.SHATHEL_ENVPACKAGE_USER}"
    private_key = "${file(format("%s/id_rsa",var.SHATHEL_ENVPACKAGE_KEY_DIR))}"
  }
  //dummy provisioninng to be sure instance is up
  provisioner "remote-exec" {
    inline = [
      "sudo echo Hello",
    ]
  }
  tags {
    Shathel = "true"
    ShathelSolution = "${var.SHATHEL_ENV_SOLUTION_NAME}"
    Name = "${var.SHATHEL_ENV_SOLUTION_NAME}-worker-${count.index+1}"
    Role = "worker"
  }
}



