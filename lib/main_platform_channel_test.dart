import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Test with explicit platform channel to enable mouse tracking
/// Run with: flutter run -d macos -t lib/main_platform_channel_test.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to force enable mouse tracking via platform channel
  try {
    const platform = MethodChannel('flutter/mousecursor');
    await platform.invokeMethod('activateSystemCursor', {'kind': 'basic'});
    print('🔧 Attempted to activate mouse cursor tracking');
  } catch (e) {
    print('⚠️  Platform channel failed: $e');
  }

  runApp(const PlatformChannelTest());
}

class PlatformChannelTest extends StatelessWidget {
  const PlatformChannelTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Platform Channel Mouse Test',
      debugShowCheckedModeBanner: false,
      home: MouseTestScreen(),
    );
  }
}

class MouseTestScreen extends StatefulWidget {
  const MouseTestScreen({super.key});

  @override
  State<MouseTestScreen> createState() => _MouseTestScreenState();
}

class _MouseTestScreenState extends State<MouseTestScreen> {
  bool _globalHover = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Channel Mouse Test'),
        backgroundColor: Colors.purple,
      ),
      body: MouseRegion(
        // Wrap entire body to request tracking
        cursor: SystemMouseCursors.basic,
        onEnter: (_) {
          print('🌐 Global MouseRegion: ENTER');
          setState(() => _globalHover = true);
        },
        onExit: (_) {
          print('🌐 Global MouseRegion: EXIT');
          setState(() => _globalHover = false);
        },
        onHover: (_) {
          print('🌐 Global MouseRegion: HOVER');
        },
        child: Stack(
          children: [
            // Background indicator
            Positioned.fill(
              child: ColoredBox(
                color: _globalHover
                    ? Colors.purple.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.02),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Global hover active: $_globalHover',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SimpleHoverBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleHoverBox extends StatefulWidget {
  const SimpleHoverBox({super.key});

  @override
  State<SimpleHoverBox> createState() => _SimpleHoverBoxState();
}

class _SimpleHoverBoxState extends State<SimpleHoverBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        print('📦 Box: ENTER');
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        print('📦 Box: EXIT');
        setState(() => _isHovered = false);
      },
      onHover: (_) {
        print('📦 Box: HOVER');
      },
      child: GestureDetector(
        onTap: () => print('📦 Box: TAPPED'),
        child: Container(
          width: 400,
          height: 100,
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue : Colors.grey[300],
            border: Border.all(
              color: _isHovered ? Colors.blue[700]! : Colors.grey,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            _isHovered ? '✅ HOVERING!' : 'Move mouse over me (no click)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isHovered ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
