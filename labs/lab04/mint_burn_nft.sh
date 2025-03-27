#1-Cài đặt xxd nếu chưa có
apt upgrade
apt update
apt install xxd


#2-Tạo thư mục và Policy
mkdir policy
cardano-cli address key-gen \
    --verification-key-file policy/policy_02.vkey \
    --signing-key-file policy/policy_02.skey
	
touch policy/policy_02.script && echo "" > policy/policy_02.script

echo "{" >> policy/policy_02.script
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy_02.vkey)\"," >> policy/policy_02.script
echo "  \"type\": \"sig\"" >> policy/policy_02.script
echo "}" >> policy/policy_02.script

cardano-cli conway transaction policyid --script-file ./policy/policy_02.script > policy/policyID_02

#3-Tạo biến môi trường
testnet="--testnet-magic 2"
address=$(cat base.addr)
address_SKEY="payment.skey"
cardano-cli query utxo --address $address $testnet

txhash_02="a56188031a8e6785563fb94c72b2a64cab07beef41d58b6eaa0570c574176632"
txix_02="1"
policyid_02=$(cat policy/policyID_02)

realtokenname="SwanLakeEcopark"
tokenname=$(echo -n $realtokenname | xxd -b -ps -c 80 | tr -d '\n')
tokenamount="1"
output="2000000"
ipfs_hash="ipfs://Qmb2KczjiEd5ypTsKMJ2QXswvRohLQdoyqXj88NZNJEPcF"
#ipfs_hash="QmdpcDnQj5u54JZ5ZxQMLXjajZAeAXRqHs7dNGvh7wVhq1"

#4-Tạo metadata
echo "{" >> metadata.json
echo "  \"721\": {" >> metadata.json
echo "    \"$(cat policy/policyID_02)\": {" >> metadata.json
echo "      \"$(echo $realtokenname)\": {" >> metadata.json
echo "        \"description\": \"Location: Ecopark!\"," >> metadata.json
echo "        \"name\": \"Photo\"," >> metadata.json
echo "        \"id\": \"1\"," >> metadata.json
echo "        \"image\": \"ipfs://$(echo $ipfs_hash)\"" >> metadata.json
echo "      }" >> metadata.json
echo "    }" >> metadata.json
echo "  }" >> metadata.json
echo "}" >> metadata.json


#4-Tạo giao dịch
cardano-cli conway transaction build \
$testnet \
--tx-in $txhash_02#$txix_02 \
--tx-out $address+$output+"$tokenamount $policyid_02.$tokenname" \
--mint "$tokenamount $policyid_02.$tokenname" \
--mint-script-file policy/policy_02.script \
--change-address $address \
--metadata-json-file metadata.json  \
--out-file mint-nft.raw


#5-Tạo ký giao dịch
cardano-cli conway transaction sign  $testnet \
--signing-key-file $address_SKEY \
--signing-key-file policy/policy_02.skey  \
--tx-body-file mint-nft.raw \
--out-file mint-nft.signed

#5-Gửi giao dịch 

cardano-cli conway transaction submit $testnet --tx-file mint-nft.signed 




#================= Burn token vừa tạo=============
#1-Truy vấn token nằm ở UTXO nào
cardano-cli query utxo $testnet --address $address 

#2- cập nhật biến môi trường
txhash_03="2aab375cafbf03f98c3a504522813ae92874716cf4c1a66faea9e8376e587c74"
txix_03="1"
burnoutput="1400000"

#3-Tạo giao dịch
cardano-cli conway transaction build \
 --testnet-magic 2\
 --tx-in $txhash_03#$txix_03\
 --tx-in 2aab375cafbf03f98c3a504522813ae92874716cf4c1a66faea9e8376e587c74#0\
 --tx-out $address+$burnoutput\
 --mint="-1 $policyid_02.$tokenname"\
 --minting-script-file policy/policy_02.script \
 --change-address $address \
 --witness-override 2\
 --out-file burning.raw

#4-Ký giao dịch
cardano-cli conway transaction sign  $testnet \
--signing-key-file $address_SKEY \
--signing-key-file policy/policy_02.skey  \
--tx-body-file burning.raw \
--out-file burning.signed

#5-Gửi giao dịch

cardano-cli conway transaction submit $testnet --tx-file burning.signed 
