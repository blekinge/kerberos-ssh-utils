#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f $BASH_SOURCE[0]))

chmod a+x $SCRIPT_DIR/*.sh
#scp $SCRIPT_DIR/create_kac_user.sh $SCRIPT_DIR/finish_create_user.sh abrsadm@kac-abri-001:bin/

scp $SCRIPT_DIR/finish_create_user.sh root@kac-abri-001:/usr/local/bin/

scp $SCRIPT_DIR/create_kac_user.sh root@kac-adm-001:/usr/local/bin/