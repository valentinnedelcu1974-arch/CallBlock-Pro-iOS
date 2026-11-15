# XNoCall 1.1 (5) — release candidate

Updates the existing app com.callblockpro.app, Apple ID 6832368460. Preserves the existing subscription product ID and extension bundle ID.

New original smartphone/X icon, dark spectrum dashboard with motion respecting Reduce Motion, private rule notebook with searchable labels and decision notes, existing validated import/export Rule Lab.

Static plist, JSON and YAML checks passed. iOS compilation, simulator tests, physical incoming calls, signing, TestFlight and review submission are not yet verified for this candidate. Codemagic requires repository access before the xnocall-verify workflow can run. Signing and publishing workflow must be configured with the actual existing integration and app/extension profiles after access is available.

Apple rejected the earlier app under 4.3(a). These changes do not guarantee acceptance. Review notes must describe only verified functionality and test results. Capture fresh screenshots from this build before resubmitting. Home-screen app icons are static; the in-app spectrum border pulses.
