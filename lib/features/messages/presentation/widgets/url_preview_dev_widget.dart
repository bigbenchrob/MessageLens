import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

/// Developer diagnostic widget for URL preview testing.
/// Simplified version - just shows the URL being tested.
///
/// Note: This is now mainly for testing purposes since we only use
/// Apple's native LinkPresentation (no HTTP scraping fallback).
class UrlPreviewDevWidget extends StatelessWidget {
  final String url;

  const UrlPreviewDevWidget({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MacosColors.controlBackgroundColor,
        border: Border.all(color: MacosColors.separatorColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.code, size: 16, color: MacosColors.systemOrangeColor),
              SizedBox(width: 8),
              Text(
                'Developer View',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: MacosColors.systemOrangeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // URL being tested
          _buildInfoRow('Testing URL:', url),
          const SizedBox(height: 8),

          // Note about native preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MacosColors.systemBlueColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: MacosColors.systemBlueColor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Using Apple LinkPresentation API (same as iMessage)',
                    style: TextStyle(fontSize: 11, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: MacosColors.systemGrayColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
