provider "cloudflare" {
  email = "${var.SHATHEL_ENV_CF_EMAIL}"
  token = "${var.SHATHEL_ENV_CF_TOKEN}"
}


resource "cloudflare_record" "shathel" {
  count = "${digitalocean_droplet.shathel_manager.count}"
  domain = "${var.SHATHEL_ENV_CF_DOMAIN}"
  name = "${var.SHATHEL_ENV_DOMAIN}"
  type = "A"
  value = "${element(digitalocean_droplet.shathel_manager.*.ipv4_address, count.index)}"
  proxied = false
}
