resource "scaleway_security_group" "security" {
  name        = "${var.SHATHEL_ENV_SOLUTION_NAME}-security"
  description = "allow SSH, HTTP, Swarm and HTTPS traffic"
}

variable "secured_ports" {
  type        = "list"
  description = "list of allowed ports"
  default = [80,22,443]
}

variable "swarm_ports_tcp" {
  type        = "list"
  description = "list of swarm communication ports"
  default = [2375, 2376, 2377, 4789]
}



variable "swarm_ports_udp" {
  type        = "list"
  description = "list of swarm communication ports"
  default = [7946, 4789]
}

resource "scaleway_security_group_rule" "secure_in" {
  count = "${length(var.secured_ports)}"
  security_group = "${scaleway_security_group.security.id}"
  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = "${element(var.secured_ports, count.index)}"
  depends_on = ["scaleway_ip.worker_public_ip", "scaleway_ip.manager_public_ip"]
}

# Allow TCP swarm communication
resource "scaleway_security_group_rule" "swarm_in_tcp" {
  count = "${length(var.swarm_ports_tcp)}"
  security_group = "${scaleway_security_group.security.id}"
  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = "${element(var.swarm_ports_tcp, count.index)}"
  depends_on = ["scaleway_ip.worker_public_ip", "scaleway_ip.manager_public_ip"]
}


# Allow UDP swarm communication
resource "scaleway_security_group_rule" "swarm_in_udp" {
  count = "${length(var.swarm_ports_udp)}"
  security_group = "${scaleway_security_group.security.id}"
  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "UDP"
  port      = "${element(var.swarm_ports_udp, count.index)}"
  depends_on = ["scaleway_ip.worker_public_ip", "scaleway_ip.manager_public_ip"]
}

// TODO when scaleway adds some range based rules to allow client connections receiving responses on Ephemeral Port Range move away from iptables rules
//resource "scaleway_security_group_rule" "drop_all_udp" {
//  security_group = "${scaleway_security_group.security.id}"
//  action = "drop"
//  direction = "inbound"
//  ip_range = "0.0.0.0/0"
//  protocol = "UDP"
//  depends_on = ["scaleway_security_group_rule.secure_in", "scaleway_security_group_rule.swarm_in_tcp","scaleway_security_group_rule.swarm_in_udp"]
//}
//
//resource "scaleway_security_group_rule" "drop_all_tcp" {
//  security_group = "${scaleway_security_group.security.id}"
//  action    = "drop"
//  direction = "inbound"
//  ip_range  = "0.0.0.0/0"
//  protocol  = "TCP"
//  depends_on = ["scaleway_security_group_rule.secure_in", "scaleway_security_group_rule.swarm_in_tcp","scaleway_security_group_rule.swarm_in_udp"]
//}