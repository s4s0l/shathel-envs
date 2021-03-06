resource "aws_vpc" "shathel" {
  cidr_block = "${var.SHATHEL_ENV_AWS_VPCCIDR}"
  enable_dns_hostnames = true
  tags {
    Shathel = "true"
    ShathelSolution = "${var.SHATHEL_ENV_SOLUTION_NAME}"
    Name = "${var.SHATHEL_ENV_SOLUTION_NAME}"
  }
}
//default group allows all
resource "aws_default_security_group" "shathel" {
  vpc_id = "${aws_vpc.shathel.id}"

  ingress {
    protocol = -1
    self = true
    from_port = 0
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags {
    Shathel = "true"
    ShathelSolution = "${var.SHATHEL_ENV_SOLUTION_NAME}"
    Name = "${var.SHATHEL_ENV_SOLUTION_NAME}"
  }
}

resource "aws_subnet" "shathel" {
  vpc_id = "${aws_vpc.shathel.id}"
  count = "${length(var.SHATHEL_ENV_AWS_ZONES)}"
  availability_zone = "${element(var.SHATHEL_ENV_AWS_ZONES,count.index )}"
  cidr_block = "${var.SHATHEL_ENV_AWS_AVZONECIDR[element(var.SHATHEL_ENV_AWS_ZONES,count.index )]}"
  tags {
    Shathel = "true"
    ShathelSolution = "${var.SHATHEL_ENV_SOLUTION_NAME}"
    Name = "${var.SHATHEL_ENV_SOLUTION_NAME}-sn-${element(var.SHATHEL_ENV_AWS_ZONES,count.index )}"
  }
}

resource "aws_internet_gateway" "shathel" {
  vpc_id = "${aws_vpc.shathel.id}"
  tags {
    Shathel = "true"
    Name = "${var.SHATHEL_ENV_SOLUTION_NAME}"
    ShathelSolution = "${var.SHATHEL_ENV_SOLUTION_NAME}"
  }
}

resource "aws_default_route_table" "shathel" {
  default_route_table_id = "${aws_vpc.shathel.default_route_table_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.shathel.id}"
  }

  tags {
    Shathel = "true"
    Name = "${var.SHATHEL_ENV_SOLUTION_NAME}"
    ShathelSolution = "${var.SHATHEL_ENV_SOLUTION_NAME}"
  }
}



