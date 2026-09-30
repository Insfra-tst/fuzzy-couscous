#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v xcodegen >/dev/null || { echo 'Install XcodeGen: brew install xcodegen'; exit 1; }
xcodebuild -version
xcodegen generate
xcodebuild -project PocketFlap.xcodeproj -scheme PocketFlap \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' build

app='build/DerivedData/Build/Products/Release-iphoneos/PocketFlap.app'
test -f "$app/PocketFlap"
mkdir -p dist
# Stage in a fresh temporary directory so old build products cannot enter the IPA.
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/Payload"
ditto "$app" "$stage/Payload/PocketFlap.app"
output="$PWD/dist/PocketFlap-unsigned.ipa"
rm -f "$output"
(cd "$stage" && /usr/bin/zip -qry "$output" Payload)
python3 scripts/verify-ipa.py "$output"
echo "Created $output"
