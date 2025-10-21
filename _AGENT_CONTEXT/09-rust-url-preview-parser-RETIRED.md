# Link Preview Implementation - Quick Reference

> **Status**: The Rust/attachment-based approach for URL previews has been fully retired. All new work should follow the LinkPresentation-native flow documented here and in `12-native-link-preview-implementation.md`.

## Current Architecture Overview

- **Platform API**: Apple LinkPresentation (`LPMetadataProvider`) invoked through a Flutter method channel named `com.remember_this_text/link_preview`.
- **Dart Service**: `NativeLinkPreviewService` (in `lib/essentials/services/native_link_preview_service.dart`) requests metadata and returns a `NativeLinkMetadata` object containing optional title, resolved URL, and raw image/icon bytes.
- **UI**: `UrlPreviewWidget` renders the metadata. It prioritises the full image, falls back to an icon rendered full-width, and ultimately degrades to a clickable link card if native metadata times out after 10 seconds.

## Integration Checklist

1. **Detect URLs** in message text (see `_MessageBubble._extractUrls` in `messages_for_chat_view.dart`).
2. **Use `UrlPreviewWidget`** whenever a message is solely a URL or contains URLs that should render inline.
3. **Do not reference attachments** for preview data—`NativeLinkPreviewService` handles all metadata fetching.
4. **No Rust plumbing required** and **no plist parsing** is part of the path anymore.

## Troubleshooting Tips

- If previews fail consistently for a domain, confirm the method channel is reachable and check macOS Console logs for LinkPresentation errors.
- For icon-only responses, the widget now stretches the icon across the hero area with a subtle gradient fallback, eliminating tiny thumbnails.
- When testing, `flutter run -d macos -t lib/features/messages/presentation/pages/url_preview_test_runner.dart` provides a focused environment.

## Related Documentation

- `12-native-link-preview-implementation.md` — Deep dive into LinkPresentation setup and UI patterns.
- `lib/features/messages/presentation/widgets/url_preview_widget.dart` — Reference implementation for rendering logic.
- `lib/features/messages/presentation/view/messages_for_chat_view.dart` — Shows how previews are integrated into the chat list.
