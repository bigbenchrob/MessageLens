import 'package:flutter/material.dart';

/// Temporary placeholder until the true global message timeline UI is ready.
class GlobalTimelinePlaceholderView extends StatelessWidget {
  const GlobalTimelinePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.timeline, size: 64, color: Color(0xFF9CA3AF)),
            SizedBox(height: 16),
            Text(
              'Global timeline is wired into navigation.\n'
              'The full virtualized UI arrives next.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
