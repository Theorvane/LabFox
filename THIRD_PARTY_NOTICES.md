# Third-Party Notices

LabFox is Apache-2.0 open source, and its mobile apps are sold for a price in the app stores.
It includes the third-party components listed below, and states each license and copyright notice.

> ⚠️ **This document is a legal obligation.** Permissive licenses such as MIT, BSD, and Apache-2.0
> **also require a copyright notice and the full license text to be included.** Whenever a dependency is added, it must be recorded here.

## In-app display

Flutter collects dependency licenses automatically. It must be exposed in the app's settings screen.

```dart
showLicensePage(
  context: context,
  applicationName: 'LabFox',
  applicationLegalese: '© 2026 sloki9637',
);
```

LabFox itself is also Apache-2.0, so it is displayed on this screen as well.
Because `LicenseRegistry` automatically collects the LICENSE files of pub packages,
this screen alone satisfies the notice obligation for most pub.dev dependencies.
**Code copied in directly, and assets such as fonts and icons, are not collected automatically, so register them manually.**

```dart
LicenseRegistry.addLicense(() async* {
  yield LicenseEntryWithLineBreaks(
    ['<component>'],
    await rootBundle.loadString('assets/licenses/<component>.txt'),
  );
});
```

---

## Permitted licenses

| License | Paid distribution allowed | Conditions |
|---|---|---|
| MIT | ✅ | Copyright notice + full license text |
| BSD-2 / BSD-3 | ✅ | Copyright notice + full license text |
| Apache-2.0 | ✅ | Notice + statement of changes + pass on the NOTICE file if one exists |
| ISC | ✅ | Copyright notice |
| Zlib | ✅ | Notice (state modifications) |

## Forbidden licenses

| License | Reason |
|---|---|
| GPL-2.0 / GPL-3.0 | copyleft propagation — nullifies Apache-2.0, blocks App Store distribution |
| AGPL | Stronger copyleft — extends even to network use |
| LGPL | Flutter links statically → the dynamic linking exception cannot be used |
| SSPL / BUSL / Commons Clause | Restricts paid distribution |
| No license | No rights granted = cannot be used |

> GPL is forbidden not because it is not open source. LabFox is already open source.
> **If copyleft propagates, users who receive the paid app gain the right to demand the source and
> redistribute it for free**, which breaks the paid model and also conflicts with Apple's terms.

**Always check the license before adding a dependency.** (`AGENTS.md` §8)

---

## Included components

<!-- Update the table below whenever a dependency is added. -->

| Component | Version | License | Source |
|---|---|---|---|
| Flutter SDK | — | BSD-3-Clause | https://github.com/flutter/flutter |
| flutter_riverpod | ^2.6.1 | MIT | https://github.com/rrousselGit/riverpod |
| dio | ^5.7.0 | MIT | https://github.com/cfug/dio |
| go_router | ^14.6.0 | BSD-3-Clause | https://github.com/flutter/packages |
| freezed / freezed_annotation | ^3.0.0 | MIT | https://github.com/rrousselGit/freezed |
| json_serializable / json_annotation | ^6.8.0 / ^4.9.0 | BSD-3-Clause | https://github.com/google/json_serializable.dart |
| flutter_secure_storage | ^9.2.2 | BSD-3-Clause | https://github.com/juliansteenbakker/flutter_secure_storage |
| shared_preferences | ^2.3.3 | BSD-3-Clause | https://github.com/flutter/packages |
| intl | any | BSD-3-Clause | https://github.com/dart-lang/i18n |
| markdown | ^7.3.1 | BSD-3-Clause | https://github.com/dart-lang/markdown |
| html | ^0.15.4 | BSD-3-Clause | https://github.com/dart-lang/tools |
| crypto (GitLab API and app) | ^3.0.0 | BSD-3-Clause | https://github.com/dart-lang/crypto |
| flutter_web_auth_2 | ^4.0.0 | MIT | https://github.com/ThexXTURBOXx/flutter_web_auth_2 |
| share_plus | ^12.0.2 | BSD-3-Clause | https://github.com/fluttercommunity/plus_plugins |
| package_info_plus | ^8.1.0 | BSD-3-Clause | https://github.com/fluttercommunity/plus_plugins |
| url_launcher | ^6.3.0 | BSD-3-Clause | https://github.com/flutter/packages |
| flutter_local_notifications | ^22.3.0 | BSD-3-Clause | https://github.com/MaikuB/flutter_local_notifications |
| workmanager | ^0.10.9 | MIT | https://github.com/fluttercommunity/flutter_workmanager |
| unity_levelplay_mediation | ^9.2.0 | Proprietary — Unity Advertising Terms of Service (vendor ad SDK; approved by the maintainer, outside the permissive list by design) | https://github.com/ironsource-mobile/flutter-sdk |
| unityads-adapter / IronSourceUnityAdsAdapter | 4.3.55 (Android) / 5.9.0.0 (iOS) | Proprietary — Unity LevelPlay License (mediation adapter; same approval as the SDK above) | https://developers.is.com/ironsource-mobile/android/ |
| unity-ads (Unity Ads SDK) | 4.15.0 (Android) / 4.19.0 (iOS, via the adapter) | Proprietary — Unity Advertising Terms of Service (the demand source behind the adapter) | https://unity.com/products/unity-ads |
| in_app_purchase | ^3.3.0 | BSD-3-Clause | https://github.com/flutter/packages |
| in_app_purchase_android | ^0.5.0 | BSD-3-Clause | https://github.com/flutter/packages |
| in_app_purchase_storekit | ^0.4.11 | BSD-3-Clause | https://github.com/flutter/packages |
| in_app_purchase_platform_interface | ^1.4.1 | BSD-3-Clause | https://github.com/flutter/packages |

The app also uses the existing `crypto` package to verify GitLab diff endpoint filename hashes. Its BSD-3-Clause license permits commercial distribution; copyright and full license text are collected from the package LICENSE by Flutter's in-app license registry. No new package version is introduced.

---

## Assets

| Asset | License | Source |
|---|---|---|
| *(none)* | | |

Fonts, icons, and images are also subject to license review.
In particular, **icon sets often have restrictive commercial-use conditions**, so verify before adopting them.
