import 'package:flutter/material.dart';

/// PURE Flutter test - no macos_ui, no macos_window_utils, no third-party packages
/// Run with: flutter run -d macos -t lib/main_pure_flutter_test.dart
void main() {
  runApp(const PureFlutterHoverTest());
}

class PureFlutterHoverTest extends StatelessWidget {
  const PureFlutterHoverTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pure Flutter Hover Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pure Flutter Hover Test'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Test 1: InkWell hover',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            InkWellTest(),
            SizedBox(height: 40),
            Text(
              'Test 2: MouseRegion hover',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            MouseRegionTest(),
            SizedBox(height: 40),
            Text(
              'Test 3: Raw Listener hover',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListenerTest(),
          ],
        ),
      ),
    );
  }
}

class InkWellTest extends StatefulWidget {
  const InkWellTest({super.key});

  @override
  State<InkWellTest> createState() => _InkWellTestState();
}

class _InkWellTestState extends State<InkWellTest> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('🟢 InkWell: TAPPED');
        },
        onHover: (hovering) {
          print('🟢 InkWell: onHover=$hovering');
          setState(() {
            _isHovered = hovering;
          });
        },
        child: Container(
          width: 400,
          height: 80,
          decoration: BoxDecoration(
            color: _isHovered ? Colors.green[300] : Colors.green[100],
            border: Border.all(
              color: _isHovered ? Colors.green[800]! : Colors.green,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            _isHovered ? '✅ InkWell HOVERING' : 'Hover over me (InkWell)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class MouseRegionTest extends StatefulWidget {
  const MouseRegionTest({super.key});

  @override
  State<MouseRegionTest> createState() => _MouseRegionTestState();
}

class _MouseRegionTestState extends State<MouseRegionTest> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        print('🔵 MouseRegion: ENTER');
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        print('🔵 MouseRegion: EXIT');
        setState(() => _isHovered = false);
      },
      onHover: (_) {
        print('🔵 MouseRegion: HOVER');
      },
      child: GestureDetector(
        onTap: () {
          print('🔵 MouseRegion: TAPPED');
        },
        child: Container(
          width: 400,
          height: 80,
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue[300] : Colors.blue[100],
            border: Border.all(
              color: _isHovered ? Colors.blue[800]! : Colors.blue,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            _isHovered
                ? '✅ MouseRegion HOVERING'
                : 'Hover over me (MouseRegion)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class ListenerTest extends StatefulWidget {
  const ListenerTest({super.key});

  @override
  State<ListenerTest> createState() => _ListenerTestState();
}

class _ListenerTestState extends State<ListenerTest> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        print('🟡 Listener: ENTER');
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        print('🟡 Listener: EXIT');
        setState(() => _isHovered = false);
      },
      child: Listener(
        onPointerHover: (event) {
          print('🟡 Listener: onPointerHover');
        },
        onPointerDown: (event) {
          print('🟡 Listener: onPointerDown');
        },
        child: GestureDetector(
          onTap: () {
            print('🟡 Listener: TAPPED');
          },
          child: Container(
            width: 400,
            height: 80,
            decoration: BoxDecoration(
              color: _isHovered ? Colors.orange[300] : Colors.orange[100],
              border: Border.all(
                color: _isHovered ? Colors.orange[800]! : Colors.orange,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _isHovered ? '✅ Listener HOVERING' : 'Hover over me (Listener)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
