"""Check device bundle metadata and payload layout before publishing the artifact."""
import plistlib
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    assert archive.testzip() is None, 'Corrupt ZIP'
    root = 'Payload/PocketFlap.app/'
    info = plistlib.loads(archive.read(root + 'Info.plist'))
    assert info['CFBundleIdentifier'] == 'com.insfratst.pocketflap'
    assert info['CFBundlePackageType'] == 'APPL'
    assert 'iPhoneOS' in info['CFBundleSupportedPlatforms'], 'Simulator build is not sideloadable'
    assert archive.getinfo(root + info['CFBundleExecutable']).file_size > 0
    assert root + 'Assets.car' in archive.namelist(), 'Missing compiled asset catalog'
    print('IPA layout and iPhoneOS bundle metadata verified.')
