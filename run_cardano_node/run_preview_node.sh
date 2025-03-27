#!/bin/bash

# Đường dẫn cấu hình node
CONFIG_PATH="~/cardano-node/preview-config.json"
DB_PATH="~/cardano-node/db"
SOCKET_PATH="~/cardano-node/db/socket"
TOPOLOGY_PATH="~/cardano-node/preview-topology.json"

# Địa chỉ và cổng lắng nghe của node
HOST_ADDR="0.0.0.0"
PORT="3001"

echo "🔄 Đang khởi chạy Cardano Node..."
cardano-node run \
  --config "$CONFIG_PATH" \
  --database-path "$DB_PATH" \
  --socket-path "$SOCKET_PATH" \
  --host-addr "$HOST_ADDR" \
  --port "$PORT" \
  --topology "$TOPOLOGY_PATH"