#!/usr/bin/env bash

set -euxo pipefail

SB="${HOME}/sandbox/sandbox"
GOAL="${SB} goal"

ACCOUNTS_PK=($(${GOAL} account list | awk '{print $3}' | tr -d '\r'))

CREATOR=${ACCOUNTS_PK[0]}
USER1=${ACCOUNTS_PK[1]}
USER2=${ACCOUNTS_PK[2]}

APPID=$(cat .APPID)
APPADDR=$(${GOAL} app info --app-id ${APPID} \
	| grep 'Application account' | awk '{print $3}' | tr -d '\r')

${GOAL} clerk send -f ${CREATOR} -t ${APPADDR} -a 200000

${GOAL} app method --app-id ${APPID} -f ${CREATOR} \
	--method "deploy_app()void" \
	--fee 2000 \
	-o deploy.txn
${GOAL} app method --app-id ${APPID} -f ${CREATOR} \
	--method "call_app()void" \
	--fee 2000 \
	-o call.txn
${GOAL} app method --app-id ${APPID} -f ${CREATOR} \
	--method "delete_app(appl,appl)void" \
	--arg deploy.txn \
	--arg call.txn \
	--fee 2000 \
	-o group.txn

${GOAL} clerk sign -i group.txn -o group.stxn

${GOAL} clerk rawsend -f group.stxn

ROUND=$(${GOAL} node status | grep 'Last committed block' | awk '{print $4}' | tr -d '\r')

curl "localhost:4001/v2/blocks/${ROUND}?pretty" -H "X-Algo-API-Token: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

