#!/bin/bash

set -eou pipefail

UUID=""

# at the start of the script, clean up any old state files.  if a user wants to
# run multiple copies of this at once, each copy should deposit their own
# ".stopped" file when they are complete, and all should obey the .stop file,
# after it is `touch`ed in the same directory as this script.  placing multiple
# different .stopped files is not supported yet.  need to think of a clean-ish
# way to do this in Bash.
if [ -e .stop ]; then
    echo "rm .stop"
    rm .stop
fi

if [ -e .stopped ]; then
    echo "rm .stopped"
    rm .stopped
fi

# while the .stop file does _not_ exist:
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
    echo "waiting 20 seconds for VM to boot."
    sleep 20

    # get the IP address of that runner 
    echo "RUNNERIP=`tart ip monterey-runner-$UUID`"
    RUNNERIP=`tart ip monterey-runner-$UUID`
    echo "RUNNERIP=$RUNNERIP" >> logs/$UUID.log
    echo $RUNNERIP 

    # get a runner registration token from GitHub
    TOKEN="$(curl -X POST -fsSL -H "Authorization: token $GITHUB_TOKEN" $RUNNER_REGISTRATION_TOKEN_URL | jq -r .token)"

    # ssh into the VM and set up the runner with the acquired token.  This step
    # will wait until the VM exits gracefully after a job is complete.
    ./setup-runner/setup-runner -ip $RUNNERIP -token $TOKEN -url $RUNNER_REGISTRATION_URL >> logs/$UUID.log

    # delete the runner VM we created above.
    tart delete monterey-runner-$UUID >> logs/$UUID.log
done

# if we see the ".stop" file, the `while` loop is broken and then this code is
# run.  This places a .stopped file in the directory of the script to show that
# this wrapper script has exited.
echo "echo \".\" >> .stopped"
echo "." >> .stopped

