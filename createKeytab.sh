#!/usr/bin/env bash

mkdir -p $HOME/.kerberos/
ipa-getkeytab --principal ${USER} --server=kac-adm-001.kach.sblokalnet --keytab=$HOME/.kerberos/${USER}.keytab -P
chmod go-rwx $HOME/.kerberos/ -R
