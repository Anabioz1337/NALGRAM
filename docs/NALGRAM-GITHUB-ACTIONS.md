# NALGRAM GitHub Actions

This workflow lets you drive the iOS build from Windows while the actual compilation happens on GitHub's hosted macOS runners.

## Important limits

- For free standard macOS runners, the repository should be public.
- The workflow is manual-only via `workflow_dispatch` so your signing secrets are not exposed to pull requests.
- This still is not a pure Windows build. It is a Windows-driven remote macOS build.
- The workflow uses `macos-26-intel` on purpose because GitHub's standard public Intel macOS runner has more RAM than the standard arm64 runner.

## Files added for this flow

- `.github/workflows/build-nalgram-ios.yml`
- `build-system/Make/ImportCertificates.py` now supports `P12_PASSWORD` from the environment

## Secrets to create in GitHub

Create these repository secrets in `Settings -> Secrets and variables -> Actions`.

### `NALGRAM_CONFIGURATION_JSON`

Paste the full JSON based on `build-system/nalgram-development-configuration.sample.json`.

Minimal example:

```json
{
  "bundle_id": "org.example.NALGRAM",
  "api_id": "123456",
  "api_hash": "0123456789abcdef0123456789abcdef",
  "team_id": "ABCDE12345",
  "app_center_id": "0",
  "is_internal_build": "true",
  "is_appstore_build": "false",
  "appstore_id": "0",
  "app_specific_url_scheme": "nalgram",
  "premium_iap_product_id": "",
  "enable_siri": false,
  "enable_icloud": false
}
```

### `NALGRAM_CODESIGNING_ZIP_B64`

This secret must contain a base64-encoded zip archive with this structure:

```text
certs/
  your-signing-cert.p12
  AppleWWDRCAG3.cer (optional)
profiles/
  Telegram.mobileprovision
  Share.mobileprovision
  Widget.mobileprovision
  NotificationService.mobileprovision
  NotificationContent.mobileprovision
  Intents.mobileprovision
  WatchApp.mobileprovision
  WatchExtension.mobileprovision
  BroadcastUpload.mobileprovision
```

The profile filenames above are the safest choice for this repository layout.

To create the secret value on Windows:

```powershell
Compress-Archive -Path .\certs,.\profiles -DestinationPath .\nalgram-signing.zip -Force
[Convert]::ToBase64String([IO.File]::ReadAllBytes('.\\nalgram-signing.zip')) | Set-Clipboard
```

Then paste the clipboard contents into `NALGRAM_CODESIGNING_ZIP_B64`.

### `NALGRAM_P12_PASSWORD`

Optional.

Set this only if your `.p12` certificate has a password. Leave it unset if the `.p12` is exported without a password.

## How to run the build

1. Push your fork to GitHub.
2. Make the repository public if you want to stay on the free GitHub-hosted macOS tier.
3. Create the three secrets above.
4. Open `Actions -> Build NALGRAM iOS`.
5. Click `Run workflow`.
6. Wait for the job to finish and download the `nalgram-ios-build` artifact.

## Notes about submodules

The workflow rewrites the relative git submodule URLs for:

- `submodules/rlottie/rlottie`
- `submodules/TgVoipWebrtc/tgcalls`

This is necessary because a GitHub fork would otherwise resolve `../rlottie.git` and `../tgcalls.git` against your own account instead of the upstream `TelegramMessenger` repositories.

## After the build

If the build succeeds, GitHub Actions uploads:

- `NALGRAM.ipa`
- `NALGRAM.DSYMs.zip`

You can then sideload the IPA from Windows with AltStore or another signing/install tool.
