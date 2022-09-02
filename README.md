# macos-vm-controller

Uses `tart` inside a `while` loop to create MacOS VMs, set them up with GitHub
Actions, run the job, destroy the VM, and repeat.

Requires that a template VM be prepared.  Here's how to do that:

1. `tart create macos-12.5.1-bare --from-ipsw=latest --disk-size=30`
1. Go through initial setup, creating the user `admin` with the password `admin`.
1. Change the following settings:
    1. Preferences -> Security & Privacy -> General -> uncheck first two
       options. 
    1. Preferences -> Users & Groups -> Login Options -> Automatic login ->
       admin 
    1. Allow SSH. General -> Sharing -> Remote Login
    1. Preferences -> Energy Saver -> Check "Prevent your Mac from automatically 
       sleeping"
    1. In a terminal, `sudo visudo` and add this line under the line starting
       with `%admin`: `admin ALL=(ALL) NOPASSWD:ALL`
    1. Shutdown the VM.
    1. (Optional, but recommended) Disable SIP: `tart run --recovery macos-12.5.1-bare` ->
       Options -> Utilities menu -> Terminal -> `csrutil disable`. Shutdown
       again via `shutdown -h now`.
1. Tell Packer to use one of the templates to build the image.
    1. `packer init templates/base.pkr.hcl`
    2. `packer build templates/base.pkr.hcl`
    1. `packer build templates/xcode.pkr.hcl` (or whatever template(s) you
       create.)
    
This isn't super complicated, just poke around with the parts of this and see
what you can make it do, I guess.