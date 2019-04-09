Use these scripts to generate the new keytabs for services

First, get the kerberos.csv file from Ambari

```bash
curl -s --netrc -H "X-Requested-By: ambari" "http://kac-abri-001.kach.sblokalnet:8080/api/v1/clusters/KAC/kerberos_identities?fields=*&format=CSV"
```

In this example, we want to set up a new NFS gateway, so lets filter out the relevant lines

```bash
curl -s --netrc -H "X-Requested-By: ambari" "http://kac-abri-001.kach.sblokalnet:8080/api/v1/clusters/KAC/kerberos_identities?fields=*&format=CSV" | grep kac-nfsg-001 | grep -v headless > kerberos.csv
```
We removed all the `headless` lines as these certificates are cluster-wide and thus should not be reissued for a new host. Rather, copy them from an existing host.



Then we must run
```bash
./kerberos-create.sh kac-adm-001.kac.sblokalnet kerberos.csv hosts
```
```
set -x
# Find unique hosts and add them to freeIPA
ipa host-add 'kac-nfsg-001.kach.sblokalnet'
```

Then we must run
```bash
./kerberos-create.sh kac-adm-001.kac.sblokalnet kerberos.csv services
```
```
set -x
# Find unique services and add them to freeIPA
ipa service-add 'hdfs-nfs/kac-nfsg-001.kach.sblokalnet@KAC.SBLOKALNET'
ipa service-add 'HTTP/kac-nfsg-001.kach.sblokalnet@KAC.SBLOKALNET'
```

Then we must run
```bash
./kerberos-create.sh kac-adm-001.kac.sblokalnet kerberos.csv keytabs
```
```
set -x
# Find unique services and add them to freeIPA
ipa service-add 'hdfs-nfs/kac-nfsg-001.kach.sblokalnet@KAC.SBLOKALNET'
ipa service-add 'HTTP/kac-nfsg-001.kach.sblokalnet@KAC.SBLOKALNET'
```
