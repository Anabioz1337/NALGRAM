# NALGRAM iOS

This fork is prepared to build as `NALGRAM` on top of the official `Telegram-iOS` source tree.

## What is already changed

- app display name is `NALGRAM`
- exported release artifact is copied out as `NALGRAM.ipa`
- a dedicated `NALGRAM` settings page is added inside the app
- the first Ayu-style features are wired for iOS:
  - Ghost Mode
  - Hide Stories
  - Hide Sponsored Messages
  - Quick Reactions toggle

## Build notes

You still need macOS with the Xcode/Bazel versions required by `versions.json`.

If you do not have your own Mac, see `docs/NALGRAM-GITHUB-ACTIONS.md` for a GitHub Actions based remote macOS build flow driven from Windows.

1. Copy `build-system/nalgram-development-configuration.sample.json`
2. Fill in your own:
   - `bundle_id`
   - `api_id`
   - `api_hash`
   - `team_id`
   - `app_specific_url_scheme` if you do not want to keep the default `nalgram`
3. Generate the Xcode project:

```bash
python3 build-system/Make/Make.py \
  --cacheDir="$HOME/telegram-bazel-cache" \
  generateProject \
  --configurationPath=build-system/nalgram-development-configuration.sample.json \
  --xcodeManagedCodesigning
```

4. Build an IPA:

```bash
python3 build-system/Make/Make.py \
  --cacheDir="$HOME/telegram-bazel-cache" \
  build \
  --configurationPath=build-system/nalgram-development-configuration.sample.json \
  --codesigningInformationPath=/path/to/codesigning \
  --buildNumber=100001 \
  --configuration=release_arm64 \
  --outputBuildArtifactsPath=/tmp/nalgram-build
```

The exported file will be copied to `/tmp/nalgram-build/NALGRAM.ipa`.
