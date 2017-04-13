#!/usr/bin/env groovy
@Grab('ch.qos.logback:logback-classic:1.1.7')
def root = new File("./.shathel-dir/deleteme");
root.mkdirs()
def cm = new CertificateManager(root, "MyPassword".bytes, "shathel-tmp")


println cm.rootCaKey
println cm.rootCaCert
println cm.clientCerts
println cm.generateKeyAndCert("xxx", ["aa.xxx"], ["1.1.1.1"])