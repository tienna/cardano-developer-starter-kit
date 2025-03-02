#1- Thiết lập biến môi trường
testnet="--testnet-magic 2"
tokenname=$(echo -n "CBCA1" | xxd -ps | tr -d '\n')
tokenamount="10000000"
output="2000000"

address=$(cat base.addr)
address_SKEY="payment.skey"
cardano-cli query utxo --address $address $testnet

txhash="e5b7710f8dc10cc4b9d4bec60b7cb2d528ae40c24f0e9fb053a92c63c88b482a"
txix="0"

#2-Tạo thư mục và Policy
mkdir policy
cardano-cli address key-gen \
    --verification-key-file policy/policy.vkey \
    --signing-key-file policy/policy.skey

touch policy/policy.script && echo "" > policy/policy.script

echo "{" >> policy/policy.script
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script
echo "  \"type\": \"sig\"" >> policy/policy.script
echo "}" >> policy/policy.script

cardano-cli conway transaction policyid --script-file ./policy/policy.script > policy/policyID
policyid=$(cat policy/policyID)

#4-Tạo giao dịch
cardano-cli conway transaction build \
$testnet \
--tx-in $txhash#$txix \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--mint "$tokenamount $policyid.$tokenname" \
--mint-script-file policy/policy.script \
--change-address $address \
--out-file mint-nft.raw


#5-Tạo ký giao dịch
cardano-cli conway transaction sign  $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file policy/policy.skey  \
--tx-body-file mint-nft.raw \
--out-file mint-nft.signed

#5-Gửi giao dịch 

cardano-cli conway transaction submit $testnet --tx-file mint-nft.signed 