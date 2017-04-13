class Inventory {
    static def getHosts(File f) {
        def ret = []
        def hostsMatch = f.text =~ /([^\s]+)\s+((?:(?:(?:private_ip|public_ip|shathel_name)=[^\s]+).*){3})/
        while (hostsMatch.find()) {
            def host = [name: hostsMatch.group(1)]
            def allAtts = hostsMatch.group(2)
            def attMatch = allAtts =~ /(private_ip|public_ip|shathel_name)+\s*=\s*([^\s]+)/
            while (attMatch.find()) {
                host << [(attMatch.group(1)): attMatch.group(2)]
            }
            ret << host
        }
        ret
    }

    static downloadFile(File localFile, String remoteUrl) {
        localFile.withOutputStream { out ->
            new URL(remoteUrl).withInputStream { from -> out << from; }
        }

    }
}