#!/bin/bash

set -eou pipefail

UUID=""

if [ -e .stopped ]; then
    echo "rm .stopped"
    rm .stopped
fi

while [ ! -e .stop ]; do 
    # come up with a unique suffix
    UUID=`uuidgen | tr "[A-Z]" "[a-z]"`
    
    echo "UUID: $UUID"

    # clone the runner VM to a VM named with the new suffix
    echo "tart clone monterey-runner monterey-runner-$UUID"
    tart clone monterey-runner monterey-runner-$UUID

    # launch that VM
    echo "tart run monterey-runner-$UUID & >> logs/$UUID.log"
    tart run monterey-runner-$UUID & >> logs/$UUID.log

    # wait for the machine to boot
    echo "sleep 20 # waiting for VM to boot."
    sleep 20

    echo "RUNNERIP=`tart ip monterey-runner-$UUID`"
    RUNNERIP=`tart ip monterey-runner-$UUID`
    echo "RUNNERIP=$RUNNERIP" >> logs/$UUID.log
    echo $RUNNERIP 

    TOKEN="$(curl -X POST -fsSL -H "Authorization: token $GITHUB_TOKEN" $RUNNER_REGISTRATION_TOKEN_URL | jq -r .token)"

    ./setup-runner/setup-runner -ip $RUNNERIP -token $TOKEN -url $RUNNER_REGISTRATION_URL >> logs/$UUID.log

    tart delete monterey-runner-$UUID >> logs/$UUID.log
done

echo "touch .stopped"
touch .stopped

echo "rm .stop"
rm .stop
