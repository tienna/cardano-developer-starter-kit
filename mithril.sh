#!/bin/bash
export CARDANO_NETWORK=preview
export AGGREGATOR_ENDPOINT=https://aggregator.pre-release-preview.api.mithril.network/aggregator
export GENESIS_VERIFICATION_KEY=$(wget -q -O - https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/pre-release-preview/genesis.vkey)
export SNAPSHOT_DIGEST=latest
mithril-client cardano-db download $SNAPSHOT_DIGEST

