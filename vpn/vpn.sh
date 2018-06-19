#!/usr/bin/env bash

ORDER=${1:-show}

nmcli connection "$ORDER" -- "kac-gway-001.kach.sblokalnet"
