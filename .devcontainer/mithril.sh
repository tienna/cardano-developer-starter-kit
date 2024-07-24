export CARDANO_NETWORK=preview
export AGGREGATOR_ENDPOINT=https://aggregator.pre-release-preview.api.mithril.network/aggregator
export GENESIS_VERIFICATION_KEY=$(wget -q -O - https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/pre-release-preview/genesis.vkey)
export SNAPSHOT_DIGEST=latest
mithril-client cardano-db download $SNAPSHOT_DIGEST
nohup cardano-node run --config /opt/cardano/config/preview/config.json --database-path "$(pwd)/data/testnet/$SNAPSHOT_DIGEST/db" --socket-path /opt/cardano/config/preview/db/node.socket --host-addr 0.0.0.0 --port 3001 --topology /opt/cardano/config/preview/topology.json >/dev/null 2>&1
