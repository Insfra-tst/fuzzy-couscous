#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
swiftc PocketFlap/GameModel.swift Tests/main.swift -o build/game-tests
build/game-tests
