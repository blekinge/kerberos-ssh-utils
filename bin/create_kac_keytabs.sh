#!/usr/bin/env bash
# Use this file to create local keytabs for ssh login
# Usage: ./create_kac_keytabs abr "PASSWORD"

sudo apt install -y sshpass

KACUSER="$1"
PASSWORD="$2"
sshpass -p $PASSWORD ssh $KACUSER@kac-adm-001.kac.sblokalnet > $HOME/.ssh/$KACUSER.keytab <<EOF
	echo -e "$PASSWORD\n$PASSWORD\n" |  ipa-getkeytab --server=kac-adm-001.kac.sblokalnet --principal=$KACUSER --keytab=\$HOME/.ssh/$KACUSER.keytab --password=$PASSWORD >/dev/null
	cat \$HOME/.ssh/$KACUSER.keytab
EOF



