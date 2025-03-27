#================= Bước_1 Tạo NFT =================
#1-Tạo thư mục Homework_Lab04 và Policy
cd labs
mkdir Homework_Lab04
cd Homework_Lab04
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

cd .. # Trở về thư mục labs

#2-Tạo biến môi trường
testnet="--testnet-magic 2"
address=$(cat base.addr)
address_SKEY="payment.skey"
cardano-cli query utxo --address $address $testnet

txhash="1796e4f786ed2a15900e8ac3ed3cbdb8067ffeea17809dc2779c36c295f7310d"
txix="1"
policyid=$(cat Homework_Lab04/policy/policyID)

realtokenname="Tran Quoc Dang_015"
tokenname=$(echo -n $realtokenname | xxd -b -ps -c 80 | tr -d '\n')
tokenamount="1"
output="2000000"
ipfs_hash="QmTPoBBis8n6EmkQv554DHZMjgECycb6mrTsAMBbFrnSNX"

#3-Tạo metadata
echo "{" >> metadata_lab04.json
echo "  \"721\": {" >> metadata_lab04.json
echo "    \"$(cat Homework_Lab04/policy/policyID)\": {" >> metadata_lab04.json
echo "      \"$(echo $realtokenname)\": {" >> metadata_lab04.json
echo "        \"Class\": \"C2VN_BK02\"," >> metadata_lab04.json
echo "        \"Name\": \"Trần Quốc Đăng\"," >> metadata_lab04.json
echo "        \"Student_no\": \"015\"," >> metadata_lab04.json
echo "        \"image\": \"ipfs://$(echo $ipfs_hash)\"," >> metadata_lab04.json
echo "        \"Module\": \"Module 1 - CLI\"" >> metadata_lab04.json
echo "      }" >> metadata_lab04.json
echo "    }" >> metadata_lab04.json
echo "  }" >> metadata_lab04.json
echo "}" >> metadata_lab04.json


#4-Tạo giao dịch
cardano-cli conway transaction build \
$testnet \
--tx-in $txhash#$txix \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--mint "$tokenamount $policyid.$tokenname" \
--mint-script-file Homework_Lab04/policy/policy.script \
--change-address $address \
--metadata-json-file metadata_lab04.json  \
--out-file mint-nft-lab04.raw


#5-Tạo ký giao dịch
cardano-cli conway transaction sign  $testnet \
--signing-key-file $address_SKEY \
--signing-key-file Homework_Lab04/policy/policy.skey  \
--tx-body-file mint-nft-lab04.raw \
--out-file mint-nft-lab04.signed

#6-Gửi giao dịch 

cardano-cli conway transaction submit $testnet --tx-file mint-nft-lab04.signed 

#================= Bước_2 Gửi NFT =================
#1-Thêm biến môi trường
cardano-cli query utxo --address $address $testnet #Liệt kê danh sách UTxO

BTC_ADDR="addr_test1qz3vhmpcm2t25uyaz0g3tk7hjpswg9ud9am4555yghpm3r770t25gsqu47266lz7lsnl785kcnqqmjxyz96cddrtrhnsdzl228"
VALUE=1500000
UTXO_IN1=eb6d8aeae523c06c258e19638e01303e504042644fbe3a10556f2fb5195c5348#0
UTXO_IN2=eb6d8aeae523c06c258e19638e01303e504042644fbe3a10556f2fb5195c5348#1

#2-Tạo metadata
echo "{" >> metadata_lab04_01.json
echo "  \"674\": {" >> metadata_lab04_01.json
echo "        \"msg\": ["\"Trần Quốc Đăng 015\"]"" >> metadata_lab04_01.json
echo "         }" >> metadata_lab04_01.json
echo "}" >> metadata_lab04_01.json

#3-Xây dựng giao dịch (Build Tx)
cardano-cli conway transaction build $testnet \
--tx-in $UTXO_IN1 \
--tx-in $UTXO_IN2 \
--tx-out $BTC_ADDR+$VALUE+"1 $policyid.$tokenname" \
--change-address $address \
--metadata-json-file metadata_lab04_01.json \
--out-file sent-nft-lab04.raw

#4-Ký giao dịch (Sign Tx)
cardano-cli conway transaction sign $testnet \
--signing-key-file $address_SKEY \
--tx-body-file sent-nft-lab04.raw \
--out-file sent-nft-lab04.signed

# B3. Gửi giao dịch (Submit Tx)

cardano-cli conway transaction submit $testnet \
--tx-file sent-nft-lab04.signed