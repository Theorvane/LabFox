# Store setup for free, ad-free releases

The release workflows upload builds; they do not create store records, submit
App Store review, or promote a Play track. Complete the console work below
before publishing the build that removes ads and purchases.

## Shared facts

- Bundle/application ID: `com.sloki9637.labfox`.
- LabFox is a free download with all LabFox features available at no charge.
- The app contains no in-app purchase or advertising SDK and does not request
  an advertising identifier. GitLab server-tier and permission requirements
  still apply to features supplied by the connected instance.
- Use the reviewed English and Korean copy in [`listing.md`](listing.md) and
  [`listing.ko.md`](listing.ko.md). Keep the public privacy URL and the bundled
  [`PRIVACY.md`](../../PRIVACY.md) aligned.
- Check whether any historical store subscriptions still have active customers.
  Console account actions, cancellation, refunds, and customer notices cannot
  be performed by changing app code.

## Google Play Console

1. Keep the existing application record and configure the release service
   account used by `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`.
2. Under App content, declare that the current build contains **no ads** and
   does **not** use the advertising ID. Update Data safety to match the
   privacy policy, including anonymous product analytics and device-local
   credentials. The Android manifest no longer requests `AD_ID`.
3. Remove purchase claims from the listing and set the app price to free.
   Review any historical subscription products and active subscribers in the
   console before retiring them.
4. Upload the first signed Android App Bundle manually to internal testing.
   Subsequent release automation uploads to the internal track; promotion to
   production remains a manual decision.

## App Store Connect

1. Keep the existing iOS application record, bundle ID, signing certificate,
   and provisioning profile used by the release workflow.
2. Set the app price to free and remove in-app purchase claims from metadata.
   Review historical subscriptions and active subscribers in App Store Connect.
3. Revise App Privacy to match the current build. The app has no advertising
   SDK, no ad tracking prompt, and no `SKAdNetworkItems` declaration. Anonymous
   product analytics remain described in `PRIVACY.md`.
4. Use the free, ad-free listing text and privacy URL. Uploads from the workflow
   reach App Store Connect but do not submit the app for review.
5. Check the macOS app record and listing separately where it is distributed.

Before submission, inspect a release build and its final platform manifests to
ensure removed purchase/ad plugins have not been reintroduced transitively.
Store console declarations change only when a maintainer saves them there;
this repository change alone cannot update them.
