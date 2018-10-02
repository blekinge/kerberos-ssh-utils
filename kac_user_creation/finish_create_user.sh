#!/usr/bin/env bash

trap '[ "$?" -ne 77 ] || exit 1' ERR
set -e
set -x



echo "Validating this host $(hostname)"
hostname | grep kac-abri-001 || (>&2 echo 'must be executed on host kac-abri-001' && exit 77)

USAGE='Please use params USERNAME PROJECT'
echo "Validating parameters $@"
USERNAME="$1"
[ -n ${USERNAME} ] || (>&2 echo "$USAGE" &&  exit 77)
PROJECT="$2"
[ -n ${PROJECT} ] || (>&2 echo "$USAGE" &&  exit 77)


sudo -i <<EOF
echo "Get Kerberos ticket for the HDFS user"
kinit -kt "/etc/security/keytabs/hdfs.headless.keytab" -- hdfs
echo "Reload sss_cache to ensure that ${USERNAME} is known"
sss_cache -u "${USERNAME}"
echo "Creating HDFS homedir hdfs:///user/${USERNAME}"
hdfs dfs -mkdir -- "/user/${USERNAME}"
hdfs dfs -chown -- "${USERNAME}:${USERNAME}" "/user/${USERNAME}"
EOF

echo "Syncing all groups (to sync $PROJECT) with Ambari. This will require Ambari *sadm Login"
grep "${PROJECT}" /etc/ambari-server/ambari-groups.csv || echo -n ",$PROJECT" >> /etc/ambari-server/ambari-groups.csv
sudo ambari-server sync-ldap --groups=/etc/ambari-server/ambari-groups.csv