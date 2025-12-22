import 'package:flutter/material.dart';

/// Minimal hover test - no macos_ui, no providers, no complexity.
/// Run with: flutter run -d macos -t lib/main_hover_test.dart
void main() {
  runApp(const HoverTestApp());
}

class HoverTestApp extends StatelessWidget {
  const HoverTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hover Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HoverTestScreen(),
    );
  }
}

class HoverTestScreen extends StatelessWidget {
  const HoverTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hover Test - Basic Principles')),
      body: const Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test 1: Simple MouseRegion with Container',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SimpleHoverBox(),
            SizedBox(height: 40),
            Text(
              'Test 2: MouseRegion inside ListView',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            HoverListTest(),
            SizedBox(height: 40),
            Text(
              'Test 3: Parent tracking hover (Y-position calculation)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ParentTrackedHoverList(),
          ],
        ),
      ),
    );
  }
}

/// Test 1: Absolute simplest hover case
class SimpleHoverBox extends StatefulWidget {
  const SimpleHoverBox({super.key});

  @override
  State<SimpleHoverBox> createState() => _SimpleHoverBoxState();
}

class _SimpleHoverBoxState extends State<SimpleHoverBox> {
  bool _isHovered = false;
  int _eventCount = 0;

  @override
  Widget build(BuildContext context) {
    print('🔥 SimpleHoverBox: building, _isHovered=$_isHovered');

    return Listener(
      onPointerHover: (event) {
        print('🔥🔥🔥 LISTENER: onPointerHover event=$event');
        if (!_isHovered) {
          setState(() {
            _isHovered = true;
            _eventCount++;
          });
        }
      },
      onPointerDown: (event) {
        print('🔥🔥🔥 LISTENER: onPointerDown event=$event');
      },
      onPointerMove: (event) {
        print('🔥🔥🔥 LISTENER: onPointerMove event=$event');
      },
      child: MouseRegion(
        onEnter: (_) {
          print('🔥 SimpleHoverBox: ENTER');
          setState(() => _isHovered = true);
        },
        onExit: (_) {
          print('🔥 SimpleHoverBox: EXIT');
          setState(() => _isHovered = false);
        },
        onHover: (event) {
          print('🔥 SimpleHoverBox: HOVER event=$event');
        },
        child: GestureDetector(
          onTap: () {
            print('🔥 SimpleHoverBox: TAPPED');
          },
          child: Container(
            width: 400,
            height: 80,
            decoration: BoxDecoration(
              color: _isHovered ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered ? Colors.blue[700]! : Colors.grey,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _isHovered
                  ? 'HOVERING! ✓ (events: $_eventCount)'
                  : 'Hover over me',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isHovered ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Test 2: Multiple items in a Column (simpler than ListView)
class HoverListTest extends StatelessWidget {
  const HoverListTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: HoverListItem(label: 'Item ${i + 1}'),
          ),
      ],
    );
  }
}

class HoverListItem extends StatefulWidget {
  const HoverListItem({super.key, required this.label});

  final String label;

  @override
  State<HoverListItem> createState() => _HoverListItemState();
}

class _HoverListItemState extends State<HoverListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        print('🔥 ${widget.label}: ENTER');
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        print('🔥 ${widget.label}: EXIT');
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: () {
          print('🔥 ${widget.label}: TAPPED');
        },
        child: Container(
          width: 400,
          height: 60,
          decoration: BoxDecoration(
            color: _isHovered ? Colors.green[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _isHovered ? Colors.green : Colors.grey),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            '${widget.label} ${_isHovered ? "← HOVER" : ""}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Test 3: Parent calculates hover by Y position (like your contact picker)
class ParentTrackedHoverList extends StatefulWidget {
  const ParentTrackedHoverList({super.key});

  @override
  State<ParentTrackedHoverList> createState() => _ParentTrackedHoverListState();
}

class _ParentTrackedHoverListState extends State<ParentTrackedHoverList> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    const items = ['Alpha', 'Bravo', 'Charlie'];
    const itemHeight = 68.0; // Height including padding

    return MouseRegion(
      onHover: (event) {
        final y = event.localPosition.dy;
        final index = (y / itemHeight).floor();
        if (index >= 0 && index < items.length && index != _hoveredIndex) {
          setState(() {
            _hoveredIndex = index;
          });
          print('🔥 Parent tracking: hovering index $index (${items[index]})');
        }
      },
      onExit: (_) {
        setState(() {
          _hoveredIndex = null;
        });
        print('🔥 Parent tracking: exited');
      },
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ParentTrackedItem(
                label: items[i],
                isHovered: _hoveredIndex == i,
              ),
            ),
        ],
      ),
    );
  }
}

class ParentTrackedItem extends StatelessWidget {
  const ParentTrackedItem({
    super.key,
    required this.label,
    required this.isHovered,
  });

  final String label;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    print('🔥 ParentTrackedItem $label: isHovered=$isHovered');

    return GestureDetector(
      onTap: () {
        print('🔥 ParentTrackedItem $label: TAPPED');
      },
      child: Container(
        width: 400,
        height: 60,
        decoration: BoxDecoration(
          color: isHovered ? Colors.orange[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isHovered ? Colors.orange : Colors.grey,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          '$label ${isHovered ? "← PARENT HOVER" : ""}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHovered ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
