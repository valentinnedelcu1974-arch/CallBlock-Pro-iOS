# CallBlock Mercury Pro
SwiftUI iPhone application with a CallKit Call Directory extension and StoreKit 2 annual subscription.

[Support](docs/SUPPORT.md) · [Privacy Policy](docs/PRIVACY.md) · [Product information](docs/CALLBLOCK-PRO.md)

## Mercury Workspace
Prepare and inspect your own number lists locally. Paste one international number per line or open a UTF-8 text file up to 1 MB and 10,000 nonempty lines. Preview validation and duplicates before applying; invalid lines must be corrected or removed. Check a number against your saved list and export through the iOS share sheet. The inspector is not a spam database or incoming-call simulator.

## Build
Run `xcodegen generate`, then build the CallBlockPro scheme. Deployment target: iOS 17 or later. The application and extension use the shared App Group `group.com.callblockpro.shared`.

Release archives use App Store provisioning profiles for `com.callblockpro.app` and `com.callblockpro.app.directory`. Keep signing keys, profiles and App Store Connect credentials outside source control.

## Subscription
The StoreKit identifier is `callblockpro.annual`. App Store Connect is configured for an annual subscription with US base price $19.99 and a 3-day introductory free trial for eligible new subscribers. Apple supplies localized prices and determines eligibility. Saved-list preparation is free; the extension loads blocking entries while verified subscription access is active.

The StoreKit configuration under UITests is used only for automated tests. It is not bundled in the release application.

## Validation
GitHub Actions builds the app and extension, tests number validation, persistence and subscription expiry, and separately exercises trial purchasing, restore and expiry using Apple's StoreKit Test environment. App Store screenshots are captured from the running application; generated mockups are not used as screenshots.

Actual incoming-call blocking requires testing on a physical iPhone with the extension enabled. Country-prefix wildcards, WhatsApp call blocking, call-history access and verified blocked-call counts are not supported.
