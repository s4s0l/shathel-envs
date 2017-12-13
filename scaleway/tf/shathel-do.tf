provider "scaleway" {
  organization = "${var.SHATHEL_ENV_DO_ORGANISATION}"
  token        = "${var.SHATHEL_ENV_DO_TOKEN}"
  region        = "${var.SHATHEL_ENV_DO_REGION}"
}