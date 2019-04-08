#!/usr/bin/env bash

#https://community.hortonworks.com/articles/104240/automate-the-ambari-ldap-sync.html

set -x

dataAllUsersFromTheseGroups='[{"Event":{"specs":[{"principal_type":"groups","sync_type":"specific","names":"kacusers,admins,subadmins,p000,p002,p003,p005"}]}}]'

dataExistingUsers='[{"Event":{"specs":[{"principal_type":"users","sync_type":"existing"},{"principal_type":"groups","sync_type":"existing"}]}}]'


curl \
-k \
-n \
-H 'X-Requested-By: ambari' \
-X POST \
-d ${dataAllUsersFromTheseGroups} \
http://kac-abri-001.kach.sblokalnet:8080/api/v1/ldap_sync_events

curl \
-k \
-n \
-H 'X-Requested-By: ambari' \
-X POST \
-d ${dataExistingUsers} \
http://kac-abri-001.kach.sblokalnet:8080/api/v1/ldap_sync_events

