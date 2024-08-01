# Hướng dẫn sử dụng Cardano CLI Starter Kit

Bộ starter kit sẽ cho thấy cách thực hiện các hoạt động phổ biến trên blockchain Cardano bằng cách sử dụng các công cụ dòng lệnh với tên gọi `cardano-cli`.

## Tạo môi trường thực hành cho chính bạn

Bạn cần tạo ra một Cardano Node đã đồng bộ xong dữ liệu bằng cách click vào nút "Open in Github Codespaces: bên dưới đây  👇👇👇

[![Tạo Cardano node trên Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=832600260)


## Làm quen với Starter Kit

Starter kit được tổ chức dưới dạng tài liệu tương tác, nơi bạn có thể thử các lệnh khi bạn tìm hiểu từng chủ đề.

### Bố trí màn hình 

Tài liệu này mô tả bạn đang đọc hướng dẫn này bên trong Cardano Workspace, chúng tôi khuyên bạn nên chia trình soạn thảo của mình thành hai ngăn khác nhau, với README ở bên trái và terminal ở bên phải.

 ![image](https://github.com/user-attachments/assets/b08566b7-bc31-4f49-8e90-ef61f102d1e9)


Bất cứ khi nào bạn thấy một đoạn mã bash mẫu như một bước trong bất kỳ hướng dẫn nào, bạn có thể sao chép và dán nó vào thiết bị đầu cuối nhúng ở bên phải, Việc này sẽ giúp bạn phản thao tác từng lệnh nhanh hơn.

### Truy cập Cardano Node

Bởi vì bạn đang chạy starter kit trong môi trường _Cardano Workspace_, bạn đã có quyền truy cập vào cơ sở hạ tầng cần thiết để thực hành, chẳng hạn như Cardano Node. Tất cả các tệp nhị phân cần thiết đều được cài đặt sẵn theo mặc định, bao gồm cả `cardano-cli`.

Môi trường bạn sẽ thực hành là Preview vì môi trường này có dung lượng thấp, tốc độ nhanh.

Để đơn giản hóa toàn bộ quá trình, _Cardano Workspaces_ đã được cấu hình sẵn với các biến môi trường cụ thể cho phép bạn kết nối với Cardano node mà không cần thêm bước thao tác nào khác. Đây là các biến có liên quan đến hướng dẫn cụ thể này:

- `CARDANO_NODE_SOCKET_PATH`: provides the location of the unix socket within the workspace where the cardano node is listening to.
- `CARDANO_NODE_MAGIC`: the network magic corresponding to the node that is connected to the workspace.

Để đảm bảo rằng bạn đã kết nối với nút, hãy thử chạy lệnh sau để đưa ra đầu hiện tại của nút:

```sh
cardano-cli query tip --testnet-magic $CARDANO_NODE_MAGIC
```
nếu mọi thứ hoạt động bình thường, bạn sẽ thấy kết quả tương tự như thế này:

```json
{
    "block": 204803,
    "epoch": 51,
    "era": "Babbage",
    "hash": "e2de3e03c45787e1f20609ed5f9a71098b0cb75e52abca459db34354cab29423",
    "slot": 4454222,
    "syncProgress": "100.00"
}
```

## Danh mục các bài Lab

Đây là các bài lab căn bản giúp bạn làm quen với Cardano trong việc tạo giao dịch, tạo token và tạo NFT

### 1. [Quản lý tài khoản](./Lab01.md)

Bài lab sẽ giải thích cách tạo khóa ký và địa chỉ đại diện cho tài khoản của bạn khi tương tác với blockchain.

### 2. [Thực hiện giao dịch](./lab02.md)
Bài lab sẽ giải thích cách xây dựng giao dịch chuyển tiền ADA đơn giản và gửi nó lên blockchain.

### 3. [Tạo Native Assets](./lab03.md)

Bài lab sẽ giải thích cách đúc tài sản gốc tùy chỉnh và chuyển những tài sản đó sang các địa chỉ khác.

### 4. [Tạo NFT](./lab04.md)

Bài lab sẽ giải thích cách đúc NFT của riêng mình và chuyển NFT đó sang các địa chỉ khác.
