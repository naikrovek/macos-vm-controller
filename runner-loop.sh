#!/bin/bash

set -eou pipefail

UUID=""

if [ -f ".stopped" ]; do 
    echo "rm .stopped"
    rm .stopped
done

while [ ! -f ".stop" ]; do
    # come up with a unique suffix
    UUID=`uuidgen | tr "[A-Z]" "[a-z]"`
    
    echo "UUID: $UUID"

    # clone the runner VM to a VM named with the new suffix
    echo "tart clone monterey-runner monterey-runner-$UUID"
    tart clone monterey-runner monterey-runner-$UUID

    # launch that VM
    echo "tart run monterey-runner-$UUID &"
    tart run monterey-runner-$UUID &

    # wait for the machine to boot
    echo "sleep 20"
    sleep 20

    echo "RUNNERIP=`tart ip monterey-runner-$UUID`"
    RUNNERIP=`tart ip monterey-runner-$UUID`
    echo $RUNNERIP

    TOKEN="$(curl -X POST -fsSL -h "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/naikrovek/macos-vm-controller/actions/runners/registration-token | jq -r .token)"

    ./setup-runner/setup-runner --address $RUNNERIP --token $TOKEN

    tart delete monterey-runner-$UUID
done

echo "touch .stopped"
touch .stopped

echo "rm .stop"
rm .stop

# notes:
# uuidgen | tr "[A-Z]" "[a-z]"
# ps | grep "tart " | grep -v grep | awk '{ print $6 }'

# in a loop:
# generate a UUID # uuidgen | tr "[A-Z]" "[a-z]"
# clone the `-runner` tart vm with the UUID attached to the name
# start that VM
# get the VM IP address, then:
# run the `setup-runner` go program which does the following:
#   connects to the VM via SSH, and 
#   configures the runner to be ephemeral
#   starts the runner via ./run.sh 
#   sudo shutdown -h now
# the Go program exits, and the shell script resumes:
# destroy the VM
# repeat the loop