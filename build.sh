#!/bin/bash

packer init templates/base.pkr.hcl
packer build vanilla-ventura.pkr.hcl
packer build disable-sip.pkr.hcl
packer build base.pkr.hcl
packer build xcode.pkr.hcl
