#!/usr/bin/env bash

set -euxo pipefail

SB="${HOME}/sandbox/sandbox"
GOAL="${SB} goal"

ACCOUNTS_PK=($(${GOAL} account list | awk '{print $3}' | tr -d '\r'))

CREATOR=${ACCOUNTS_PK[0]}
USER1=${ACCOUNTS_PK[1]}
USER2=${ACCOUNTS_PK[2]}

# Copy contracts to sandbox
${SB} copyTo approval.teal
${SB} copyTo clear.teal

APPID=$(${GOAL} app create --creator ${CREATOR} \
	--approval-prog approval.teal \
	--clear-prog clear.teal \
	--global-byteslices 0 --global-ints 0 \
	--local-byteslices 0 --local-ints 0 \
	| grep 'Created app with app index' | awk '{print $6}' | tr -d '\r')
echo ${APPID} > .APPID

