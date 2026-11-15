# XNoCall

Native SwiftUI iPhone app with a CallKit Call Directory extension and StoreKit 2 annual subscription.

[Support](docs/SUPPORT.md) · [Privacy](docs/PRIVACY.md) · [Product](docs/CALLBLOCK-PRO.md)

XNoCall includes an original smartphone/X icon and spectrum dashboard, a private searchable notebook of labels and decisions, and Rule Lab for local validation, text import, deduplication, inspection and number export. Numbers and notes remain on the device unless the user explicitly exports numbers. Exports do not include notebook notes.

List preparation and notebook tools are free. Telephone blocking requires an enabled extension and verified annual subscription access. Apple supplies regional prices and eligibility for the three-day introductory trial; US base price is $19.99/year. Product ID remains callblockpro.annual to preserve subscription identity.

Build with XcodeGen and the CallBlockPro scheme. Bundle IDs remain com.callblockpro.app and com.callblockpro.app.directory. Minimum iOS 17. Code signing uses the existing App Group group.com.callblockpro.shared and dedicated profiles. Never commit signing credentials.

Codemagic provides simulator verification and a test-gated signed TestFlight workflow. Required-reason privacy manifests cover local UserDefaults and the shared App Group. StoreKit test configuration is bundled only with UI tests. Actual telephone blocking needs a physical iPhone; simulator messages explicitly explain this limit.

The app does not provide a spam database, country-prefix wildcards, WhatsApp blocking, call history or blocked-call counters. App Review acceptance is determined by Apple.
