import java.nio.file.Files

/**
 * @author Marcin Wielgus
 */


class CertificateManager {
    private final File certificateHome
    private final byte[] passPhrase
    private final String caCommonName

    CertificateManager(File certificateHome, byte[] passPhrase, String caCommonName) {
        this.certificateHome = certificateHome
        this.passPhrase = passPhrase
        this.caCommonName = caCommonName
    }

    private ExecWrapper getWrapper() {
        return new ExecWrapper(org.slf4j.LoggerFactory.getLogger(CertificateManager), "openssl")
    }

    File getRootCaKey() {
        def rootCaFile = new File(certificateHome, "ca-key.pem")
        if (!rootCaFile.exists()) {
            wrapper.executeForOutput(passPhrase, certificateHome, [:], "genrsa -aes256 -passout stdin -out ${rootCaFile.absolutePath} 4096")
        }
        return rootCaFile
    }

    File getRootCaCert() {
        def rootCaCertFile = new File(certificateHome, "ca-cert.pem")
        if (!rootCaCertFile.exists()) {
            wrapper.executeForOutput(passPhrase, certificateHome, [:],
                    "req -new -x509 -days 365 -key ${getRootCaKey().absolutePath} -sha256 -out ${rootCaCertFile.absolutePath} -passin stdin -subj /CN=${caCommonName}");
        }
        return rootCaCertFile
    }

    Map<String, File> getKeyAndCert(String tag) {
        File serverDir = new File(certificateHome, tag)

        File serverKey = new File(serverDir, "server-key.pem")
        File serverCert = new File(serverDir, "server-cert.pem")
        return serverKey.exists() && serverCert.exists() ? [
                key : serverKey,
                cert: serverCert
        ] : [:]
    }


    Map<String, File> getClientCerts() {
        File serverDir = new File(certificateHome, "client")
        File serverKey = new File(serverDir, "key.pem")
        File serverCert = new File(serverDir, "cert.pem")
        File caCert = new File(serverDir, "ca.pem")
        return serverKey.exists() && serverCert.exists() ? [
                key : serverKey,
                cert: serverCert,
                ca  : caCert,
        ] : generateClientKeyAndCert()
    }

    Map<String, File> generateClientKeyAndCert() {
        List<String> extendsdKeyUsage = [
                "clientAuth",
        ]
        File clientDir = new File(certificateHome, "client")
        clientDir.mkdirs()
        File clientKey = new File(clientDir, "key.pem")
        wrapper.executeForOutput(null, certificateHome, [:],
                "genrsa -out ${clientKey.absolutePath} 4096")
        File serverCsr = new File(clientDir, "client.csr")
        wrapper.executeForOutput(null, certificateHome, [:],
                "req -subj /CN=client -sha256 -new -key ${clientKey.absolutePath} -out ${serverCsr.absolutePath}")

        def extFile = new File(clientDir, "extfile.cfg")

        extFile.text = """
basicConstraints = critical, CA:true
keyUsage=critical, digitalSignature,keyEncipherment,keyAgreement,dataEncipherment,keyCertSign
extendedKeyUsage=${extendsdKeyUsage.join(",")}
"""
        File serverCert = new File(clientDir, "cert.pem")

        wrapper.executeForOutput(passPhrase, certificateHome, [:],
                "x509 -req -days 365 -sha256 -in ${serverCsr.absolutePath} " +
                        "-CA ${rootCaCert.absolutePath} " +
                        "-CAkey ${rootCaKey.absolutePath} " +
                        "-CAcreateserial -out ${serverCert.absolutePath} " +
                        "-extfile ${extFile.absolutePath} -passin stdin ")

        //copy ca cert to match convention of DOCKER_CERT_PATH
        File caCert = new File(clientDir, "ca.pem")
        Files.copy(rootCaCert.toPath(), caCert.toPath())

        return [
                key : clientKey,
                cert: serverCert,
                ca  : caCert
        ]
    }


    Map<String, File> generateKeyAndCert(String tag, String commonName = tag,
                                         List<String> dns,
                                         List<String> ips,
                                         List<String> extendsdKeyUsage = [
                                                 "critical",
                                                 "serverAuth",
                                                 "clientAuth",
                                                 "codeSigning"
                                         ]) {
        File serverDir = new File(certificateHome, tag)
        serverDir.mkdirs()
        File serverKey = new File(serverDir, "server-key.pem")
        wrapper.executeForOutput(null, certificateHome, [:],
                "genrsa -out ${serverKey.absolutePath} 4096")
        File serverCsr = new File(serverDir, "server.csr")
        wrapper.executeForOutput(null, certificateHome, [:],
                "req -subj /CN=$commonName -sha256 -new -key ${serverKey.absolutePath} -out ${serverCsr.absolutePath}")

        def extFile = new File(serverDir, "extfile.cfg")

        extFile.text = """
basicConstraints = critical, CA:true
keyUsage=critical, digitalSignature,keyEncipherment,keyAgreement,dataEncipherment,keyCertSign
extendedKeyUsage=${extendsdKeyUsage.join(",")}
subjectAltName=${(ips.collect { "IP:$it" } + dns.collect { "DNS:$it" }).join(",")}
"""
        File serverCert = new File(serverDir, "server-cert.pem")

        wrapper.executeForOutput(passPhrase, certificateHome, [:],
                "x509 -req -days 365 -sha256 -in ${serverCsr.absolutePath} " +
                        "-CA ${rootCaCert.absolutePath} " +
                        "-CAkey ${rootCaKey.absolutePath} " +
                        "-CAcreateserial -out ${serverCert.absolutePath} " +
                        "-extfile ${extFile.absolutePath} -passin stdin ")

        return [
                key : serverKey,
                cert: serverCert
        ]
    }


}