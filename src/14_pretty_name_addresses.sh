#!/usr/bin/env bash

trap "exit" INT TERM ERR
trap "kill 0" EXIT

# rebuild the distribution
npm run build

# todo, uncomment this
./cleanslate.sh

# Start the node.
NODE1="test"
NODE1_PORT=3000
NODE1_URL="http://localhost:${NODE1_PORT}"

node ../dist/final.js --port=${NODE1_PORT} --id=${NODE1} &

sleep 2

# adding 2 addresses
echo -e && read -n 1 -s -r -p "Adding 2 addresses that will serve as receiver and sender. Press any key to continue..." && echo -e

curl -X PUT -H "Content-Type: application/json" -d '{
 "prettyName": "ohads-personal"
}' "${NODE1_URL}/address" -w "\n"

curl -X PUT -H "Content-Type: application/json" -d '{
 "prettyName": "ohads-business"
}' "${NODE1_URL}/address" -w "\n"


# Submit 2 transactions to the first node.
echo -e && read -n 1 -s -r -p "Submitting 2 valid transactions. Press any key to continue..." && echo -e

curl -X POST -H "Content-Type: application/json" -d '{
 "senderPrettyName": "ohads-personal",
 "recipientPrettyName": "ohads-business",
 "value": "100"
}' "${NODE1_URL}/transactions" -w "\n"

curl -X POST -H "Content-Type: application/json" -d '{
 "senderPrettyName": "ohads-business",
 "recipientPrettyName": "ohads-personal",
 "value": "50"
}' "${NODE1_URL}/transactions" -w "\n"


# now adding 2 not valid transaction, expecting an error
 echo -e && read -n 1 -s -r -p "Submitting 2 NON valid transactions, expecting errors. Press any key to continue..." && echo -e

curl -X POST -H "Content-Type: application/json" -d '{
 "senderPrettyName": "fake-address",
 "recipientPrettyName": "ohads-business",
 "value": "100"
}' "${NODE1_URL}/transactions" -w "\n"

curl -X POST -H "Content-Type: application/json" -d '{
 "senderPrettyName": "ohads-business",
 "recipientPrettyName": "fake-address",
 "value": "50"
}' "${NODE1_URL}/transactions" -w "\n"



# Mine 1 block.
echo -e && read -n 1 -s -r -p "Mining blocks. Press any key to continue..." && echo -e

curl -X POST -H "Content-Type: application/json" "${NODE1_URL}/blocks/mine" -w "\n"


echo 'done. happy.'