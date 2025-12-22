import 'package:flutter/material.dart';

/// Drop this widget ANYWHERE in your existing app to test hover.
/// For example, add it directly to macos_app_shell.dart
class DebugHoverWidget extends StatefulWidget {
  const DebugHoverWidget({super.key});

  @override
  State<DebugHoverWidget> createState() => _DebugHoverWidgetState();
}

class _DebugHoverWidgetState extends State<DebugHoverWidget> {
  bool _isHovered = false;
  int _hoverEvents = 0;
  int _clickEvents = 0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 150,
      left: 100,
      child: Listener(
        onPointerHover: (event) {
          print('🔥🔥🔥 LISTENER onPointerHover: $event');
          if (!_isHovered) {
            setState(() {
              _isHovered = true;
              _hoverEvents++;
            });
          }
        },
        onPointerDown: (event) {
          print('🔥🔥🔥 LISTENER onPointerDown: $event');
          setState(() {
            _clickEvents++;
          });
        },
        child: MouseRegion(
          onEnter: (_) {
            print('🔥 MouseRegion ENTER');
            setState(() => _isHovered = true);
          },
          onExit: (_) {
            print('🔥 MouseRegion EXIT');
            setState(() => _isHovered = false);
          },
          onHover: (_) {
            print('🔥 MouseRegion HOVER');
          },
          child: GestureDetector(
            onTap: () {
              print('🔥 GestureDetector TAP');
              setState(() {
                _clickEvents++;
              });
            },
            child: Container(
              width: 350,
              height: 100,
              decoration: BoxDecoration(
                color: _isHovered ? Colors.red : Colors.yellow,
                border: Border.all(
                  color: _isHovered ? Colors.red[900]! : Colors.orange,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isHovered ? '🔥 HOVERING!' : '👆 Hover & Click Me',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hovers: $_hoverEvents | Clicks: $_clickEvents',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
