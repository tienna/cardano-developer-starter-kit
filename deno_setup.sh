#! /bin/bash
set -euo pipefail

apt-get update
apt-get install unzip -y
curl -fsSL https://deno.land/install.sh | sh

