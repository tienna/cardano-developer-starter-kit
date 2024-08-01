# Mục tiêu của Lab04
- [ ] Soạn thảo giao dịch tạo NFT
- [ ] Ký giao dịch giao dịch tạo NFT
- [ ] Submit giao dịch tạo NFT
- [ ] Kiểm tra NFT trên ví

## VI. Mint NFT

Phần này nó cũng giống như tạo Token. Tuy nhiên như các bạn đã biết thì NFT là duy nhất do vậy tham số về số lượng ta đặt là 1. Nếu bạn đã làm theo hướng dẫn này cho đến thời điểm này, thì bạn đã quen với quy trình, vì vậy hãy bắt đầu lại.

Thiết lập mọi thứ và kiểm tra địa chỉ của chúng ta:

```bash
cardano-cli query utxo --address $address $testnet
```

```bash
txhash="5c6a453342dcfb902111fd74f095cf0f6780932d7967785c752fb7a9bba219be"
txix="1"
policyid=$(cat policy/policyID)

realtokenname="NFT1"
tokenname=$(echo -n $realtokenname | xxd -b -ps -c 80 | tr -d '\n')
tokenamount="1"
output="1400000"
ipfs_hash="QmdpcDnQj5u54JZ5ZxQMLXjajZAeAXRqHs7dNGvh7wVhq1"
```

Hàm băm IPFS là một yêu cầu quan trọng và có thể được tìm thấy sau khi bạn tải hình ảnh của mình lên IPFS. Đây là một ví dụ về giao diện của IPFS khi một hình ảnh được tải lên trong [pinata](https://pinata.cloud/) ![hình ảnh](https://user-images.githubusercontent.com/34856010/162868237-0085e25f-daa0-4cfc-b82d-0c85ad2dec1c.png)


### metadata

Vì hiện tại chúng tôi đã xác định chính sách cũng như `policyID` của mình, nên chúng tôi cần điều chỉnh thông tin siêu dữ liệu của mình.

Đây là một ví dụ về metadata.json mà chúng tôi sẽ sử dụng cho hướng dẫn này:

```json
{
        "721": {
            "please_insert_policyID_here": {
              "NFT1": {
                "description": "This is my first NFT thanks to the Cardano foundation",
                "name": "Cardano foundation NFT guide token",
                "id": 1,
                "image": ""
              }
            }
        }
}
```

:::note 
Phần tử thứ ba trong file json cần phải có cùng tên với nội dung gốc NFT của chúng ta. 
:::

Lưu tệp này dưới dạng `metadata.json` .

Nếu bạn muốn tạo nó "một cách nhanh chóng", hãy sử dụng các lệnh sau:

```bash
echo "{" >> metadata.json
echo "  \"721\": {" >> metadata.json
echo "    \"$(cat policy/policyID)\": {" >> metadata.json
echo "      \"$(echo $realtokenname)\": {" >> metadata.json
echo "        \"description\": \"This is my first NFT thanks to the Cardano foundation\"," >> metadata.json
echo "        \"name\": \"Cardano foundation NFT guide token\"," >> metadata.json
echo "        \"id\": \"1\"," >> metadata.json
echo "        \"image\": \"ipfs://$(echo $ipfs_hash)\"" >> metadata.json
echo "      }" >> metadata.json
echo "    }" >> metadata.json
echo "  }" >> metadata.json
echo "}" >> metadata.json
```


### B1. Xây dựng giao dịch (Build Tx) Mint NFT:



```bash

cardano-cli transaction build \
$testnet \
--babbage-era \
--tx-in $txhash#$txix \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--mint "$tokenamount $policyid.$tokenname" \
--mint-script-file policy/policy.script \
--change-address $address \
--metadata-json-file metadata.json  \
--out-file mint-nft.raw
```



### B2. Kí giao dịch

Các giao dịch cần phải được ký để chứng minh tính xác thực và quyền sở hữu của khóa chính sách.

```bash
cardano-cli transaction sign  $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file policy/policy.skey  \
--tx-body-file mint-nft.raw \
--out-file mint-nft.signed
```

Giao dịch đã ký sẽ được lưu trong một tệp mới có tên <i>burn-native-assets.signed</i> 

### B3. Gửi giao dịch
Bây giờ chúng ta sẽ gửi giao dịch, do đó đốt tài sản gốc của chúng ta:

```bash
cardano-cli transaction submit $testnet --tx-file mint-nft.signed 
```

Xin chúc mừng, chúng ta hiện đã đúc thành công mã thông báo của riêng mình. Sau vài giây, chúng ta có thể kiểm tra địa chỉ đầu ra

```bash
cardano-cli query utxo $testnet --address $address 
```
