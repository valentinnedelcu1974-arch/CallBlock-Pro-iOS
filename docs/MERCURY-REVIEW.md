# CallBlock Mercury Pro — candidate build 4

This candidate keeps the existing bundle identifiers and subscription product. It adds a local number-list workspace: text import, explicit preview of valid/invalid/duplicate entries, all-valid confirmation before applying, saved-rule inspection and export. It uses original Mercury telephone artwork without WhatsApp branding.

Validation required before App Review: macOS build and unit tests, UI tests for import/inspection/export, physical iPhone blocking with enabled Call Directory and sandbox subscription, actual current screenshots, updated App Store title/description/subscription artwork and review notes. This document does not assert approval or that the 4.3(a) concern is resolved.

Review walkthrough: open Mercury Workspace; paste +447700900123 twice and an invalid line; confirm Apply is disabled. Remove the invalid line, apply the unique entry, then inspect that number. Export the list. In Protection, enable the extension, obtain sandbox subscription access and refresh. Test real incoming-call behavior on a physical iPhone.
