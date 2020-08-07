#!/usr/bin/env bash

getent group gpuusers | cut -d':' -f4 | sed 's/,/\n/g' | xargs -r -i bash -c "sudo mkdir /data/d1/users/{}; sudo chown {}:{} /data/d1/users/{}"