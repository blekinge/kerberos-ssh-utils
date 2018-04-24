#!/usr/bin/env bash

set -e
set -x

hostname | grep kac-abri-001 || >&2 echo 'must be executed on host kac-abri-001' && exit 1

USERNAME="$1"
[ -n ${USERNAME} ] || >&2 echo 'Please use params USERNAME PROJECT' &&  exit 1
PROJECT="$2"
[ -n ${PROJECT} ] || >&2 echo 'Please use params USERNAME PROJECT' && exit 1

sudo -i <<EOF
kinit -kt /etc/security/keytabs/hdfs.headless.keytab hdfs
hdfs dfs -mkdir /user/${USERNAME}
hdfs dfs -chown ${USERNAME}:${USERNAME} /user/${USERNAME}
EOF

grep ${PROJECT} /etc/ambari-server/ambari-groups.csv || echo -n ",$PROJECT" >> /etc/ambari-server/ambari-groups.csv
sudo ambari-server sync-ldap --groups=/etc/ambari-server/ambari-groups.csv