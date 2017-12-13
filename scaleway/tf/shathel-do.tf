provider "scaleway" {
  organization = "${var.SHATHEL_ENVPACKAGE_DO_ORGANISATION}"
  token        = "${var.SHATHEL_ENV_DO_TOKEN}"
  region        = "${var.SHATHEL_ENV_DO_REGION}"
}