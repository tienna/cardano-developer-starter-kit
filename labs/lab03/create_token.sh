#1- Thiết lập biến môi trường
testnet="--testnet-magic 2"
tokenname_02=$(echo -n "PUMP" | xxd -ps | tr -d '\n')
tokenamount_02="10000000000"
output_02="2000000"

address=$(cat base.addr)
address_SKEY="payment.skey"
cardano-cli query utxo --address $address $testnet

txhash_01="f9bd883ba27daded255519469defea67d9b0fe222e8dd645c45d80b7bcda28d1"
txix_02="1"

#2-Tạo thư mục và Policy
mkdir policy
cardano-cli address key-gen \
    --verification-key-file policy/policy_01.vkey \
    --signing-key-file policy/policy_01.skey

touch policy/policy_01.script && echo "" > policy/policy_01.script

echo "{" >> policy/policy_01.script
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy_01.vkey)\"," >> policy/policy_01.script
echo "  \"type\": \"sig\"" >> policy/policy_01.script
echo "}" >> policy/policy_01.script

cardano-cli conway transaction policyid --script-file ./policy/policy_01.script > policy/policyID_01
policyid_01=$(cat policy/policyID_01)

#4-Tạo giao dịch
cardano-cli conway transaction build \
$testnet \
--tx-in $txhash_01#$txix_01 \
--tx-out $address+$output_01+"$tokenamount_01 $policyid_01.$tokenname_01" \
--mint "$tokenamount_01 $policyid_01.$tokenname_01" \
--mint-script-file policy/policy_01.script \
--change-address $address \
--out-file create-token.raw


#5-Tạo ký giao dịch
cardano-cli conway transaction sign  $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file policy/policy_01.skey  \
--tx-body-file create-token.raw \
--out-file create-token.signed

#5-Gửi giao dịch 

cardano-cli conway transaction submit $testnet --tx-file create-token.signed 