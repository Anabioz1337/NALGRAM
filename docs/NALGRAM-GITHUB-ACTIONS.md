# NALGRAM GitHub Actions build

This repository can build `NALGRAM.ipa` on GitHub-hosted macOS runners.

## 1. Make the repository public

Standard GitHub-hosted macOS runners are free and unlimited only for public repositories.

## 2. Prepare `NALGRAM_CONFIGURATION_JSON`

Use [`build-system/nalgram-development-configuration.sample.json`](../build-system/nalgram-development-configuration.sample.json) as the template.

Example:

```json
{
  "bundle_id": "com.anabioz.nalgram",
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

Field notes:

- `bundle_id`: your base bundle id, for example `com.anabioz.nalgram`
- `api_id` and `api_hash`: get them from `https://my.telegram.org/apps`
- `team_id`: your Apple Developer Team ID
- `app_specific_url_scheme`: keep `nalgram`
- `enable_siri` and `enable_icloud`: keep `false` unless you really need them

## 3. Prepare the signing bundle

Create a directory with this structure:

```text
codesigning/
  certs/
    development.p12
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

Notes:

- The `.p12` file must contain your iPhone Developer certificate.
- The provisioning profiles must match your base `bundle_id`.
- The profile filenames are not important to the build script, but keeping the names above makes the bundle easy to audit.

Expected bundle identifiers:

- `bundle_id`
- `bundle_id.Share`
- `bundle_id.Widget`
- `bundle_id.NotificationService`
- `bundle_id.NotificationContent`
- `bundle_id.SiriIntents`
- `bundle_id.watchkitapp`
- `bundle_id.watchkitapp.watchkitextension`
- `bundle_id.BroadcastUpload`

Zip the folder on Windows:

```powershell
Compress-Archive -Path .\codesigning\certs,.\codesigning\profiles -DestinationPath .\nalgram-signing.zip -Force
```

Convert the zip to Base64:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('.\nalgram-signing.zip')) | Set-Clipboard
```

## 4. Add GitHub Actions secrets

In your repository open `Settings -> Secrets and variables -> Actions` and create:

- `NALGRAM_CONFIGURATION_JSON`
- `NALGRAM_CODESIGNING_ZIP_B64`
- `NALGRAM_P12_PASSWORD`

Put the full JSON into `NALGRAM_CONFIGURATION_JSON`.

Put the Base64 text from the previous step into `NALGRAM_CODESIGNING_ZIP_B64`.

If your `.p12` has no password, set `NALGRAM_P12_PASSWORD` to an empty string.

## 5. Run the workflow

Open `Actions -> Build NALGRAM iOS -> Run workflow`.

The workflow file is:

- [`.github/workflows/build-nalgram-ios.yml`](../.github/workflows/build-nalgram-ios.yml)

## 6. Download the result

After a successful build, download the `nalgram-ios-build` artifact.

It contains:

- `NALGRAM.ipa`
- `NALGRAM.DSYMs.zip`

## 7. Install on iPhone from Windows

Use AltStore or another sideload tool on Windows to install `NALGRAM.ipa`.

This does not replace Apple signing. The GitHub workflow still requires a valid Apple certificate and provisioning profiles.
