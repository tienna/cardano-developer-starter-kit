
testnet="--testnet-magic 2"
address=$(cat base.addr)
address_skey="payment.skey"
cardano-cli query utxo $testnet --address $address

#chỉnh sửa lại giá trị các biến
BOB_ADDR="addr_test1qrjgrt0eqjlrn3wkd6m6rpllkzjff0xldchhl8jzwx430tkf4wx2mtkjxk0cqxgsh0t9rrfapzzgs0l4mlvh4uwsqvys3upzzm"
VALUE=100000000
UTXO_IN=e909828f5201633151b882fde26c484cc81f0264ec58323c55783ebe1ed9a73d#0

# B1. Xây dựng giao dịch (Build Tx)


cardano-cli conway transaction build $testnet \
--tx-in $UTXO_IN \
--tx-out $BOB_ADDR+$VALUE \
--change-address $address \
--out-file tx1.raw


# B2. Ký giao dịch (Sign Tx)

cardano-cli conway transaction sign $testnet \
--signing-key-file $address_skey \
--tx-body-file tx1.raw \
--out-file tx1.signed

# B3. Gửi giao dịch (Submit Tx)

cardano-cli conway transaction submit $testnet \
--tx-file tx1.signed

