# Tương tác với Blockchain Cardano bằng CLI 

**Cài thêm các phụ thuộc**

apt update -y

apt install nano

apt install vim

## I. Khôi phục ví từ cụm từ ghi nhớ

Điều kiện tiên quyết
Quy trình này yêu cầu cardano-wallet và cardano-cli .

**Cardano Wallet**

Navigating the HD wallet tree structure

![](https://www.cardano2vn.io/assets/images/Cardano-Wallet-eb0b6d22232d2b14afd713cd546c82ba.png)


### Tạo cụm từ bí mật

```
cardano-address recovery-phrase generate --size 24 > phrase.prv
```

Nhập cụm mật khẩu 15 từ  hoặc cụm 24 từ (ví Shelley trên Daedalus,...) tại dấu nhắc để chuyển đổi nó thành khóa cá nhân gốc:

### B1. Tạo file gồm 24 ký tự

```
nano recovery-phrase.prv

```

### B2. Khôi phục khóa riêng gốc.

```
BASENAME=test 
cardano-address key from-recovery-phrase Shelley < recovery-phrase.prv > $BASENAME.root.prv
```

### B3. Tạo cặp khóa thanh toán.
Bây giờ hãy tạo khóa riêng $BASENAME.payment-0.prv cho địa chỉ ví đầu tiên và khóa công khai tương ứng của nó $BASENAME.payment-0.pub:

```
cardano-address key child 1852H/1815H/0H/0/0    < $BASENAME.root.prv      > $BASENAME.payment-0.prv

cardano-address key public --without-chain-code < $BASENAME.payment-0.prv > $BASENAME.payment-0.pub
```

### B4. Tạo cặp khóa thanh toán với cli.

Các khóa thanh toán khác có thể được tạo bằng cách tăng số cuối cùng trong đường dẫn xuất `1852H/1815H/0H/0/0`. Các khóa thanh toán từ Trezor Model T có được bằng cách tăng chữ số cuối cùng này, nhưng các khóa dành cho ví Daedalus có được từ việc tăng chữ số cuối cùng của đường dẫn xuất `1852H/1815H/0H/0/0` và `1852H/1815H/0H/1/0`.


Các khóa này có thể được chuyển đổi sang định dạng thuận tiện nhất cho cardano-cli, sử dụng các lệnh sau:

```
cardano-cli key convert-cardano-address-key --shelley-payment-key \
                                            --signing-key-file $BASENAME.payment-0.prv \
                                            --out-file $BASENAME.payment-0.skey
```

```
cardano-cli key verification-key --signing-key-file $BASENAME.payment-0.skey \
                                 --verification-key-file $BASENAME.payment-0.vkey
```

Đặc biệt, `$BASENAME.payment-0.skey` có thể được sử dụng để ký các giao dịch với cardano-cli: điều này sẽ cho phép một người chuyển tiền được bảo đảm bằng ví ban đầu.

### B5. Tạo khóa cổ phần.

Quy trình tạo khóa cổ phần tương tự như quy trình tạo khóa thanh toán:

```
cardano-address key child 1852H/1815H/0H/2/0    < $BASENAME.root.prv  > $BASENAME.stake.prv
cardano-address key public --without-chain-code < $BASENAME.stake.prv > $BASENAME.stake.pub
```

Tạo khóa cổ phần riêng tư với cli.

```
cardano-cli key convert-cardano-address-key --shelley-payment-key \
                                            --signing-key-file $BASENAME.stake.prv \
                                            --out-file $BASENAME.stake.skey
```

Tạo khóa cổ phần công khaii với cl.

```
cardano-cli key verification-key --signing-key-file $BASENAME.stake.skey \
                                 --verification-key-file $BASENAME.stake.vkey
```

### B6. Tạo địa chỉ ví.
Mỗi địa chỉ thanh toán được tính từ khóa thanh toán tương ứng:

```
cardano-cli address build --testnet-magic 2 \
                          --payment-verification-key $(cat $BASENAME.payment-0.pub) \
                          --stake-verification-key $(cat $BASENAME.stake.pub) \
                          --out-file $BASENAME.payment-0.addr
```

Các địa chỉ này phải khớp với địa chỉ của ví ban đầu.

### B7. Tạo địa chỉ ví cổ phần:

```
cardano-cli stake-address build --testnet-magic 2 \
                                --stake-verification-key-file $BASENAME.stake.pub \
                                --out-file $BASENAME.stake.addr
                                
```
### B8 Đọc UTxO trên ví

```
cardano-cli query utxo --address $(cat $BASENAME.payment-0.addr) --testnet-magic 2
```

### Kiểm tra tình trạng node

Chúng ta cũng muốn kiểm tra xem Node của chúng ta có được cập nhật hay không. Để làm điều đó, chúng ta kiểm tra kỷ nguyên / khối hiện tại và so sánh nó với giá trị hiện tại được hiển thị trong [Cardano Explorer for the testnet](https://explorer.cardano-testnet.iohkdev.io/en).

```bash
cardano-cli query tip $testnet
```

Sẽ cung cấp cho bạn một đầu ra như thế này
```bash
{
    "epoch": 282,
    "hash": "82cfbbadaaec1a6204442b91de1535505b6482ae9858f3f0bd9c4bb9c8a2c12b",
    "slot": 36723570,
    "block": 6078639,
    "era": "Mary"
}
```

Epoch và số vị trí phải khớp khi được so sánh với Cardano [Explorer for testnet](https://explorer.cardano-testnet.iohkdev.io/en)

![image](https://user-images.githubusercontent.com/34856010/162867330-fa85a6a9-37fa-4cad-94c8-bfe742c7983d.png)



Chúng ta sẽ lưu giá trị băm địa chỉ trong một biến được gọi là `address`.


```bash
address=$(cat $BASENAME.payment-0.addr)
```
### Cấp tiền cho địa chỉ

Thực hiện một giao dịch luôn yêu cầu bạn trả phí. Việc gửi nội dung gốc cũng yêu cầu gửi ít nhất 1 ada.
Vì vậy, hãy đảm bảo rằng địa chỉ bạn sẽ sử dụng làm đầu vào cho giao dịch đúc tiền luôn có đủ tiền.


Trên mạng **thử nghiệm - testnet**, bạn có thể yêu cầu cấp tiền từ [testnet faucet](https://docs.cardano.org/cardano-testnets/tools/faucet/).

### Export protocol parameters

Để tính toán các giao dich, chúng ta cần một số tham số giao thức hiện tại. Các tham số có thể được lưu trong một tệp có tên là <i>protocol.json</i> bằng câu lệnh:

```bash
cardano-cli query protocol-parameters $testnet --out-file protocol.json
```
## II. Tạo giao dịch chuyển tADA từ ví của mình sang ví khác


### Thiết lập các biến môi trường để thuận thiện cho việc giao dịch

```bash
address=$(cat $BASENAME.payment-0.addr)
address_SKEY="$BASENAME.payment-0.skey"
BOB_ADDR="addr_test1qz8shh6wqssr83hurdmqx44js8v7tglg9lm3xh89auw007dd38kf3ymx9c2w225uc7yjmplr794wvc96n5lsy0wsm8fq9n5epq"
LOVELACE_VALUE=101000000
```

### Lấy txhash và txid

```bash
cardano-cli query utxo $testnet --address $address
```

Xác định UTXO sử dụng để chi tiêu từ ví của Alice với cú pháp: 
UTXO_IN=<TxHash>#<TxId>
Trong đó <TxHash> và <TxId> được lấy từ kết quả của câu lệnh truy vấn trên, cụ thể như sau:

```bash
UTXO_IN=b8c108bde14a183b79d00a48108c40808f46757ddfd16cdbf797fc0ebecd8047#0
```


### B1. Xây dựng giao dịch (Build Tx)

```bash
cardano-cli transaction build $testnet \
--tx-in $UTXO_IN \
--tx-out $BOB_ADDR+$LOVELACE_VALUE \
--change-address $address \
--out-file simple-tx.raw
```

Bạn sẽ thấy xuất hiện file simple-tx.raw trong cùng thư mục thực hiện câu lệnh.


### B2. Ký giao dịch (Sign Tx)

```bash
cardano-cli transaction sign $testnet \
--signing-key-file $address_SKEY \
--tx-body-file simple-tx.raw \
--out-file simple-tx.signed
```

Bạn sẽ thấy xuất hiện file simple-tx.signed trong cùng thư mục thực hiện câu lệnh.


### B3. Gửo giao dịch lên Preview Testnet (Submit Tx)

```bash
cardano-cli transaction submit $testnet \
--tx-file simple-tx.signed
```
 

Transaction successfully submitted.
→ Thông báo giao dịch đã được thực hiện thành công


### Kiểm tra số dư từ ví của bạn

```bash
cardano-cli query utxo $testnet --address $address
```

## III. Tạo token


Trong phần này, chúng ta sẽ tạo tài sản gốc --**chứ không phải NFT**

Chúng ta đặc biệt khuyên bạn nên tham khảo phần này để hiểu cách hoạt động của giao dịch và đúc tiền.
Minting NFTs sẽ tuân theo quy trình tương tự, chỉ với một vài chỉnh sửa. Nếu bạn quan tâm NFT, vui lòng truy cập 
[Minting NFTs](mint-nfts).


### Yêu cầu
1. Một nút Cardano đang chạy và được đồng bộ hóa - có thể truy cập thông qua lệnh `cardano-cli`. Hướng dẫn này được viết bằng `cardano-cli` v 1.27.0. Một số lệnh có thể thay đổi.
2. Bạn có một số kiến thức về Linux về cách điều hướng giữa các thư mục, tạo và chỉnh sửa tệp cũng như thiết lập và kiểm tra các biến thông qua Linux shell.


### Tổng quan
Hướng dẫn này sẽ cung cấp cho bạn một bản sao và hướng dẫn có thể dán qua vòng đời hoàn chỉnh của mã thông báo:

![image](https://user-images.githubusercontent.com/34856010/162867266-a61dfbe8-f0cb-4c97-9c1a-7ef71d818e23.png)

Đây sẽ là những bước chúng ta cần thực hiện để hoàn thành toàn bộ vòng đời:

1. Thiết lập mọi thứ sẵn sàng
2. Tạo địa chỉ và khóa (keys) mới
3. Tạo chính sách đúc tiền
4. Soạn thảo một giao dịch đúc tiền
5. Tính phí
6. Gửi mã thông báo giao dịch và đúc token (cho chính mình)
7. Gửi token 
8. Đốt token


### Cấu trúc thư mục
Chúng ta sẽ làm việc trong một thư mục mới, Đây là tổng quan về các file sẽ được tạo ra:

```
├── burn-native-assets.raw                    # Giao dich để đốt token
├── burn-native-assets.signed                 # File ký giao dịch đã được ký để đốt token
├── mint-native-assets.raw                       # Giao dịch tạo token
├── mint-native-assets.signed                    # File ký giao dịch tạo token
├── metadata.json                  # Metadata mô tả đặc tính NFT
├── test.payment-0.addr                   # Địa chỉ để gửi và nhận
├── test.payment-0.skey                   # Khóa ký giao dịch
├── test.payment-0.vkey                   # Khóa xác nhận giao dịch
├── policy                         # Thư mục chứa chính sách
│   ├── policy.script              # Script tạo  policyID
│   ├── policy.skey                # Khóa ký Policy
│   ├── policy.vkey                # Khóa xác nhận Policy 
│   └── policyID                   # File chứa policy ID
└── protocol.json                  # File thông số hệ thống
```

### Kiến trúc mã thông báo
Trước khi khai thác nội dung gốc, bạn cần tự hỏi bản thân ít nhất bốn câu hỏi sau:
1. Tên của (các) mã thông báo sẽ là gì?
2. Tôi muốn đúc bao nhiêu?
3. Sẽ có giới hạn thời gian cho việc tương tác (đúc mã thông báo?)
4. Ai sẽ có thể đúc chúng?

Số 1, 3 và 4 sẽ được xác định trong kịch bản chính sách tiền tệ (**policy**), trong khi số tiền thực tế sẽ chỉ được xác định trên giao dịch đúc tiền.

Đối với hướng dẫn này, chúng ta sẽ sử dụng:

1. Tên của (các) mã thông báo tùy chỉnh của tôi sẽ là gì?
--> Chúng ta sẽ đặt tên là `Testtoken` và `SecondTesttoken`
2. Tôi muốn đúc bao nhiêu?
--> 10000000 each (10M `Testtoken` and 10M `SecondTesttoken`)
3. Sẽ có giới hạn thời gian cho việc tương tác (đúc hoặc đốt mã thông báo?)
---> Không (tuy nhiên, chúng ta sẽ làm khi tạo NFT), chúng ta muốn đúc và đốt chúng theo cách chúng ta muốn.
4. Ai sẽ có thể đúc chúng?
--> chỉ có một chữ ký (mà chúng ta sơ hữu) mới có thể ký giao dịch và do đó có thể đúc mã thông báo



### Khai báo biến
Vì chúng ta đã trả lời tất cả các câu hỏi ở trên, chúng ta sẽ đặt các biến trên terminal / bash của mình để làm cho khả năng đọc dễ dàng hơn một chút. Chúng ta cũng sẽ sử dụng testnet. Sự khác biệt duy nhất giữa việc khai thác nội dung gốc trong mạng chính là bạn cần thay thế <b>testnet</b> bằng <b>mainnet</b>. 

<b>Kể từ phiên bản cardano-cli 1.31.0, tên mã thông báo phải được mã hóa base16 </b>.  Vì vậy, ở đây, chúng ta sử dụng công cụ xxd để mã hóa tên mã thông báo.

```bash
BASENAME=test
testnet="--testnet-magic 2"
tokenname1=$(echo -n "CBCA1" | xxd -ps | tr -d '\n')
tokenname2=$(echo -n "CBCA2" | xxd -ps | tr -d '\n')
tokenamount="10000000"
output="20000000"
```

Chúng ta sẽ sử dụng kỹ thuật thiết lập các biến này để giúp bạn dễ dàng theo dõi hơn..



## Minting tài sản gốc

### Tạo policy

Chính sách (Policies) là yếu tố quyết định công việc tài sản gốc. Chỉ những người sở hữu từ khóa chính sách mới mới có thể tạo ra tài liệu gốc theo chính sách này. Chúng ta sẽ tạo một thư mục con riêng biệt trong thư mục công việc của mình để giữ cho mọi thứ được tách biệt theo chính sách và có tổ chức hơn. Để đọc thêm, vui lòng xem [tài liệu chính thức](https://docs.cardano.org/native-tokens/getting-started/#tokenmintingpolicies) hoặc [trang github về tập lệnh đa chữ ký](https://github.com/input-output-hk/cardano-node/blob/c6b574229f76627a058a7e559599d2fc3f40575d/doc/reference/simple-scripts.md).



**all**

Kiểu `type` với giá trị khóa `all` chỉ ra rằng để chi tiêu đầu ra giao dịch này, cần có chữ ký tương ứng của tất cả các mã băm khóa thanh toán được liệt kê..

```json
{
    "scripts": [
        {
            "keyHash": "e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a",
            "type": "sig"
        },
        {
            "keyHash": "a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756",
            "type": "sig"
        },
    ],
    "type": "all"
}
```

### Tạo thư mục chưa policy

```bash
mkdir policy
```

:::note Chúng ta không điều hướng vào thư mục này và mọi thứ được thực hiện từ thư mục làm việc của chúng ta. :::

### Trước hết, chúng ta cần một số cặp khóa policy:

```bash
cardano-cli address key-gen \
    --verification-key-file policy/policy.vkey \
    --signing-key-file policy/policy.skey
```

Tạo một tệp `policy.script` là chính sách đúc token.

```bash
touch policy/policy.script && echo "" > policy/policy.script
```

Sử dụng lệnh `echo` để điền vào tệp:

```bash
echo "{" >> policy/policy.script
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script
echo "  \"type\": \"sig\"" >> policy/policy.script
echo "}" >> policy/policy.script
```
Chung ta có thể xem chúng.

```bash
nano policy/policy.script
```

Bây giờ chúng ta có một tệp tập lệnh đơn giản xác định khóa xác minh chính sách làm nhân chứng để ký giao dịch đúc. Không có ràng buộc nào khác như khóa mã thông báo hoặc yêu cầu chữ ký cụ thể để gửi thành công giao dịch với chính sách đúc tiền này.

### Mint tài sản

Để đúc Token gốc, chúng ta cần tạo Policy ID từ tệp tập lệnh mà chúng ta đã tạo.

```bash
cardano-cli transaction policyid --script-file ./policy/policy.script > policy/policyID
```

Đầu ra được lưu vào tệp `policyID` vì chúng ta cần tham khảo nó sau này.


#### Nói nhanh về các giao dịch trong Cardano

Mỗi giao dịch trong Cardano yêu cầu thanh toán một khoản phí — tính đến thời điểm hiện tại — phần lớn sẽ được xác định bởi quy mô của những gì chúng ta muốn truyền tải. Càng nhiều byte được gửi, phí càng cao.

Đó là lý do tại sao thực hiện giao dịch trong Cardano là một quá trình ba chiều.

1. Đầu tiên, chúng ta sẽ xây dựng một giao dịch, kết quả là một tệp. Đây sẽ là cơ sở để tính phí giao dịch.
2. Chúng ta sử dụng tệp `raw` này và các tham số giao thức của mình để tính phí
3. Sau đó, chúng ta cần xây dựng lại giao dịch, bao gồm phí chính xác và số tiền đã điều chỉnh mà chúng ta có thể gửi. Vì chúng ta gửi nó cho chính mình nên đầu ra cần phải là số tiền chúng ta tài trợ trừ đi phí tính toán.

Một điều khác cần lưu ý là mô hình về cách các giao dịch và "số dư" được thiết kế trong Cardano. Mỗi giao dịch có một (hoặc nhiều) đầu vào (nguồn tiền của bạn, chẳng hạn như hóa đơn bạn muốn sử dụng trong ví của mình để thanh toán) và một hoặc nhiều đầu ra. Trong ví dụ đúc tiền của chúng ta, đầu vào và đầu ra sẽ giống nhau - <b>địa chỉ của chính chúng ta</b> .

Trước khi bắt đầu, một lần nữa chúng ta sẽ cần một số thiết lập để giúp việc xây dựng giao dịch dễ dàng hơn. 

**Trước tiên, hãy truy vấn địa chỉ thanh toán của bạn và lưu ý các giá trị khác nhau hiện có.**

```bash
cardano-cli query utxo $testnet --address $address 
```

Đầu ra của bạn sẽ trông giống như thế này (ví dụ hư cấu):

```bash
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
b35a4ba9ef3ce21adcd6879d08553642224304704d206c74d3ffb3e6eed3ca28     0        1000000000 lovelace
```

Vì chúng ta cần từng giá trị đó trong giao dịch của mình nên chúng ta sẽ lưu trữ chúng riêng lẻ trong một biến tương ứng.

Tạo các biến để mint Token

```bash
txhash="75b550532dfe0b103b73b9a1b9dcc446ce4aaff3df06f06476e4efc951809a23"
txix="1"
policyid=$(cat policy/policyID)
```

### B1. Xây dựng giao dịch (Build Tx) Minting Transaction:

Bây giờ chúng ta đã sẵn sàng tạo giao dịch đầu tiên để tính phí của chúng ta và lưu nó vào một tệp có tên <i>mint-native-assets.raw</i> . Chúng ta sẽ tham chiếu các biến trong giao dịch của mình để cải thiện khả năng đọc vì chúng ta đã lưu gần như tất cả các giá trị cần thiết trong các biến. Đây là giao dịch của chúng ta trông như thế nào:

```bash

cardano-cli transaction build \
$testnet \
--babbage-era \
--tx-in $txhash#$txix \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname1 + $tokenamount $policyid.$tokenname2" \
--mint "$tokenamount $policyid.$tokenname1 + $tokenamount $policyid.$tokenname2" \
--mint-script-file policy/policy.script \
--change-address $address \
--out-file mint-native-assets.raw
```


#### phân tích cú pháp

```bash
--tx-in $txhash#$txix \
```

Hàm băm của địa chỉ mà chúng ta sử dụng làm đầu vào cho giao dịch cần có đủ tiền. Vì vậy, cú pháp là: hàm băm, theo sau là dấu thăng, theo sau là giá trị TxIx của hàm băm tương ứng.

```bash
--tx-out $address+$output+"$tokenamount $policyid.$tokenname1 + $tokenamount $policyid.$tokenname2" \
```

Đây là phần đầu ra quan trọng. Đối với <i>--tx-out</i> , chúng ta cần chỉ định địa chỉ nào sẽ nhận giao dịch của này. Trong trường hợp của chúng ta, chúng ta gửi mã thông báo đến địa chỉ của chúng ta.

1. ịa chỉ
2. Dấu cộng +
3. Đầu ra tính bằng Lovelace (ada)
4. Dấu cộng +
5. Dấu ngoặc kép
6. Số lượng mã thông báo
7. Một khoảng trống
8. id chính sách
9. Một dấu chấm
10. Tên mã thông báo (tùy chọn nếu bạn muốn có nhiều/mã thông báo khác nhau: một ô trống, một dấu cộng, một ô trống và bắt đầu lại từ 6.)
11. dấu ngoặc kép


```bash
--mint="$tokenamount $policyid.$tokenname1 + $tokenamount $policyid.$tokenname2" \
```

Một lần nữa, cú pháp tương tự như được chỉ định như trong <i>--tx-out</i> nhưng không có địa chỉ và số lovelace (ADA).



```bash
--change-address $address \
```

Đậy là phần còn lại ADA của UTxO gửi lại đỉa chỉ ký.

```bash
--protocol-params-file protocol.json \
```
Đây là file cấu hình để tạo giao dịch nó lấy các thông số của mạng

```bash
--out-file mint-native-assets.raw
```

Cuối cùng, Chúng ta lưu giao dịch của mình vào một tệp mà bạn có thể đặt tên theo ý muốn. Chỉ cần đảm bảo tham chiếu đúng tên tệp trong các lệnh sắp tới. 

### B2. Kí giao dịch

Các giao dịch cần phải được ký để chứng minh tính xác thực và quyền sở hữu của khóa chính sách.

```bash
cardano-cli transaction sign  $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file policy/policy.skey  \
--tx-body-file mint-native-assets.raw \
--out-file mint-native-assets.signed
```

Giao dịch đã ký sẽ được lưu trong một tệp mới có tên <i>mint-native-assets.signed</i> 

### B3. Gửi giao dịch

Bây giờ chúng ta sẽ gửi giao dịch, do đó đúc tài sản gốc của chúng ta:

```bash
cardano-cli transaction submit $testnet --tx-file mint-native-assets.signed 
```

Xin chúc mừng, chúng ta hiện đã đúc thành công mã thông báo của riêng mình. Sau vài giây, chúng ta có thể kiểm tra địa chỉ đầu ra

```bash
cardano-cli query utxo $testnet --address $address 
```

và sẽ thấy một cái gì đó như thế này

```bash
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
d82e82776b3588c1a2c75245a20a9703f971145d1ca9fba4ad11f50803a43190     0        999824071 lovelace + 10000000 45fb072eb2d45b8be940c13d1f235fa5a8263fc8ebe8c1af5194ea9c.5365636F6E6454657374746F6B656E + 10000000 45fb072eb2d45b8be940c13d1f235fa5a8263fc8ebe8c1af5194ea9c.54657374746F6B656E
```

## Gửi Token đến ví khác

Để gửi mã thông báo đến ví, chúng ta cần tạo một giao dịch khác - chỉ lần này là không có tham số đúc. 
Chúng ta sẽ thiết lập các biến của chúng ta cho phù hợp.



### Thiết lập các biến môi trường để thuận thiện cho việc giao dịch

```bash
address=$(cat $BASENAME.payment-0.addr)
address_SKEY="$BASENAME.payment-0.skey"
BOB_ADDR="addr_test1qz8shh6wqssr83hurdmqx44js8v7tglg9lm3xh89auw007dd38kf3ymx9c2w225uc7yjmplr794wvc96n5lsy0wsm8fq9n5epq"
LOVELACE_VALUE=2000000
policyid=$(cat policy/policyID)
```
Chúng ta truy cập vào các biến khác từ quá trình đúc. Vui lòng kiểm tra xem các biến đó đã được đặt chưa:

```bash
echo Tokenname 1: $tokenname1
echo Tokenname 2: $tokenname2
echo Address: $address
echo Policy ID: $policyid
```

### Lấy txhash và txid

```bash
cardano-cli query utxo $testnet --address $address
```

Xác định UTXO sử dụng để chi tiêu từ ví của Alice với cú pháp: 
UTXO_IN=<TxHash>#<TxId>
Trong đó <TxHash> và <TxId> được lấy từ kết quả của câu lệnh truy vấn trên, cụ thể như sau:

```bash
UTXO_IN=71dce5be551f2c69d139eb8de50b9cd94fa94d6b47214307c6f32e574820755d#0

```


### B1. Xây dựng giao dịch (Build Tx)

```bash
cardano-cli transaction build $testnet \
--tx-in $UTXO_IN \
--tx-out $BOB_ADDR+$LOVELACE_VALUE+"2 $policyid.$tokenname1" \
--change-address $address \
--out-file simple-tx.raw
```

Bạn sẽ thấy xuất hiện file simple-tx.raw trong cùng thư mục thực hiện câu lệnh.


### B2. Ký giao dịch (Sign Tx)

```bash
cardano-cli transaction sign $testnet \
--signing-key-file $address_SKEY \
--tx-body-file simple-tx.raw \
--out-file simple-tx.signed
```

Bạn sẽ thấy xuất hiện file simple-tx.signed trong cùng thư mục thực hiện câu lệnh.


### B3. Gửi giao dịch lên Preview Testnet (Submit Tx)

```bash
cardano-cli transaction submit $testnet \
--tx-file simple-tx.signed
```
 

Transaction successfully submitted.
→ Thông báo giao dịch đã được thực hiện thành công


### Kiểm tra số dư từ ví của bạn

```bash
cardano-cli query utxo $testnet --address $address
```


## Đốt mã thông báo

Trong phần cuối của vòng đời mã thông báo, chúng ta sẽ đốt 5000 mã thông báo mới được tạo <i>SecondTesttoken</i> , do đó sẽ hủy chúng vĩnh viễn.

Bạn sẽ không ngạc nhiên khi điều này — một lần nữa — sẽ được thực hiện với một giao dịch. Nếu bạn đã làm theo hướng dẫn này cho đến thời điểm này, thì bạn đã quen với quy trình, vì vậy hãy bắt đầu lại.

Thiết lập mọi thứ và kiểm tra địa chỉ của chúng ta:

```bash
cardano-cli query utxo --address $address $testnet
```

```bash
txhash="5c6a453342dcfb902111fd74f095cf0f6780932d7967785c752fb7a9bba219be"
txix="1"
policyid=$(cat policy/policyID)
```

### B1 B1. Xây dựng giao dịch (Build Tx) đốt token:


Việc đốt mã thông báo khá đơn giản. Bạn sẽ đưa ra một hành động đúc kết mới, nhưng lần này với đầu vào <b>âm</b> . Điều này về cơ bản sẽ trừ đi số lượng mã thông báo.

```bash

cardano-cli transaction build \
$testnet \
--babbage-era \
--tx-in $txhash#$txix \
--mint="-5000 $policyid.$tokenname2" \
--minting-script-file policy/policy.script \
--change-address $address \
--out-file burn-native-assets.raw
```

### B2. Kí giao dịch

Các giao dịch cần phải được ký để chứng minh tính xác thực và quyền sở hữu của khóa chính sách.

```bash
cardano-cli transaction sign  $testnet \
--signing-key-file $address_SKEY  \
--signing-key-file policy/policy.skey  \
--tx-body-file burn-native-assets.raw \
--out-file burn-native-assets.signed
```

Giao dịch đã ký sẽ được lưu trong một tệp mới có tên <i>burn-native-assets.signed</i> 

### B3. Gửi giao dịch
Bây giờ chúng ta sẽ gửi giao dịch, do đó đốt tài sản gốc của chúng ta:

```bash
cardano-cli transaction submit $testnet --tx-file burn-native-assets.signed 
```

Xin chúc mừng, chúng ta hiện đã đúc thành công mã thông báo của riêng mình. Sau vài giây, chúng ta có thể kiểm tra địa chỉ đầu ra

```bash
cardano-cli query utxo $testnet --address $address 
```
