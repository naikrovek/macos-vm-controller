#!/bin/bash

packer init templates/
packer build 0-vanilla-monterey.pkr.hcl
packer build 1-disable-sip.pkr.hcl
packer build 2-base.pkr.hcl
packer build 3-xcode.pkr.hcl
