#1-Tạo thư mục Merge_UTXO
mkdir Merge_UTXO
#2-Tạo biển môi trường
testnet="--testnet-magic 2"
address=$(cat base.addr)
address_skey="payment.skey"
cardano-cli query utxo --address $address $testnet # kiểm tra các UTXO có trong địa chỉ của bạn

txhash_01="752bbeae095c9a6194b38b5f425dd679b5145ff444412d8fc925ab5d15923d42"
txix_01="0"
txhash_02="752bbeae095c9a6194b38b5f425dd679b5145ff444412d8fc925ab5d15923d42"
txix_02="1"
txhash_03="a3e986f09af8b7e0561eb84b63726745baf5263e926c0eeecf980cb42d4e7ecf"
txix_03="1"
txhash_04="da941a7f1359b24edee022730056273bd80e36b59520c203f6d332bccc4355a4"
txix_04="1"
txhash_05="da941a7f1359b24edee022730056273bd80e36b59520c203f6d332bccc4355a4"
txix_05="2"
txhash_06="da941a7f1359b24edee022730056273bd80e36b59520c203f6d332bccc4355a4"
txix_06="3"
txhash_07="da941a7f1359b24edee022730056273bd80e36b59520c203f6d332bccc4355a4"
txix_07="4"
txhash_08="da941a7f1359b24edee022730056273bd80e36b59520c203f6d332bccc4355a4"
txix_08="5"

#3-Tạo transaction draft để ước tính phí:
cardano-cli conway transaction build \
$testnet \
--tx-in $txhash_01#$txix_01 \
--tx-in $txhash_02#$txix_02 \
--tx-in $txhash_03#$txix_03 \
--tx-in $txhash_04#$txix_04 \
--tx-in $txhash_05#$txix_05 \
--tx-in $txhash_06#$txix_06 \
--tx-in $txhash_07#$txix_07 \
--tx-in $txhash_08#$txix_08 \
--tx-out $address+50000000000 \
--change-address $address \
--out-file estimate.raw

#3-Tính phí:
cardano-cli conway query protocol-parameters \
  --testnet-magic 2 \
  --out-file protocol.json

cardano-cli conway transaction calculate-min-fee \
  --tx-body-file estimate.raw \
  --tx-in-count 8 \
  --tx-out-count 1 \
  --witness-count 1 \
  --protocol-params-file protocol.json

#4-Xác định giá trị chính xác cho --tx-out
output=$(expr 1400000 + 49998230630 + 1132906 + 337001486 + 168598762 + 84299381 + 84299381 + 5000000 - 215089)

#5-Cập nhận lệnh transaction
cardano-cli conway transaction build \
$testnet \
--tx-in $txhash_01#$txix_01 \
--tx-in $txhash_02#$txix_02 \
--tx-in $txhash_03#$txix_03 \
--tx-in $txhash_04#$txix_04 \
--tx-in $txhash_05#$txix_05 \
--tx-in $txhash_06#$txix_06 \
--tx-in $txhash_07#$txix_07 \
--tx-in $txhash_08#$txix_08 \
--tx-out $address+$output \
--change-address $address \
--out-file consolidate-utxo.raw

#6-Tạo ký giao dịch
cardano-cli conway transaction sign  $testnet \
--signing-key-file $address_skey \
--tx-body-file consolidate-utxo.raw \
--out-file consolidate-utxo.signed

#7-Gửi giao dịch 

cardano-cli conway transaction submit $testnet --tx-file consolidate-utxo.signed
