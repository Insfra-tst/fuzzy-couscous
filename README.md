# Pocket Flap

A small, offline Flappy Bird-style iOS game with original vector artwork. Tap to fly through gaps, beat your saved best score, and tap to restart. Includes pause/resume and automatic pause when the app loses focus. No ads, network requests, external game libraries, or Apple credentials in CI.

**Requires iOS/iPadOS 15 or later. No local Xcode is needed for the GitHub build.** GitHub's macOS runner builds the app using Xcode. The output is an **unsigned IPA** that a signing-capable sideloader signs for your device. It is not an App Store or already-signed distribution.

## 1. Push this folder to GitHub

Your destination is [Insfra-tst/fuzzy-couscous](https://github.com/Insfra-tst/fuzzy-couscous).

Git has already been initialized **inside this folder** with `main` and that URL as `origin`. Open Terminal and run:

```bash
cd "/Users/kosala/Documents/Codex/Jailbreak/IPA Creation"
git rev-parse --show-toplevel
git remote -v
git add .gitignore .github PocketFlap Tests scripts project.yml README.md
git commit -m "Add Pocket Flap iOS game and IPA build workflow"
git push -u origin main
```

The first command that prints a path should show this exact project folder. If you moved the folder, update the `cd` path. Do not run `git add` from your home directory.

If Git asks for your identity, configure it for this repository, then retry the commit:

```bash
git config user.name "YOUR NAME"
git config user.email "YOUR GITHUB EMAIL OR NOREPLY EMAIL"
```

For HTTPS authentication, use your GitHub username and a personal access token when a password is requested; your normal GitHub password will not work. The token must allow pushing repository contents and workflow files (a classic token needs `repo` and `workflow`; a fine-grained token needs appropriate Contents and Workflows write permissions for this repository). Never put a token into the repository or remote URL. GitHub Desktop is another option: add this existing local repository, commit, and push using its GitHub login.

If you copy these files to a fresh folder without `.git`, initialize it first:

```bash
git init -b main
git remote add origin https://github.com/Insfra-tst/fuzzy-couscous.git
```

The remote was empty when prepared. If it now has commits and rejects the push, fetch and inspect the existing history; do not force-push over it. If it contains only an independently-created starter README, merge deliberately with `git pull --no-rebase origin main --allow-unrelated-histories`, resolve any README conflict, commit, and push again.

## 2. Build and download the IPA

1. Push to `main`. This automatically starts the build.
2. Open [the repository's Actions page](https://github.com/Insfra-tst/fuzzy-couscous/actions).
3. Enable Actions if GitHub prompts you. Select **Build IPA**. You can also choose **Run workflow → main → Run workflow** to rebuild manually.
4. Open the run for your latest commit and wait for a green check.
5. In its **Artifacts** section, download **PocketFlap-unsigned-IPA** while logged in to GitHub.
6. Extract the downloaded ZIP. Inside is **PocketFlap-unsigned.ipa**. Keep the `.ipa` intact and give it to your sideloader, not the outer ZIP.

Artifacts are retained for 14 days. Rerun the workflow if a download expires. The workflow needs no repository secrets, provisioning profiles, certificates, Apple ID, or paid Apple Developer membership. GitHub Actions availability/usage limits still depend on your repository and account.

The workflow tests the game rules, installs XcodeGen, generates an Xcode project, builds for a real iOS device with signing disabled, packages `Payload/PocketFlap.app`, verifies the archive, and uploads it. It intentionally uses `iphoneos`, not a simulator build.

## 3. Install on your iPhone or iPad

Using [iloader's official download](https://iloader.app/):

1. Install iloader on your computer and connect the device with USB.
2. Unlock the device and accept **Trust This Computer** if asked.
3. Follow iloader's Apple Account sign-in and device setup instructions.
4. Use its IPA import/install option and select `PocketFlap-unsigned.ipa`.
5. Let iloader sign and install it. If iOS requests developer trust, open **Settings → General → VPN & Device Management**, select your developer identity, and trust it.
6. On iOS 16 or later, if prompted, enable **Settings → Privacy & Security → Developer Mode**, restart, and confirm.
7. Open **Pocket Flap**. Tap anywhere to start and flap. Avoid the pipes, ceiling, and ground. Use **Pause** to stop, tap to resume, or tap after a crash to retry.

Other IPA installers, including the SideInstaller tool you use, must support **signing/re-signing an unsigned IPA for your device**. A transfer-only installer cannot install this unsigned artifact on a stock iPhone. Follow that installer's instructions; its exact compatibility depends on the tool/version.

Free Apple personal-team provisioning is time-limited (typically seven days). Refresh/re-sign before expiry using your sideloader. Keep the same app identity and install over the existing copy to preserve the local best score; deleting the app removes its data. Free accounts also have active-app limits, so an app-limit error must be resolved in the sideloader.

## Troubleshooting

| Issue | What to do |
| --- | --- |
| Actions does not start | Confirm the workflow exists at `.github/workflows/build-ipa.yml`, is pushed to `main`, and Actions is enabled. |
| Workflow push is denied | Check repository access and your token's permission to write workflow files. |
| Build is red | Open the failed step in Actions. The first compiler/build error is the useful one. |
| No artifact | Artifacts appear only after a successful build; also check expiry and GitHub login. |
| Runner will not start | Check repository Actions policy, account quotas, and billing settings. |
| App cannot be verified or launched | Check signing expiry, developer trust, and Developer Mode in the sideloader/iOS. |
| Installer rejects the file | Extract the GitHub artifact ZIP once and select the `.ipa`; ensure the installer signs unsigned apps. |

## Development and verification

`project.yml` is the source of the Xcode project. Generated `.xcodeproj` files are ignored. Change the display name or bundle ID there; if changing the bundle ID, update the expected value in `scripts/verify-ipa.py` too.

Run the deterministic game-rule checks on a Mac with Swift command-line tools:

```bash
bash scripts/test.sh
```

If you later install full Xcode and XcodeGen, build locally with:

```bash
bash scripts/build-ipa.sh
```

Regenerate the included app icons on macOS with `swift scripts/make-icon.swift`. The app draws its graphics directly in UIKit. The game uses a fixed logical playfield, scaled to fit the safe area on phones and tablets.

Local validation covers the game model and file/script structure. UIKit compilation, device rendering, and installation still require the GitHub Xcode build and a device test. After installing, verify a scored pipe, a collision/retry, pause/resume, background/foreground pause, and best-score persistence after relaunch.

## References

- [GitHub-hosted macOS runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
- [Downloading workflow artifacts](https://docs.github.com/en/actions/managing-workflow-runs/downloading-workflow-artifacts)
- [XcodeGen project specification](https://yonaskolb.github.io/XcodeGen/Docs/ProjectSpec.html)
- [iloader installation and signing overview](https://iloader.app/)
- [Apple Developer membership and personal-team limitations](https://developer.apple.com/support/compare-memberships/)
- [Apple Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)
