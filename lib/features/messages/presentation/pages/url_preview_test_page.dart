import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import '../widgets/url_preview_dev_widget.dart';
import '../widgets/url_preview_widget.dart';

/// Test page to experiment with URL preview metadata fetching.
/// Shows comprehensive metadata for various URL types.
class UrlPreviewTestPage extends StatefulWidget {
  const UrlPreviewTestPage({super.key});

  @override
  State<UrlPreviewTestPage> createState() => _UrlPreviewTestPageState();
}

class _UrlPreviewTestPageState extends State<UrlPreviewTestPage> {
  final _urlController = TextEditingController();
  final List<String> _testUrls = [];

  // Pre-populated test URLs of various types
  final List<String> _sampleUrls = [
    'https://github.com/flutter/flutter',
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'https://twitter.com/flutterdev/status/1234567890',
    'https://www.nytimes.com/2024/01/01/technology/ai-news.html',
    'https://medium.com/@author/some-article-123abc',
    'https://www.reddit.com/r/FlutterDev/comments/abc123/title/',
    'https://stackoverflow.com/questions/12345/how-to-flutter',
  ];

  @override
  void initState() {
    super.initState();
    // Start with one sample URL
    _testUrls.add(_sampleUrls[0]);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _addUrl(String url) {
    if (url.trim().isEmpty) {
      return;
    }
    setState(() {
      _testUrls.add(url.trim());
      _urlController.clear();
    });
  }

  void _removeUrl(int index) {
    setState(() {
      _testUrls.removeAt(index);
    });
  }

  void _addSampleUrl(String url) {
    setState(() {
      _testUrls.add(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('URL Preview Metadata Test'),
        actions: [
          ToolBarIconButton(
            icon: const MacosIcon(Icons.clear_all),
            label: 'Clear All',
            showLabel: true,
            onPressed: _testUrls.isEmpty
                ? null
                : () {
                    setState(() {
                      _testUrls.clear();
                    });
                  },
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MacosColors.systemBlueColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: MacosColors.systemBlueColor),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📋 URL Preview Test',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This page shows ALL metadata that any_link_preview can extract from URLs. '
                          'Each preview shows:\n'
                          '• Title, description, site name\n'
                          '• Image preview (if available)\n'
                          '• Metadata completeness score\n'
                          '• Raw JSON data\n\n'
                          'Add your own URLs or try the sample URLs below.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // URL input
                  Row(
                    children: [
                      Expanded(
                        child: MacosTextField(
                          controller: _urlController,
                          placeholder: 'Enter URL to test...',
                          onSubmitted: _addUrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      PushButton(
                        controlSize: ControlSize.large,
                        onPressed: () => _addUrl(_urlController.text),
                        child: const Text('Add URL'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sample URLs
                  Material(
                    color: Colors.transparent,
                    child: ExpansionTile(
                      title: const Text(
                        'Sample URLs (tap to add)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _sampleUrls.map((url) {
                            final isAdded = _testUrls.contains(url);
                            return ActionChip(
                              label: Text(
                                _getDomainFromUrl(url),
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: isAdded
                                  ? MacosColors.systemGreenColor.withValues(
                                      alpha: 0.2,
                                    )
                                  : null,
                              onPressed: isAdded
                                  ? null
                                  : () => _addSampleUrl(url),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  const Divider(),

                  const SizedBox(height: 20),

                  // Preview list
                  if (_testUrls.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'No URLs added yet.\nAdd a URL above to see its metadata.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: MacosColors.systemGrayColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _testUrls.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final url = _testUrls[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'URL ${index + 1} of ${_testUrls.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                MacosIconButton(
                                  icon: const MacosIcon(Icons.close),
                                  onPressed: () => _removeUrl(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Production widget preview
                            const Text(
                              'Production Preview:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: MacosColors.systemBlueColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            UrlPreviewWidget(
                              key: ValueKey('preview_$url'),
                              url: url,
                            ),

                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Developer detailed view
                            const Text(
                              'Developer Metadata View:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: MacosColors.systemOrangeColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            UrlPreviewDevWidget(url: url),
                          ],
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }
}
