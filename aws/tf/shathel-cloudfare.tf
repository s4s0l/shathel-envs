provider "cloudflare" {
  email = "${var.SHATHEL_ENV_CF_EMAIL}"
  token = "${var.SHATHEL_ENV_CF_TOKEN}"
}


resource "cloudflare_record" "shathel" {
  count = "${aws_eip.shathel_manager_ip.count}"
  domain = "${var.SHATHEL_ENV_CF_DOMAIN}"
  name = "${var.SHATHEL_ENV_DOMAIN}"
  type = "A"
  value = "${element(aws_eip.shathel_manager_ip.*.public_ip, count.index)}"
  proxied = false
}
