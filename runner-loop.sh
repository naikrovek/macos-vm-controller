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

    TOKEN="$(curl -X POST -fsSL -H "Authorization: token $GITHUB_TOKEN" $RUNNER_REGISTRATION_TOKEN_URL | jq -r .token)"

    ./setup-runner/setup-runner --address $RUNNERIP --token $TOKEN --url $RUNNER_REGISTRATION_URL

    tart delete monterey-runner-$UUID
done

echo "touch .stopped"
touch .stopped

echo "rm .stop"
rm .stop
