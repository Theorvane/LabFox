# Releasing

A release is a `dev` → `main` pull request. Landing it runs `release.yml`, which
verifies the commit, packages Windows, uploads to App Store Connect and Google
Play, tags, and publishes a GitHub release.

Nothing else publishes. An ordinary push to `main` with an already-tagged
version does nothing, so the pipeline cannot ship the same version twice.

---

## How to cut one

1. Bump `version:` in `apps/labfox/pubspec.yaml`.
   The part before `+` becomes the tag (`1.2.0` → `v1.2.0`). The part after is
   Android's `versionCode` and Apple's build number: **both stores reject a
   build that reuses one**, so it must increase on every release.
2. Open a `dev` → `main` pull request. `release-promotion.yml` rejects anything
   that is not the repository's own `dev` branch.
3. Merge it. `release.yml` takes over.

The Play upload targets the **internal** track. Promoting to production is a
decision made in the Play Console, not a side effect of merging.

### Release notes

`docs/store/release-notes.md` and its translations are the source. Every
release needs a `## <version>` section there, in every language, or the Play
job fails rather than publishing a release with nothing to say.

- **Play** takes them automatically: `scripts/whatsnew.py` turns the section
  into the `whatsnew-<locale>` files the upload expects, and refuses a locale
  whose text is over Play's 500-character limit.
- **The App Store does not.** `altool` uploads a build and touches no
  metadata, so the **What's New** field has to be filled in App Store Connect
  by hand, from the same file, before submitting for review. Nothing in the
  pipeline can do it and nothing checks that it was done.

---

## What the pipeline does, in order

| Job | What it does | Reversible? |
|---|---|---|
| `check` | Reads the version, skips if tagged, then runs format, analyze, and every package's tests | — |
| `windows` | Builds the Windows app, then packages an installer and a zip | — |
| `app-store-connect` | Uploads an iOS build. **Submits nothing** | yes |
| `google-play` | Uploads to the internal track, with the release notes from `docs/store` | published to testers |
| `release` | Tags and publishes the GitHub release with the Windows installer and zip | — |

Apple runs before Google deliberately. The two are not equally reversible, and
if Play published and a later step then failed, the release would be shipped but
untagged — so the next push would re-enter the pipeline and re-upload a
`versionCode` Play rejects. Live, unrecorded, and stuck until someone bumps the
version.

---

## Third-party actions are pinned

Every action in `.github/workflows/` is pinned to a full commit SHA, with the
tag it corresponded to in a trailing comment.

This is not tidiness. The release jobs hold the upload keystore, its passwords,
the Play service account, and the Apple distribution certificate. A tag is a
mutable pointer: whoever controls an action's repository can move `v2` to
different code, and every workflow referencing it would pick that up on the next
run with those secrets in scope. A SHA cannot be moved.

When bumping one, resolve the tag yourself rather than trusting a badge:

```
gh api repos/<owner>/<repo>/git/ref/tags/<tag> --jq '.object.sha'
```

---

## Secrets and variables

Configured under the repository's `play-store` and `app-store` environments,
which already exist.

`scripts/setup-release-secrets.sh` loads them. Every value goes straight from a
local file, or from your keyboard, into `gh secret set` over stdin — nothing is
echoed, written to a temporary file, or left in your shell history:

```
./scripts/setup-release-secrets.sh android   # reads android/key.properties
./scripts/setup-release-secrets.sh apple     # prompts for the Apple assets
./scripts/setup-release-secrets.sh check     # lists what is configured
```

Run it yourself. It handles secrets, so it is deliberately not something CI or
an agent does.

### Android — `play-store`

| Name | Kind | Where it comes from |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | secret | `base64 -i upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | secret | the keystore password |
| `ANDROID_KEY_ALIAS` | secret | `keytool -list -v -keystore <file>` |
| `ANDROID_KEY_PASSWORD` | secret | the key password |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | secret | Play Console → Setup → API access → service account, then grant it release permissions |

The keystore itself is never committed: `.gitignore` covers `*.jks`,
`*.keystore` and `android/key.properties`, and the workflow writes
`key.properties` from these secrets at build time.

### Apple — `app-store`

| Name | Kind | Where it comes from |
|---|---|---|
| `APPLE_TEAM_ID` | variable | App Store Connect → Membership |
| `ASC_KEY_ID` | secret | App Store Connect → Users and Access → Integrations → App Store Connect API |
| `ASC_ISSUER_ID` | secret | the same page |
| `ASC_PRIVATE_KEY` | secret | the contents of the downloaded `.p8`, which Apple lets you download **once** |
| `APPLE_DISTRIBUTION_CERTIFICATE_BASE64` | secret | an Apple Distribution certificate exported as `.p12`, base64-encoded |
| `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD` | secret | the password set during that export |
| `APP_STORE_PROVISIONING_PROFILE_BASE64` | secret | an App Store provisioning profile for `com.sloki9637.labfox`, base64-encoded |

---

## The first release is manual

The pipeline cannot bootstrap either store. The console side — app records and
privacy declarations — is written up in
[`docs/store/store-setup.md`](docs/store/store-setup.md).

The API access needed for `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` requires a working
Play Console. Upload the first bundle by hand:

```
cd apps/labfox && flutter build appbundle --release
```

Upload `build/app/outputs/bundle/release/app-release.aab` to the internal
testing track.

**App Store Connect** needs an app record for each shipped platform; see
[`docs/store/store-setup.md`](docs/store/store-setup.md).

Once both stores have an app and the pipeline's credentials exist, releases are
the three steps at the top of this file.

---

## Not automated yet

**macOS.** LabFox ships to the Mac App Store, which needs a signed installer
package rather than the app bundle the other platforms produce: a `3rd Party Mac
Developer Application` certificate for the app, a `3rd Party Mac Developer
Installer` certificate for the `.pkg`, and a Mac App Store provisioning profile.
That is a different signing path from the iOS job and worth landing on its own.
Until then, macOS releases are built and uploaded by hand.

**Windows code signing.** The Windows installer and zip are both unsigned, so
SmartScreen warns on first run. The release notes say so. Fixing it needs a
code-signing certificate.
