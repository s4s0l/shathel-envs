#
ssh  -f -i ./.shathel-dir/settings/key/id_rsa -M -S ./.shathel-dir/tmp/control1 -l ubuntu -L 127.0.0.1:3333:42.42.42.2:2376 -N 42.42.42.2

