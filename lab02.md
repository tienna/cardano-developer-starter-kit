# Mục tiêu của Lab02
- [ ] Soạn thảo giao dịch
- [ ] Ký giao dịch
- [ ] Submit giao dịch
- [ ] Kiểm tra số dư

## Tạo giao dịch chuyển tADA từ ví của mình sang ví khác

### Thiết lập các biến môi trường để thuận thiện cho việc soạn thảo

⚠️ **Thay địa chỉ BOB_ADDR= địa chỉ bạn muốn gửi đến** 

```bash
testnet="--testnet-magic 2"
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


### B3. Gửi giao dịch lên Preview Testnet (Submit Tx)

```bash
cardano-cli transaction submit $testnet \
--tx-file simple-tx.signed
```
 
bạn sẽ nhìn thầy dòng chữ 

**Transaction successfully submitted.**

→ điều này có nghĩa Thông báo giao dịch đã được thực hiện thành công


### Kiểm tra số dư từ ví của bạn

```bash
cardano-cli query utxo $testnet --address $address
```

Số dư của bạn sẽ thay đổi (giảm đi) so với ban đầu, Chúc mừng bạn đã hoàn thành lab2
