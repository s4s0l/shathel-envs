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


def token = env['SHATHEL_ENV_DO_TOKEN']
def baseImageName = env['SHATHEL_ENV_DO_IMAGE'] == null ? "ubuntu-16-04-x64" : env['SHATHEL_ENV_DO_IMAGE']
def imageName = ("SHT-" + baseImageName)
env['SHATHEL_ENVPACKAGE_SNAP_NAME'] = imageName
def getParams(String token) {
    [
            contentType: ContentType.JSON,
            headers    : [Authorization: "Bearer $token"],
            path       : '/v2/snapshots',
            query      : [page: 1, per_page: 10, resource_type: "droplet"],
    ]}
HttpResponseDecorator result = getClient("https://api.digitalocean.com").get(getParams(token))
assert result.status == 200
def ids = result.data.snapshots.findAll {
    it.name.equalsIgnoreCase(imageName)
}.collect { it.id }

if (ids.isEmpty()) {
    def x = processor.run("packer", "APPLY", "./packer-ubuntu-shathel.json", env)
    assert x.retcode == 0
    for (int i = 0; i < 10; i++) {
        result = getClient("https://api.digitalocean.com").get(getParams(token))
        assert result.status == 200
        ids = result.data.snapshots.findAll {
            it.name.equalsIgnoreCase(imageName)
        }.collect { it.id }
        if (!ids.isEmpty()) {
            break
        } else {

            Thread.sleep(1000)
        }
    }
}

println("Image id found:" + ids.head())

env['SHATHEL_ENVPACKAGE_IMAGE_ID'] = ids.head()


def getClient(address) {
    def ret = new RESTClient(address)
    ret.handler['401'] = ret.handler.get(Status.SUCCESS)
    ret.handler['404'] = ret.handler.get(Status.SUCCESS)
    ret
}
