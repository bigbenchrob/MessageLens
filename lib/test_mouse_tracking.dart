import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Test to diagnose macOS mouse tracking issue
/// Run with: flutter run -d macos -t lib/test_mouse_tracking.dart
void main() {
  // Enable mouse tracking globally
  RendererBinding.instance.mouseTracker.mouseIsConnected;
  runApp(const MouseTrackingTestApp());
}

class MouseTrackingTestApp extends StatelessWidget {
  const MouseTrackingTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mouse Tracking Test',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('macOS Mouse Tracking Debug'),
          backgroundColor: Colors.teal,
        ),
        body: const Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Move mouse over boxes WITHOUT clicking\n'
                '2. Check if hover state changes\n'
                '3. Check console for print statements',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 32),
              Text(
                'Test 1: InkWell (Material hover)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              InkWellHoverTest(),
              SizedBox(height: 32),
              Text(
                'Test 2: MouseRegion with explicit cursor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              MouseRegionWithCursor(),
              SizedBox(height: 32),
              Text(
                'Test 3: Listener with behavior',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              ListenerHoverTest(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Test 1: InkWell naturally requests hover tracking
class InkWellHoverTest extends StatefulWidget {
  const InkWellHoverTest({super.key});

  @override
  State<InkWellHoverTest> createState() => _InkWellHoverTestState();
}

class _InkWellHoverTestState extends State<InkWellHoverTest> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => print('🟢 InkWell tapped'),
        onHover: (hovering) {
          print('🟢 InkWell onHover: $hovering');
          setState(() {
            _isHovering = hovering;
          });
        },
        child: Container(
          width: 400,
          height: 60,
          decoration: BoxDecoration(
            color: _isHovering ? Colors.green[300] : Colors.green[100],
            border: Border.all(
              color: _isHovering ? Colors.green[800]! : Colors.green,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            _isHovering ? '✓ InkWell HOVERING' : 'InkWell: hover me',
            style: TextStyle(
              fontSize: 16,
              fontWeight: _isHovering ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Test 2: MouseRegion with explicit cursor change
class MouseRegionWithCursor extends StatefulWidget {
  const MouseRegionWithCursor({super.key});

  @override
  State<MouseRegionWithCursor> createState() => _MouseRegionWithCursorState();
}

class _MouseRegionWithCursorState extends State<MouseRegionWithCursor> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        print('🔵 MouseRegion ENTER');
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        print('🔵 MouseRegion EXIT');
        setState(() => _isHovered = false);
      },
      onHover: (_) {
        print('🔵 MouseRegion HOVER');
      },
      child: GestureDetector(
        onTap: () => print('🔵 MouseRegion tapped'),
        child: Container(
          width: 400,
          height: 60,
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue[300] : Colors.blue[100],
            border: Border.all(
              color: _isHovered ? Colors.blue[800]! : Colors.blue,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            _isHovered
                ? '✓ MouseRegion + Cursor HOVERING'
                : 'MouseRegion + cursor: hover me',
            style: TextStyle(
              fontSize: 16,
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Test 3: Raw Listener
class ListenerHoverTest extends StatefulWidget {
  const ListenerHoverTest({super.key});

  @override
  State<ListenerHoverTest> createState() => _ListenerHoverTestState();
}

class _ListenerHoverTestState extends State<ListenerHoverTest> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        print('🟡 Listener wrapper ENTER');
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        print('🟡 Listener wrapper EXIT');
        setState(() => _isHovered = false);
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerHover: (event) {
          print('🟡 Listener onPointerHover: ${event.position}');
        },
        onPointerDown: (event) {
          print('🟡 Listener onPointerDown');
        },
        child: GestureDetector(
          onTap: () => print('🟡 Listener tapped'),
          child: Container(
            width: 400,
            height: 60,
            decoration: BoxDecoration(
              color: _isHovered ? Colors.orange[300] : Colors.orange[100],
              border: Border.all(
                color: _isHovered ? Colors.orange[800]! : Colors.orange,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _isHovered ? '✓ Listener HOVERING' : 'Listener: hover me',
              style: TextStyle(
                fontSize: 16,
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
