#!/usr/bin/env groovy
@Grab('ch.qos.logback:logback-classic:1.1.7')
def masterPassword = "SomePassword".bytes
def SHATHEL_ENVPACKAGE_WORKING_DIR = new File("../../virtualbox").absolutePath
def SHATHEL_ENVPACKAGE_SETTINGS_DIR = new File("./.shathel-dir/settings").absolutePath
def SHATHEL_ENVPACKAGE_TMP_DIR = new File("./.shathel-dir/tmp").absolutePath
def SHATHEL_ENVPACKAGE_KEY_DIR = "${SHATHEL_ENVPACKAGE_SETTINGS_DIR}/key"
def SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY = "${SHATHEL_ENVPACKAGE_SETTINGS_DIR}/ansible-inventory"
def SHATHEL_ENVPACKAGE_VERSION = "1.4"
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
def vagrantEnvs = commonEnvs + [
        "VAGRANT_DOTFILE_PATH": SHATHEL_ENVPACKAGE_SETTINGS_DIR,
]
def ansibleEnvs = commonEnvs + [
        "ANSIBLE_HOST_KEY_CHECKING": "False",
        "ANSIBLE_NOCOWS"           : "1",
]
def ansibleExtraVars = commonEnvs.collect {
    "${it.key.toLowerCase()}=${it.value}"
}.join(" ")

// generate key

def id_rsa = new File(SHATHEL_ENVPACKAGE_KEY_DIR, "id_rsa")
if (!id_rsa.exists()) {
    exec("ssh-keygen").executeForOutput("-t", "rsa", "-C", "${SHATHEL_ENV_EMAIL}", "-N", "", "-f", "${id_rsa.absolutePath}")
}

//invoke prepare vagrant
def box = new File(SHATHEL_ENVPACKAGE_IMAGE)


if (!box.exists()) {
    exec("vagrant", vagrantEnvs + ["VAGRANT_VAGRANTFILE": "Vagrantfile-image"]).executeForOutput(workingDir, "up")
    exec("vagrant", vagrantEnvs + ["VAGRANT_VAGRANTFILE": "Vagrantfile-image"]).executeForOutput(workingDir, "package --output ${SHATHEL_ENVPACKAGE_IMAGE}")
    exec("vagrant", vagrantEnvs + ["VAGRANT_VAGRANTFILE": "Vagrantfile-image"]).executeForOutput(workingDir, "destroy -f")
}

//invoke vagrant up
exec("vagrant", vagrantEnvs).executeForOutput(workingDir, "up")
//invoke ansible setup

exec("ansible-playbook", ansibleEnvs).executeForOutput(null, workingDir, [:],
        "-u", SHATHEL_ENVPACKAGE_USER.toString(),
        "--timeout=60",
        "--private-key=${SHATHEL_ENVPACKAGE_KEY_DIR}/id_rsa".toString(),
        "--inventory-file=${SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY}".toString(),
        "--extra-vars", ansibleExtraVars.toString(),
        "${SHATHEL_ENVPACKAGE_WORKING_DIR}/../common/hostname.yml".toString())

//prepare ssh keys for docker
def hosts = Inventory.getHosts(new File(SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY))
def cm = new CertificateManager(new File(SHATHEL_ENVPACKAGE_CERTS_DIR), masterPassword, SHATHEL_ENV_SOLUTION_NAME)
cm.clientCerts
hosts.each {
    if (cm.getKeyAndCert(it.shathel_name).isEmpty()) {
        exec("ssh-keygen", [:]).executeForOutput("-f /home/sasol/.ssh/known_hosts -R ${it.public_ip}")
        cm.generateKeyAndCert(
                it.shathel_name,
                [it.shathel_name, it.name, "localhost"],
                [it.private_ip, it.public_ip, "127.0.0.1"])
    }
}

//invoke swarm
exec("ansible-playbook", ansibleEnvs).executeForOutput(null, workingDir, [:],
        "-u", SHATHEL_ENVPACKAGE_USER.toString(),
        "--timeout=60",
        "--private-key=${SHATHEL_ENVPACKAGE_KEY_DIR}/id_rsa".toString(),
        "--inventory-file=${SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY}".toString(),
        "--extra-vars", ansibleExtraVars.toString(),
        "${SHATHEL_ENVPACKAGE_WORKING_DIR}/../common/swarmize.yml".toString())

def exec(String command, Map<String, String> environment = [:]) {
    def LOGGER = org.slf4j.LoggerFactory.getLogger(Object.class)
    new ExecWrapper(LOGGER, command, environment)
}

