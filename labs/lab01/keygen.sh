#!/bin/bash

cat .phrase.prv | cardano-address key from-recovery-phrase Shelley > root.xsk

cardano-address key child 1852H/1815H/0H/0/0 < root.xsk > payment.xsk
cardano-address key public --without-chain-code < payment.xsk > payment.xvk

cardano-cli key convert-cardano-address-key --shelley-payment-key \
                                            --signing-key-file payment.xsk \
                                            --out-file payment.skey
cardano-cli key verification-key --signing-key-file payment.skey \
                                 --verification-key-file payment.vkey                                           

cardano-address key child 1852H/1815H/0H/2/0    < root.xsk > stake.xsk
cardano-address key public --without-chain-code < stake.xsk > stake.xvk
cardano-cli key convert-cardano-address-key --shelley-payment-key \
                                            --signing-key-file stake.xsk \
                                            --out-file stake.skey
cardano-cli key verification-key --signing-key-file stake.skey \
                                 --verification-key-file stake.vkey
								 

# cardano-address address payment --network-tag testnet < payment.xvk > payment.addr
# cardano-address address stake --network-tag testnet < stake.xvk > stake.addr
# cardano-address key hash < stake.xvk > stake.vkh
# cardano-address address delegation $(cat stake.vkh) < payment.addr > base.addr

cardano-cli conway address build --testnet-magic 2 \
                          --payment-verification-key-file payment.xvk \
                          --stake-verification-key-file stake.xvk \
                          --out-file base.addr

cardano-cli conway stake-address build --testnet-magic 2 \
                                --stake-verification-key-file stake.xvk \
                                --out-file stake.addr

                                