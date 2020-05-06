#!/bin/bash
set -e

# コンテナを再実行すると前回実行時のserver.pidが残っているので削除
rm -f /techpitgram/tmp/pids/server.pid

# DockerfileのCMDに設定されたメインプロセスを実行.
exec "$@"