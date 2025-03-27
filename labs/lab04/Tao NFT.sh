#================Lab 03- Tạo giao dich có metadata  =============
# Step 1: =========Tạo file Metadata==================
file JSON
{
    "674": {
        "msg": ["Testing onchain metadata message"]
        }
}
 
# Step 2: =========Soạn thảo giao dich==================
 
cardano-cli conway transaction build --testnet-magic 2 \
--tx-in $UTXO_IN \
--tx-out $BOB_ADDR+$VALUE \
--change-address $Alice_address \
--metadata-json-file metadata.json \
--out-file simple-tx.raw

cardano-cli conway transaction build --testnet-magic 2 \
--tx-in $UTXO_IN \ 
--tx-out $BOB_ADDR+$VALUE \ 
--change-address $Alice_address \ 
--metadata-json-file metadata.json \ 
--out-file simple-tx.raw

echo  $UTXO_IN
echo $BOB_ADDR+$VALUE
echo $Alice_address

# Step 3: =========Tạo file Metadata==================
cardano-cli conway transaction sign $testnet \
--signing-key-file $Alice_skey \
--tx-body-file simple-tx.raw \
--out-file simple-tx.signed
# Step 4: =========Tạo file Metadata==================
cardano-cli conway transaction submit $testnet \
--tx-file simple-tx.signed



#================Lab 04- Tạo tokens/NFT =============
#Step 1: =========Gán các biến==================
apt update
apt install xxd

testnet="--testnet-magic 2"
address=$(cat base.addr)
cardano-cli query utxo $testnet --address $address


txhash=86b5e9504e91b27ce0392fbfd007e0dba1b339af34578227606f560cfe976eed 
txix=0
output=1500000

ipfs_hash="QmY1HZHQeByVekQVf4SA8VQRStQE7i7967FcXDpsWsZsnQ"

realtokenname="KHBK02"
tokenname=$(echo -n $realtokenname| xxd -ps | tr -d '\n')
tokenamount=1000000

#Step 1: =========Tạo Policy ID===============
mkdir tokens; cd tokens
mkdir policy
cardano-cli address key-gen \
    --verification-key-file policy/policy.vkey \
    --signing-key-file policy/policy.skey
	
touch policy/policy.script && echo "" > policy/policy.script

echo "{" >> policy/policy.script
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script
echo "  \"type\": \"sig\"" >> policy/policy.script
echo "}" >> policy/policy.script


##====Đọc lại nội dung file policy.script để kiểm tra==============
cat policy/policy.script
cardano-cli conway transaction policyid --script-file ./policy/policy.script > policy/policyID
cat policy/policyID
policyid=$(cat policy/policyID)








#Step 2: =========Tạo Metadata ===============

echo "{" >> metadata.json
echo "  \"721\": {" >> metadata.json
echo "    \"$(cat policy/policyID)\": {" >> metadata.json
echo "      \"$(echo $realtokenname)\": {" >> metadata.json
echo "        \"description\": \"Khoa hoc Blockchain -BK02 \"," >> metadata.json
echo "        \"name\": \"$(echo $realtokenname)\"," >> metadata.json
echo "        \"id\": \"1\"," >> metadata.json
echo "        \"image\": \"ipfs://$(echo $ipfs_hash)\"" >> metadata.json
echo "      }" >> metadata.json
echo "    }" >> metadata.json
echo "  }" >> metadata.json
echo "}" >> metadata.json

cat metadata.json 

#Step 3: =========Soạn thảo giao dịch===============

echo $policyid.$tokenname >policy_token.log

cardano-cli conway transaction build $testnet \
--tx-in $txhash#$txix \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--change-address $address \
--mint "$tokenamount $policyid.$tokenname" \
--mint-script-file policy/policy.script \
--metadata-json-file metadata.json  \
--witness-override 2 \
--out-file mint-nft.raw

echo $txhash#$txix $testnet
echo $address+$output+"$tokenamount $policyid.$tokenname"
echo $address

#Step 4: =========Tạo ký giao dịchdịch===============
cardano-cli conway transaction sign  $testnet \
--signing-key-file ../payment.skey  \
--signing-key-file policy/policy.skey  \
--tx-body-file mint-nft.raw \
--out-file mint-nft.signed

#Step 5: =========Gửi giao dịchdịch===============

cardano-cli conway transaction submit $testnet --tx-file mint-nft.signed 



cardano-cli query utxo --address $(< payment.addr)
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
d4b158e58cb58da28b25837300f6ef8f9f7d67fd5a5ce07648d17a6fae31b88a     0        10000000 lovelace + 1000 11375f8ee31c280e1f2ec6fe11a73bca79d7a6a64f18e1e6980f0c74.637573746f6d636f696e
d4b158e58cb58da28b25837300f6ef8f9f7d67fd5a5ce07648d17a6fae31b88a     1        9989824379 lovelace + TxOutDatumNone

cardano-cli conway transaction build \
--tx-in d4b158e58cb58da28b25837300f6ef8f9f7d67fd5a5ce07648d17a6fae31b88a#0 \
--tx-in d4b158e58cb58da28b25837300f6ef8f9f7d67fd5a5ce07648d17a6fae31b88a#1 \
--tx-out addr_test1vp9khgeajxw8snjjvaaule727hpytrvpsnq8z7h9t3zeuegh55grh+1043020+"1 11375f8ee31c280e1f2ec6fe11a73bca79d7a6a64f18e1e6980f0c74.637573746f6d636f696e" \
--tx-out $(< payment.addr)+8956980+"999 11375f8ee31c280e1f2ec6fe11a73bca79d7a6a64f18e1e6980f0c74.637573746f6d636f696e" \
--change-address $(< payment.addr) \
--out-file tx.raw


cardano-cli conway transaction sign --tx-file tx.raw --signing-key-file policy.skey --signing-key-file payment.skey --out-file tx.signed


cardano-cli conway transaction submit --tx-file tx.signedTransaction successfully submitted.


#================Lab 05- Gửi tokens =============

bdabfe1c4677455889904cdfcab350818eeb7f0420de3af5f226a73e25a4e884     0        1500000 lovelace + 10000000  + TxOutDatumNone


txhash1=bdabfe1c4677455889904cdfcab350818eeb7f0420de3af5f226a73e25a4e884#0
txhash2=cc641d6d50d4f6900b530e767fe583a5edeeb0d37aade3f0df22a30e6bb80c3c#1
receiver="addr_test1qz8shh6wqssr83hurdmqx44js8v7tglg9lm3xh89auw007dd38kf3ymx9c2w225uc7yjmplr794wvc96n5lsy0wsm8fq9n5epq"
receiver_output=1500000


cardano-cli conway transaction build --testnet-magic 2 \
--tx-in $txhash1 \
--tx-in $txhash2 \
--tx-out $receiver+$receiver_output+"5000000 66528797c8524a6e74e6374cf0a90180626ca8f2eb2d627ebcdbc62f.4b48424b3032"  \
--tx-out $address+$receiver_output+"5000000 66528797c8524a6e74e6374cf0a90180626ca8f2eb2d627ebcdbc62f.4b48424b3032"  \
--change-address $address \
--out-file rec_matx.raw


cardano-cli conway transaction sign \
 --signing-key-file payment.skey $testnet \
 --tx-body-file rec_matx.raw \
 --out-file rec_matx.signed


cardano-cli conway transaction submit $testnet --tx-file rec_matx.signed


#================Lab 06- Burn tokens/NFT =============
cardano-cli conway transaction submit --tx-file burning.signed --testnet-magic 2
burnfee="0"
burnoutput="0"
txhash="Insert your utxo holding the NFT"
txix="Insert your txix"
burnoutput=1400000  /min ada for tx

cardano-cli conway transaction build --testnet-magic 2 \
	--tx-in $txhash#$txix \
	--tx-out $address+$burnoutput \
	--mint="-1 $policyid.$tokenname" \
	--minting-script-file $script \
	--change-address $address \
	--invalid-hereafter $slot \
	--witness-override 2 \
	--out-file burning.raw

cardano-cli conway transaction sign \
  --signing-key-file payment.skey \
  --signing-key-file policy/policy.skey \
  --testnet-magic 2 \
  --tx-body-file burning.raw \
  --out-file burning.signed

cardano-cli conway transaction submit \
	--tx-file burning.signed \
	--testnet-magic 2