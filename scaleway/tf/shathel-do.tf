provider "scaleway" {
  organization = "${var.SHATHEL_ENV_SCALEWAY_ORGANISATION}"
  token        = "${var.SHATHEL_ENV_SCALEWAY_TOKEN}"
  region        = "${var.SHATHEL_ENV_SCALEWAY_REGION}"
}