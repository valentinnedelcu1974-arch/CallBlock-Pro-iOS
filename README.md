# CallBlock Pro — iOS source project

Prototype: SwiftUI + CallKit Call Directory extension + StoreKit 2. Requires Xcode 16+, XcodeGen, Apple Developer account, App Group provisioning and App Store Connect setup.

Run `xcodegen generate`, then build in Xcode. Update bundle IDs and App Group to identifiers owned by your team. The annual StoreKit product ID is `callblockpro.annual`. Configure a 3-day introductory free trial in App Store Connect; the source code alone does not create a trial.

Limitations: Call Directory only accepts explicit E.164-style full telephone numbers, not country-prefix wildcards. The extension cannot block WhatsApp calls. No claim of real-time call monitoring, call history access, or successful blocked-call counts. The demo allows manual number blocking before subscription; enforce premium only for legitimate premium features once StoreKit is configured and tested.

Before release: add original app icon asset, privacy/support URLs, App Privacy questionnaire, age rating, real device screenshots, subscription terms, privacy policy, localization, proper signing, and end-to-end testing. Never submit synthetic screenshots as real App Store captures.

## CI and TestFlight preparation

Version 1.1, initial build 1. GitHub Actions builds both the app and embedded extension for the iOS Simulator. Download the simulator app and build log from Actions artifacts. This is not a signed iPhone/TestFlight package.

To prepare a signed TestFlight archive, register `com.callblockpro.app` and `com.callblockpro.app.directory` in the intended Apple Developer team. Register and enable `group.com.callblockpro.shared` for both identifiers. Create App Store distribution provisioning profiles for both targets and a distribution certificate. Create the CallBlock Pro record in App Store Connect using the app identifier.

Set the correct DEVELOPMENT_TEAM in the generated Xcode project or through xcodebuild. Archive the CallBlockPro scheme for generic iOS Device with both distribution profiles, then export using App Store Connect distribution and upload through Xcode Organizer or Transporter. Keep certificates, provisioning material and API keys out of source control; use repository-specific encrypted secrets for any future automated upload. Increment CURRENT_PROJECT_VERSION before each subsequent upload. Test Call Directory on a physical iPhone: enable the extension, add an international number, reload, remove it and reload again. Simulator compilation does not verify actual call blocking, App Group provisioning or StoreKit purchases.
