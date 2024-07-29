# Khôi phục ví từ cụm từ ghi nhớ

Điều kiện tiên quyết
Quy trình này yêu cầu cardano-wallet và cardano-cli .

**Cardano Wallet**

Navigating the HD wallet tree structure

![](https://www.cardano2vn.io/assets/images/Cardano-Wallet-eb0b6d22232d2b14afd713cd546c82ba.png)


## Tạo cụm từ bí mật

```
cardano-address recovery-phrase generate --size 24 > phrase.prv
```

Nhập cụm mật khẩu 15 từ  hoặc cụm 24 từ (ví Shelley trên Daedalus,...) tại dấu nhắc để chuyển đổi nó thành khóa cá nhân gốc:

## B1. Tạo file gồm 24 ký tự

```
nano recovery-phrase.prv

```

## B2. Khôi phục khóa riêng gốc.

```
BASENAME=test 
cardano-address key from-recovery-phrase Shelley < recovery-phrase.prv > $BASENAME.root.prv
```

## B3. Tạo cặp khóa thanh toán.
Bây giờ hãy tạo khóa riêng $BASENAME.payment-0.prv cho địa chỉ ví đầu tiên và khóa công khai tương ứng của nó $BASENAME.payment-0.pub:

```
cardano-address key child 1852H/1815H/0H/0/0    < $BASENAME.root.prv      > $BASENAME.payment-0.prv

cardano-address key public --without-chain-code < $BASENAME.payment-0.prv > $BASENAME.payment-0.pub
```

## B4. Tạo cặp khóa thanh toán với cli.

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

## B5. Tạo khóa cổ phần.

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

## B6. Tạo địa chỉ ví.
Mỗi địa chỉ thanh toán được tính từ khóa thanh toán tương ứng:

```
cardano-cli address build --testnet-magic 2 \
                          --payment-verification-key $(cat $BASENAME.payment-0.pub) \
                          --stake-verification-key $(cat $BASENAME.stake.pub) \
                          --out-file $BASENAME.payment-0.addr
```

Các địa chỉ này phải khớp với địa chỉ của ví ban đầu.

## B7. Tạo địa chỉ ví cổ phần:

```
cardano-cli stake-address build --testnet-magic 2 \
                                --stake-verification-key-file $BASENAME.stake.pub \
                                --out-file $BASENAME.stake.addr
                                
```
## B8 Đọc UTxO trên ví

```
cardano-cli query utxo --address $(cat $BASENAME.payment-0.addr) --testnet-magic 2
```

