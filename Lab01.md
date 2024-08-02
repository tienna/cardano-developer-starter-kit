# Muc tiêu của Lab01:

- [ ] Chuyển đổi cụm từ ghi nhớ sang private key
- [ ] Kiểm tra node đã đồng bộ 100% chưa?
- [ ] Tìm số dư của ví= đọc UTxO trên ví
- [ ] Cấp tiền cho địa chỉ
- [ ] Export protocol parameters--> phục vụ cho các bài lab sau


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
code recovery-phrase.prv

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

### Kiểm tra node đã đồng bộ 100% chưa?

Chúng ta cũng muốn kiểm tra xem Node của chúng ta có được cập nhật hay không. Để làm điều đó, chúng ta kiểm tra kỷ nguyên / khối hiện tại và so sánh nó với giá trị hiện tại được hiển thị trong [Cardano Explorer for the testnet](https://explorer.cardano-testnet.iohkdev.io/en).

```bash
testnet="--testnet-magic 2"
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

### Đọc UTxO trên ví

```
cardano-cli query utxo --address $(cat $BASENAME.payment-0.addr) --testnet-magic 2
```


### Cấp tiền cho địa chỉ

Chúng ta sẽ lưu giá trị băm địa chỉ trong một biến được gọi là `address`.


```bash
address=$(cat $BASENAME.payment-0.addr)
```
Thực hiện một giao dịch luôn yêu cầu bạn trả phí. Việc gửi nội dung gốc cũng yêu cầu gửi ít nhất 1 ada.
Vì vậy, hãy đảm bảo rằng địa chỉ bạn sẽ sử dụng làm đầu vào cho giao dịch đúc tiền luôn có đủ tiền.


Trên mạng **thử nghiệm - testnet**, bạn có thể yêu cầu cấp tiền từ [testnet faucet](https://docs.cardano.org/cardano-testnets/tools/faucet/).

### Export protocol parameters

Để tính toán các giao dich, chúng ta cần một số tham số giao thức hiện tại. Các tham số có thể được lưu trong một tệp có tên là <i>protocol.json</i> bằng câu lệnh:

```bash
cardano-cli query protocol-parameters $testnet --out-file protocol.json
```

Chúc mừng, Bạn đã hoàn thành Lab1
