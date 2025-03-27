testnet="--testnet-magic 2"
address=$(cat base.addr)
address_skey="payment.skey"
cardano-cli query utxo $testnet --address $address

#chỉnh sửa lại giá trị các biến
BOB_ADDR="addr_test1qrpr3fvu6pqcfhhhljudvx6lq3sx6zmphaq560r08ntmhgyt26njmyqh6zwt0vt5qmxqg0tztsj4hlw33pm54rsu6mrqdttspd"
VALUE=10000000
UTXO_IN=2aab375cafbf03f98c3a504522813ae92874716cf4c1a66faea9e8376e587c74#1

# B1. Xây dựng giao dịch (Build Tx)


cardano-cli conway transaction build $testnet \
--tx-in $UTXO_IN \
--tx-out $BOB_ADDR+$VALUE \
--change-address $address \
--metadata-json-file metadata_01.json \
--out-file simple_tx_01.raw


# B2. Ký giao dịch (Sign Tx)

cardano-cli conway transaction sign $testnet \
--signing-key-file $address_skey \
--tx-body-file simple_tx_01.raw \
--out-file simple_tx_01.signed

# B3. Gửi giao dịch (Submit Tx)

cardano-cli conway transaction submit $testnet \
--tx-file simple_tx_01.signed