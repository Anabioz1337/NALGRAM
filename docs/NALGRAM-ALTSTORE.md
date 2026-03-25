# NALGRAM AltStore build

This is the free-account workflow for building `NALGRAM.ipa` without your own Mac.

The build runs on GitHub-hosted macOS and produces an AltStore-friendly IPA with app extensions disabled.

## Why this variant exists

AltStore on a free Apple ID is limited by App IDs and active app slots.

The full Telegram iOS app contains many extensions. This repository references at least:

- main app
- `Share`
- `NotificationContent`
- `NotificationService`
- `SiriIntents`
- `Widget`
- `BroadcastUpload`
- `WatchApp`
- `WatchExtension`

To stay within AltStore limits, this workflow builds with `--disableExtensions`.

## 1. Make the repository public

GitHub-hosted macOS runners are free only for public repositories.

## 2. Create `NALGRAM_ALTSTORE_CONFIGURATION_JSON`

Use [`build-system/nalgram-altstore-configuration.sample.json`](../build-system/nalgram-altstore-configuration.sample.json) as the template.

Example:

```json
{
  "bundle_id": "ph.telegra.Telegraph",
  "api_id": "25572831",
  "api_hash": "7b1862d59571097ce68b3a1d7ae23836",
  "team_id": "C67CF9S4VU",
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

Important:

- This free build path uses the repository's existing fake codesigning bundle.
- Because of that, `bundle_id` and `team_id` must stay:
  - `bundle_id = ph.telegra.Telegraph`
  - `team_id = C67CF9S4VU`
- The display name is still `NALGRAM`, but the underlying bundle identifier is Telegram's original one for this build artifact.
- If you already have App Store Telegram installed, AltStore installation may conflict. Remove the App Store version first.

## 3. Add the GitHub secret

In `Settings -> Secrets and variables -> Actions`, create:

- `NALGRAM_ALTSTORE_CONFIGURATION_JSON`

Paste the full JSON there.

No Apple certificate or provisioning profiles are needed for this workflow.

## 4. Run the workflow

Open:

- `Actions -> Build NALGRAM AltStore IPA -> Run workflow`

The workflow file is:

- [`.github/workflows/build-nalgram-altstore.yml`](../.github/workflows/build-nalgram-altstore.yml)

## 5. Download the artifact

After a successful build, download `nalgram-altstore-build`.

It contains:

- `NALGRAM.ipa`
- `NALGRAM.DSYMs.zip`

## 6. Install with AltStore on Windows

Use AltStore Classic on Windows to install `NALGRAM.ipa`.

You need:

- iTunes and iCloud installed directly from Apple, not Microsoft Store
- AltServer running on Windows
- Developer Mode enabled on the iPhone

## 7. Limitations

- The app will need refresh/reinstall roughly every 7 days on a free Apple ID.
- This variant disables app extensions to reduce App ID usage for AltStore.
- Features tied to extensions, widgets, watchOS, share extension, and related integrations are not included in this build.
