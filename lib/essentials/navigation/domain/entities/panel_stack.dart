import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'view_spec.dart';

@immutable
class PanelPage {
  const PanelPage({
    required this.id,
    required this.spec,
    required this.title,
    this.isClosable = true,
  });

  final String id;
  final ViewSpec spec;
  final String title;
  final bool isClosable;

  PanelPage copyWith({
    String? id,
    ViewSpec? spec,
    String? title,
    bool? isClosable,
  }) {
    return PanelPage(
      id: id ?? this.id,
      spec: spec ?? this.spec,
      title: title ?? this.title,
      isClosable: isClosable ?? this.isClosable,
    );
  }
}

@immutable
class PanelStack {
  const PanelStack({required this.pages, this.activeIndex = 0})
    : assert(activeIndex >= 0);

  const PanelStack.empty() : this(pages: const <PanelPage>[]);

  final List<PanelPage> pages;
  final int activeIndex;

  bool get isEmpty => pages.isEmpty;

  PanelPage? get activePage {
    if (isEmpty) {
      return null;
    }
    final index = math.min(activeIndex, pages.length - 1);
    return pages[index];
  }

  PanelStack replaceWithSingle(PanelPage page) {
    return PanelStack(pages: <PanelPage>[page]);
  }

  PanelStack push(PanelPage page) {
    final updated = <PanelPage>[...pages, page];
    return PanelStack(pages: updated, activeIndex: updated.length - 1);
  }

  PanelStack activate(int index) {
    if (index < 0 || index >= pages.length) {
      return this;
    }
    return PanelStack(pages: pages, activeIndex: index);
  }

  PanelStack pop() {
    if (pages.isEmpty) {
      return this;
    }
    final updated = List<PanelPage>.of(pages)..removeLast();
    if (updated.isEmpty) {
      return const PanelStack.empty();
    }
    final nextIndex = math.min(activeIndex, updated.length - 1);
    return PanelStack(pages: updated, activeIndex: nextIndex);
  }

  PanelStack removeAt(int index) {
    if (index < 0 || index >= pages.length) {
      return this;
    }
    final updated = List<PanelPage>.of(pages)..removeAt(index);
    if (updated.isEmpty) {
      return const PanelStack.empty();
    }
    final nextIndex = math.min(activeIndex, updated.length - 1);
    return PanelStack(pages: updated, activeIndex: nextIndex);
  }
}
