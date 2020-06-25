#!/usr/bin/env bash

host=kac-proj-013

IPAHOST=kac-adm-001.kac.sblokalnet

curl -s --netrc -H "X-Requested-By: ambari" "http://kac-abri-001.kach.sblokalnet:8080/api/v1/clusters/KAC/kerberos_identities?fields=*&format=CSV" | grep $host | grep -v headless > kerberos-$host.csv


./kerberos-create.sh $IPAHOST kerberos-$host.csv hosts > $host-hosts.sh

./kerberos-create.sh $IPAHOST kerberos-$host.csv services > $host-services.sh

./kerberos-create.sh $IPAHOST kerberos-$host.csv keytabs > $host-keytabs.sh

./kerberos-create.sh $IPAHOST kerberos-$host.csv distribute > $host-distribute.sh

echo "ssh root@$host -- rsync -av root@$IPAHOST:/root/cfgmount/keytabs/*.headless.keytab /etc/security/keytabs/" > $host-headless.sh