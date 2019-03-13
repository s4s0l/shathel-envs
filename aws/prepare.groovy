#!/usr/bin/env groovy

if(env['SHATHEL_ENV_AWS_SOURCE_AMI'] == null){
    env['SHATHEL_ENV_AWS_SOURCE_AMI'] = 'ami-05af84768964d3dc0'
}


def imageName = ("SHT-" + env['SHATHEL_ENV_AWS_SOURCE_AMI'])
env['SHATHEL_ENVPACKAGE_SNAP_NAME'] = imageName

def ami = null
def x = processor.run("packer", "APPLY", "./packer-ubuntu-shathel.json", env)
if (x.retcode == 1) {
    def amiMatch = x.output =~ /name conflicts with an existing AMI: (ami-[^\s]+)/
    if (amiMatch.find()) {
        ami = amiMatch.group(1)
    }
} else {
    def amiMatch = x.output.readLines().last() =~ /[^\s]+: (ami-[^\s]+)/
    if (amiMatch.find()) {
        ami = amiMatch.group(1)
    }
}
if (ami == null) {
    throw RuntimeException("Unexpected packer output, no ami present? : ${x.output}")
}
env['SHATHEL_ENVPACKAGE_IMAGE_ID'] = ami
