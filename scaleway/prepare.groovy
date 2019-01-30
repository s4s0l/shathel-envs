#!/usr/bin/env groovy
// Scaleway does not support packer build
// TODO add support for it when it comes
def size = env['SHATHEL_ENV_SCALEWAY_SIZE']

def volumeSizeMapping = [
        'START1-XS' : '0',
        'START1-S' : '0',
        'START1-M' : '50',
        'START1-L' : '150',
        'C2S' : '0',
        'C2M' : '0',
        'C2L' : '350',
        'X64-15GB' : '150',
        'X64-30GB' : '350',
        'X64-60GB' : '950',
]

if(size.startsWith('X64')) {
    env['SHATHEL_ENVPACKAGE_VOLUME_TYPE'] = 'd_ssd'
}
env['SHATHEL_ENVPACKAGE_VOLUME_SIZE'] = volumeSizeMapping[size]

println env
