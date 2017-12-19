#!/usr/bin/env bash
# Use this file to create local keytabs for ssh login
# Usage: ./create_kac_keytabs "PASSWORD" [username] [server]

dpkg -s sshpass &>/dev/null || sudo apt install -y sshpass

#set -x

PASSWORD="$1"
KACUSER="${2:-$USER}"

project_from_username="$(echo $KACUSER| grep -o '[0-9]\+')"
PROJECT="${project_from_username:-000}"

SERVER="${3:-kac-proj-$PROJECT.kac.sblokalnet}"

sshpass -p "${PASSWORD}" ssh -T "${KACUSER}@${SERVER}" > $HOME/.ssh/$KACUSER.keytab <<EOF
	echo -e "${PASSWORD}\n${PASSWORD}\n" |  ipa-getkeytab --server=kac-adm-001.kac.sblokalnet --principal=${KACUSER} --keytab=\$HOME/.ssh/${KACUSER}.keytab --password=${PASSWORD} >/dev/null
	cat \$HOME/.ssh/${KACUSER}.keytab
EOF
