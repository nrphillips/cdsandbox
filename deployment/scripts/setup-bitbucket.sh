#!/usr/bin/env bash

BITBUCKET_USERNAME=nrp0110@gmail.com
# see https://bitbucket.org/account/user/{username}/app-passwords
BITBUCKET_PASSWORD=<app password goes here>
BITBUCKET_USERNAME_PASSWORD_FILE=~/bitbucket.pwd
BITBUCKET_ACCOUNT_NAME=nicks-bitbucket-account

echo ${BITBUCKET_USERNAME}:${BITBUCKET_PASSWORD} > ${BITBUCKET_USERNAME_PASSWORD_FILE}

hal config features edit --artifacts true

#hal config artifact http enable
#hal config artifact http account add my-http-account \
#    --username-password-file $USERNAME_PASSWORD_FILE

hal config artifact bitbucket enable
hal config artifact bitbucket account add ${BITBUCKET_ACCOUNT_NAME} \
    --username-password-file ${BITBUCKET_USERNAME_PASSWORD_FILE}

#curl -u ${BITBUCKET_USERNAME} https://api.Bitbucket.org/2.0/repositories/nrphx/cdsandbox
#curl -u ${BITBUCKET_USERNAME} https://api.Bitbucket.org/2.0/repositories/nrphx/cdsandbox/src/master/
#curl -u ${BITBUCKET_USERNAME} https://api.Bitbucket.org/2.0/repositories/nrphx/cdsandbox/src/500a4557e193aaff8f07221536b75bb40f514c9b/test-pipline.yaml
#curl -u nicholas_phillips@yahoo.com:nedis-logis https://api.Bitbucket.org/2.0/repositories/nrphx/cdsandbox
