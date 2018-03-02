def imageName = env['SHATHEL_ENVPACKAGE_IMAGE_NAME']

processor.run("vagrant", "plugin install vagrant-disksize", "eee", env)

if (!processor.run("vagrant", "box list", "./Vagrantfile-image", env).output.contains(imageName)) {
    processor.run("vagrant", "up", "./Vagrantfile-image", env)
    processor.run("vagrant", "package --output ${env['SHATHEL_ENVPACKAGE_TMP_DIR']}/${imageName}.box", "./Vagrantfile-image", env)
    processor.run("vagrant", "box add --name ${imageName} file://${env['SHATHEL_ENVPACKAGE_TMP_DIR']}/${imageName}.box", "./Vagrantfile-image", env)
    processor.run("vagrant", "destroy -f", "./Vagrantfile-image", env)
    new File("${env['SHATHEL_ENVPACKAGE_TMP_DIR']}/${imageName}.box").delete()
}
