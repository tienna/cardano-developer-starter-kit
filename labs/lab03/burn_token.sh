#================= Burn token vừa tạo=============
#1- Thiết lập biến môi trường
testnet="--testnet-magic 2"
tokenname_01=$(echo -n "HN_01" | xxd -ps | tr -d '\n')
tokenamount_01="100000000"
output_01="2000000"

address=$(cat base.addr)
address_SKEY="payment.skey"
#1-Truy vấn token nằm ở UTXO nào
cardano-cli query utxo $testnet --address $address 

#2- cập nhật biến môi trường


txhash_01="4d54c5a15f89bcfda3e1981e58a9fdaa49e74dc9d6a01f429fa93130f9d49665"
txix_01="1"
burnoutput="1400000"

#3-Tạo giao dịch
cardano-cli conway transaction build \
 --testnet-magic 2\
 --tx-in $txhash_01#$txix_01\
 --tx-in a56188031a8e6785563fb94c72b2a64cab07beef41d58b6eaa0570c574176632#0\
 --tx-out $address+$burnoutput\
 --mint="-100000000 $policyid_01.$tokenname_01"\
 --minting-script-file policy/policy_01.script \
 --change-address $address \
 --witness-override 2\
 --out-file burning_token.raw

#4-Ký giao dịch
cardano-cli conway transaction sign  $testnet \
--signing-key-file $address_SKEY \
--signing-key-file policy/policy_01.skey  \
--tx-body-file burning_token.raw \
--out-file burning_token.signed

#5-Gửi giao dịch

cardano-cli conway transaction submit $testnet --tx-file burning_token.signed