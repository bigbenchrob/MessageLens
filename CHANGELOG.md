# Changelog

All notable changes to MessageLens will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.0] — 2026-03-12

First build sent to testers.

### Added
- Full Disk Access gate — app detects missing FDA on first launch and walks the user through granting it in System Settings
- Data import onboarding — imports Messages and AddressBook databases on first run with progress overlay
- Reimport from Settings — "Reimport Data" action in Settings sidebar re-runs the full import pipeline
- Abort import — user can cancel an in-progress import
- Sidebar navigation with Messages, Contacts, and Settings modes
- Contact list with display name overlay merging (working DB + user overlays)
- Chat message viewer
- Dark mode support with semantic color tokens
- Developer panel for onboarding diagnostics
- Notarized and stapled DMG distribution via `tool/build_and_notarize.sh`
