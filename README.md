# macos-vm-controller

Uses `tart` inside a `while` loop to create a single MacOS VM, set it up with
GitHub Actions, do the work defined in a GHA job, destroy the VM, and repeat,
until a file named `.stop` is placed in the same folder as the shell script.
The running GHA job, or the next to run, will be the last and after the current
VM clone is deleted, the shell script will exit. 

Tart only runs on Apple Silicon, and therefore that is a requirement for this
tool, as well.

## Setting up the VM template

Create your `tart` VMs as described here:  

1. `tart create monterey-vanilla --from-ipsw=latest --disk-size=30`
1. Go through initial setup, creating the user `admin` with the password `admin`.
1. Change the following settings:
    1. Preferences → Security & Privacy → General → uncheck first two
       options. 
    1. Preferences → Users & Groups → Login Options → Automatic login →
       admin 
    1. Allow SSH. General → Sharing → Remote Login
    1. Preferences → Energy Saver → Check "Prevent your Mac from automatically 
       sleeping"
    1. In a terminal, `sudo visudo` and add this line under the line starting
       with `%admin`: `admin ALL=(ALL) NOPASSWD:ALL`
    1. Shutdown the VM.
    1. (Optional, but recommended) Disable SIP: `tart run --recovery monterey-vanilla` →
       Options → Utilities menu → Terminal → `csrutil disable`. Shutdown
       again via `shutdown -h now`.
1. Tell Packer to use one or all of the templates to build the image.
    1. `packer init templates/base.pkr.hcl` (you only need this a single time.)
    1. `packer build templates/base.pkr.hcl`
    1. `packer build templates/xcode.pkr.hcl`
    1. `packer build templates/runner.pkr.hcl`
    
These could be combined into a single template, if you like.  Up to you.  I do
it in stages in case anything breaks, there's less that needs redone as you fix
things. 

Thanks to APFS cloning, you can just clone a virtual machine using `tart clone`,
and the copy will take almost no additional disk space. This way you can have a
"clean" copy of your VM, do whatever you want with a duplicate of it, and then
throw the copy away with `tart delete` and `tart clone` a new clean version if
things break or you want to start over.  Very convenient.  NTFS doesn't have
this.

## Usage

Once your VM base image is created, CD to the root of this repository
and set the environment variables shown here to their correct values for your
situation: 

```
export GITHUB_TOKEN="your_token"
export RUNNER_REGISTRATION_TOKEN_URL="runner registration token URL"
export RUNNER_REGISTRATION_URL="runner registration URL"
```

If not clear, the `RUNNER_REGISTRATION_TOKEN_URL` is the API endpoint which you
use to get a runner registration token, and the `RUNNER_REGISTRATION_TOKEN` is
where you use that token to register the runner.

Run `./runner-loop.sh` in a terminal.



