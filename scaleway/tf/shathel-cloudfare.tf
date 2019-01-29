provider "cloudflare" {
  email = "${var.SHATHEL_ENV_CF_EMAIL}"
  token = "${var.SHATHEL_ENV_CF_TOKEN}"
}


resource "cloudflare_record" "shathel" {
  count = "${scaleway_ip.manager_public_ip.count}"
  domain = "${var.SHATHEL_ENV_CF_DOMAIN}"
  name = "${var.SHATHEL_ENV_DOMAIN}"
  type = "A"
  value = "${element(scaleway_ip.manager_public_ip.*.ip, count.index)}"
  proxied = false
}

resource "cloudflare_record" "shathel-domains" {
  count = "${var.SHATHEL_ENV_CF_DOMAINS == "" ? 0 : length(split(",",var.SHATHEL_ENV_CF_DOMAINS))}"
  domain = "${var.SHATHEL_ENV_CF_DOMAIN}"
  name = "${element(split(",",var.SHATHEL_ENV_CF_DOMAINS), count.index)}"
  type = "CNAME"
  value = "${var.SHATHEL_ENV_DOMAIN}"
  proxied = false
}
