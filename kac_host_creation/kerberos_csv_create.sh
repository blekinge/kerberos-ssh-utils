#!/usr/bin/env bash

CLUSTER_NAME=${1:-KAC}
MASTER_NAME=${2:-kac-abri-001.kac.sblokalnet}

function get(){
    local path="$1"
    curl -s -H "X-Requested-By: ambari" -X GET --netrc "http://$MASTER_NAME:8080/api/v1/$path"
}

get "clusters/$CLUSTER_NAME/kerberos_identities?fields=*&format=csv"
