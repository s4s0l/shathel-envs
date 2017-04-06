#!/usr/bin/env groovy
@Grab('ch.qos.logback:logback-classic:1.1.7')
def masterPassword = "SomePassword".bytes
def SHATHEL_ENVPACKAGE_WORKING_DIR = new File("../../virtualbox").absolutePath
def SHATHEL_ENVPACKAGE_SETTINGS_DIR = new File("./.shathel-dir/settings").absolutePath
def SHATHEL_ENVPACKAGE_TMP_DIR = new File("./.shathel-dir/tmp").absolutePath
def SHATHEL_ENVPACKAGE_KEY_DIR = "${SHATHEL_ENVPACKAGE_SETTINGS_DIR}/key"
def SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY = "${SHATHEL_ENVPACKAGE_SETTINGS_DIR}/ansible-inventory"
def SHATHEL_ENVPACKAGE_VERSION = "1.0"
def SHATHEL_ENVPACKAGE_IMAGE = "${SHATHEL_ENVPACKAGE_TMP_DIR}/shathel-env-${SHATHEL_ENVPACKAGE_VERSION}.box"
def SHATHEL_ENVPACKAGE_USER = "ubuntu"
def SHATHEL_ENVPACKAGE_CERTS_DIR = "${SHATHEL_ENVPACKAGE_SETTINGS_DIR}/certificates"
def SHATHEL_ENV_MANAGERS = "2"
def SHATHEL_ENV_WORKERS = "1"
def SHATHEL_SOLUTION_NAME = "shtl"
def SHATHEL_ENV_NAME = "test"
def SHATHEL_ENV_SOLUTION_NAME = "shtl-test"


def SHATHEL_ENV_DOMAIN = "this.is.my.domain"
def SHATHEL_ENV_EMAIL = "mwielgus@outlook.com"


def workingDir = new File(SHATHEL_ENVPACKAGE_WORKING_DIR)
new File(SHATHEL_ENVPACKAGE_SETTINGS_DIR).mkdirs()
new File(SHATHEL_ENVPACKAGE_TMP_DIR).mkdirs()
new File(SHATHEL_ENVPACKAGE_KEY_DIR).mkdirs()
new File(SHATHEL_ENVPACKAGE_CERTS_DIR).mkdirs()


def commonEnvs = [
        "SHATHEL_ENVPACKAGE_VERSION"          : SHATHEL_ENVPACKAGE_VERSION,
        "SHATHEL_ENVPACKAGE_SETTINGS_DIR"     : SHATHEL_ENVPACKAGE_SETTINGS_DIR,
        "SHATHEL_ENVPACKAGE_IMAGE"            : SHATHEL_ENVPACKAGE_IMAGE,
        "SHATHEL_ENVPACKAGE_KEY_DIR"          : SHATHEL_ENVPACKAGE_KEY_DIR,
        "SHATHEL_ENVPACKAGE_TMP_DIR"          : SHATHEL_ENVPACKAGE_TMP_DIR,
        "SHATHEL_ENVPACKAGE_WORKING_DIR"      : SHATHEL_ENVPACKAGE_WORKING_DIR,
        "SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY": SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY,
        "SHATHEL_ENVPACKAGE_USER"             : SHATHEL_ENVPACKAGE_USER,
        "SHATHEL_ENVPACKAGE_CERTS_DIR"        : SHATHEL_ENVPACKAGE_CERTS_DIR,
        "SHATHEL_ENV_MANAGERS"                : SHATHEL_ENV_MANAGERS,
        "SHATHEL_ENV_WORKERS"                 : SHATHEL_ENV_WORKERS,
        "SHATHEL_SOLUTION_NAME"               : SHATHEL_SOLUTION_NAME,
        "SHATHEL_ENV_NAME"                    : SHATHEL_ENV_NAME,
        "SHATHEL_ENV_SOLUTION_NAME"           : SHATHEL_ENV_SOLUTION_NAME,
        "SHATHEL_ENV_DOMAIN"                  : SHATHEL_ENV_DOMAIN,
        "SHATHEL_ENV_EMAIL"                   : SHATHEL_ENV_EMAIL
]
def vagrantEnvs = commonEnvs << [
        "VAGRANT_DOTFILE_PATH": SHATHEL_ENVPACKAGE_SETTINGS_DIR,
]
def ansibleEnvs = commonEnvs << [
        "ANSIBLE_HOST_KEY_CHECKING": "False",
        "ANSIBLE_NOCOWS"           : "1",
]
def ansibleExtraVars = commonEnvs.collect {
    "${it.key.toLowerCase()}=${it.value}"
}.join(" ")


//invoke vagrant up
exec("vagrant", vagrantEnvs).executeForOutput(workingDir, "destroy -f")


//todo powinno kasowac certy i najlepiej wszystko inne tez

def exec(String command, Map<String, String> environment = [:]) {
    def LOGGER = org.slf4j.LoggerFactory.getLogger(Object.class)
    new ExecWrapper(LOGGER, command, environment)
}