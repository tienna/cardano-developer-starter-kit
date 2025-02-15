# Các bước cài đặt và chạy thử lucid trên deno

## Cài đặt deno

Trong folder đã có sẵn một script với nội dung
```bash
#! /bin/bash
set -euo pipefail

apt-get update
apt-get install unzip -y
curl -fsSL https://deno.land/install.sh | sh
```

## viết một chương trình đơn giản
Trong folder `lucid`  có sẵn một file .env và simpletx.ts nhằm tạo một giao dịch đơn giản giữa Alice và Bob. Bạn có thể mở file này bằng lệnh code .env và `code simple.tx`

## Chạy test chương trình simple.tx

```bash

root@codespaces-2df844:/workspaces/cardano-cli-starter-kit/lucid# bash
root@codespaces-2df844:/workspaces/cardano-cli-starter-kit/lucid# deno -v
deno 2.1.10
root@codespaces-2df844:/workspaces/cardano-cli-starter-kit/lucid# deno run --allow-all simpletx.ts 
f1ce6dd64d50461612c236864e9a72b6b552407b1aeb4d143ddaa6ce9ec6f0ec
root@codespaces-2df844:/workspaces/cardano-cli-starter-kit/lucid# 
```
