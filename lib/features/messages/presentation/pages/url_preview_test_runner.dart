import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'url_preview_test_page.dart';

/// Simple runner to test URL preview functionality in isolation.
/// Run this with: flutter run -t lib/features/messages/presentation/pages/url_preview_test_runner.dart
void main() {
  runApp(const UrlPreviewTestApp());
}

class UrlPreviewTestApp extends StatelessWidget {
  const UrlPreviewTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'URL Preview Test',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const UrlPreviewTestPage(),
    );
  }
}
