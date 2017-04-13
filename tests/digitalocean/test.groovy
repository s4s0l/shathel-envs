#!/usr/bin/env groovy
import groovy.json.JsonSlurper
import groovyx.net.http.ContentType
import groovyx.net.http.HttpResponseDecorator
import groovyx.net.http.RESTClient
import groovyx.net.http.Status

import java.nio.file.Files
import java.nio.file.attribute.PosixFilePermission

@Grab('ch.qos.logback:logback-classic:1.1.7')
@Grab('org.codehaus.groovy.modules.http-builder:http-builder:0.7.1')
@Grab('org.apache.httpcomponents:httpmime:4.2.1')
def masterPassword = "SomePassword".bytes
def SHATHEL_ENVPACKAGE_WORKING_DIR = new File("../../digital-ocean").absolutePath
def SHATHEL_ENVPACKAGE_SETTINGS_DIR = new File("./.shathel-dir/settings").absolutePath
def SHATHEL_ENVPACKAGE_TMP_DIR = new File("./.shathel-dir/tmp").absolutePath
def SHATHEL_ENVPACKAGE_KEY_DIR = "${SHATHEL_ENVPACKAGE_SETTINGS_DIR}/key"
def SHATHEL_ENVPACKAGE_BIN_DIR = new File("./.shathel-dir/bin").absolutePath
def SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY = "${SHATHEL_ENVPACKAGE_SETTINGS_DIR}/ansible-inventory"
def SHATHEL_ENVPACKAGE_VERSION = "1.6"
def SHATHEL_ENVPACKAGE_IMAGE_NAME = "shathel-env-${SHATHEL_ENVPACKAGE_VERSION}"
def SHATHEL_ENVPACKAGE_IMAGE = "${SHATHEL_ENVPACKAGE_TMP_DIR}/${SHATHEL_ENVPACKAGE_IMAGE_NAME}.box"
def SHATHEL_ENVPACKAGE_USER = "root"
def SHATHEL_ENVPACKAGE_CERTS_DIR = "${SHATHEL_ENVPACKAGE_SETTINGS_DIR}/certificates"
def SHATHEL_ENV_MANAGERS = "1"
def SHATHEL_ENV_WORKERS = "0"
def SHATHEL_SOLUTION_NAME = "shtl"
def SHATHEL_ENV_NAME = "test"
def SHATHEL_ENV_SOLUTION_NAME = "shtl-test"
def SHATHEL_ENV_DOMAIN = "this.is.my.domain"
def SHATHEL_ENV_EMAIL = "mwielgus@outlook.com"




def workingDir = new File(SHATHEL_ENVPACKAGE_WORKING_DIR)
new File(SHATHEL_ENVPACKAGE_SETTINGS_DIR).mkdirs()
new File(SHATHEL_ENVPACKAGE_TMP_DIR).mkdirs()
new File(SHATHEL_ENVPACKAGE_KEY_DIR).mkdirs()
new File(SHATHEL_ENVPACKAGE_BIN_DIR).mkdirs()
new File(SHATHEL_ENVPACKAGE_CERTS_DIR).mkdirs()


def commonEnvs = [
        "SHATHEL_ENVPACKAGE_VERSION"          : SHATHEL_ENVPACKAGE_VERSION,
        "SHATHEL_ENVPACKAGE_SETTINGS_DIR"     : SHATHEL_ENVPACKAGE_SETTINGS_DIR,
        "SHATHEL_ENVPACKAGE_BIN_DIR"          : SHATHEL_ENVPACKAGE_BIN_DIR,
        "SHATHEL_ENVPACKAGE_IMAGE"            : SHATHEL_ENVPACKAGE_IMAGE,
        "SHATHEL_ENVPACKAGE_IMAGE_NAME"       : SHATHEL_ENVPACKAGE_IMAGE_NAME,
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

def ansibleEnvs = commonEnvs + [
        "ANSIBLE_HOST_KEY_CHECKING": "False",
        "ANSIBLE_NOCOWS"           : "1",
]


def packerEnvs = commonEnvs + [
        PACKER_CACHE_DIR: "${SHATHEL_ENVPACKAGE_TMP_DIR}/packer/cache",
        PACKER_LOG      : "1",
        PACKER_LOG_PATH : "${SHATHEL_ENVPACKAGE_TMP_DIR}/packer/logs",
]
new File("${SHATHEL_ENVPACKAGE_TMP_DIR}/packer/cache").mkdirs()


def ansibleExtraVars = commonEnvs.collect {
    "${it.key.toLowerCase()}=${it.value}"
}.join(" ")

// generate key
def id_rsa = new File(SHATHEL_ENVPACKAGE_KEY_DIR, "id_rsa")
if (!id_rsa.exists()) {
    exec("ssh-keygen").executeForOutput("-t", "rsa", "-C", "${SHATHEL_ENV_EMAIL}", "-N", "", "-f", "${id_rsa.absolutePath}")
}

def packerVarsFile = new File("./.private/packer.vars.json")
def token = new JsonSlurper().parse(packerVarsFile).shathel_env_dotoken
def getParams = [
        contentType: ContentType.JSON,
        headers    : [Authorization: "Bearer $token"],
        path       : '/v2/snapshots',
        query      : [page: 1, per_page: 10, resource_type: "droplet"],
]
HttpResponseDecorator result = getClient("https://api.digitalocean.com").get(getParams)
assert result.status == 200
def ids = result.data.snapshots.findAll {
    it.name == SHATHEL_ENVPACKAGE_IMAGE_NAME
}.collect { it.id }

println ids

def packerBin = new File(SHATHEL_ENVPACKAGE_BIN_DIR, "packer")
println packerBin
if (!packerBin.exists()) {
    println "Downloading packer"
    Inventory.downloadFile(new File(SHATHEL_ENVPACKAGE_BIN_DIR, "packer.zip"), "https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip")
    exec("unzip").executeForOutput(new File(SHATHEL_ENVPACKAGE_BIN_DIR), "packer.zip")
    Files.setPosixFilePermissions(packerBin.toPath(), Collections.singleton(PosixFilePermission.OWNER_EXECUTE))
}

if (ids.isEmpty()) {
    exec(packerBin.absolutePath, packerEnvs).executeForOutput(workingDir, "build -var-file=${packerVarsFile.absolutePath} ${workingDir.absolutePath}/packer-ubuntu-shathel.json")
    result = getClient("https://api.digitalocean.com").get(getParams)
    assert result.status == 200
    ids = !result.data.snapshots.findAll {
        it.name == SHATHEL_ENVPACKAGE_IMAGE_NAME
    }.collect { it.id }
}

println(ids.head())

//
////invoke vagrant up
//exec("vagrant", vagrantEnvs).executeForOutput(workingDir, "up")
////invoke ansible setup
//
//exec("ansible-playbook", ansibleEnvs).executeForOutput(null, workingDir, [:],
//        "-u", SHATHEL_ENVPACKAGE_USER.toString(),
//        "--timeout=160",
//        "--private-key=${SHATHEL_ENVPACKAGE_KEY_DIR}/id_rsa".toString(),
//        "--inventory-file=${SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY}".toString(),
//        "--extra-vars", ansibleExtraVars.toString(),
//        "${SHATHEL_ENVPACKAGE_WORKING_DIR}/playbook.yml".toString())
//
////prepare ssh keys for docker
//def hosts = Inventory.getHosts(new File(SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY))
//def cm = new CertificateManager(new File(SHATHEL_ENVPACKAGE_CERTS_DIR), masterPassword, SHATHEL_ENV_SOLUTION_NAME)
//cm.clientCerts
//hosts.each {
//    if (cm.getKeyAndCert(it.shathel_name).isEmpty()) {
//        exec("ssh-keygen", [:]).executeForOutput("-f /home/sasol/.ssh/known_hosts -R ${it.public_ip}")
//        cm.generateKeyAndCert(
//                it.shathel_name,
//                [it.shathel_name, it.name, "localhost"],
//                [it.private_ip, it.public_ip, "127.0.0.1"])
//    }
//}
//
////invoke swarm
//exec("ansible-playbook", ansibleEnvs).executeForOutput(null, workingDir, [:],
//        "-u", SHATHEL_ENVPACKAGE_USER.toString(),
//        "--timeout=160",
//        "--private-key=${SHATHEL_ENVPACKAGE_KEY_DIR}/id_rsa".toString(),
//        "--inventory-file=${SHATHEL_ENVPACKAGE_ANSIBLE_INVENTORY}".toString(),
//        "--extra-vars", ansibleExtraVars.toString(),
//        "${SHATHEL_ENVPACKAGE_WORKING_DIR}/../common/swarmize.yml".toString())

def exec(String command, Map<String, String> environment = [:]) {
    def LOGGER = org.slf4j.LoggerFactory.getLogger(Object.class)
    new ExecWrapper(LOGGER, command, environment)
}

def getClient(address) {
    def ret = new RESTClient(address)
    ret.handler['401'] = ret.handler.get(Status.SUCCESS)
    ret.handler['404'] = ret.handler.get(Status.SUCCESS)
    ret
}