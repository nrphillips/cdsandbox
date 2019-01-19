#!/usr/bin/env bash
## ######################################################################################
## Inital kubernetes cluster setup
## ######################################################################################

source 0-Settings.sh

SPINNAKER_INSTALL_TYPE=kube-v1

if [ $SPINNAKER_INSTALL_TYPE = kube-v2 ]
then {
echo $SPINNAKER_INSTALL_TYPE
echo $SPINNAKER_INSTALL_TYPE-tweriu
} fi
