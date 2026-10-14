import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectionPath = _path(
    'lib/essentials/source_scoped_import/application/messages/'
    'message_rich_text_semantic_projection.dart',
  );
  final enricherPath = _path(
    'lib/essentials/source_scoped_import/application/messages/'
    'message_rich_text_enricher.dart',
  );

  test('rich-text semantic projection is synchronous and dependency-free', () {
    final unit = _parse(projectionPath);

    expect(unit.directives.whereType<ImportDirective>(), isEmpty);
    final projection = unit.declarations
        .whereType<FunctionDeclaration>()
        .singleWhere(
          (declaration) =>
              declaration.name.lexeme == 'projectMessageRichTextSemantics',
        );
    expect(projection.functionExpression.body.isAsynchronous, isFalse);
    expect(projection.functionExpression.body.isGenerator, isFalse);

    final visitor = _BoundaryVisitor();
    unit.accept(visitor);
    expect(visitor.awaitCount, 0);
    expect(visitor.methodNames, contains('trim'));
    expect(
      visitor.methodNames,
      isNot(
        contains(
          anyOf(<String>[
            'extractMessageTextsFromBlobs',
            'readMessageTextEnrichmentBlobs',
            'writeTransaction',
            'update',
          ]),
        ),
      ),
    );
  });

  test('the production enricher is the sole projection consumer', () {
    const projectionImport = 'message_rich_text_semantic_projection.dart';
    final consumers = Directory(_path('lib'))
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) {
          final unit = _parse(file.path);
          return unit.directives.whereType<ImportDirective>().any(
            (directive) =>
                directive.uri.stringValue?.endsWith(projectionImport) ?? false,
          );
        })
        .map((file) => file.path)
        .toList(growable: false);

    expect(consumers, <String>[enricherPath]);

    final unit = _parse(enricherPath);
    final visitor = _BoundaryVisitor();
    unit.accept(visitor);
    expect(
      visitor.methodNames.where(
        (name) => name == 'projectMessageRichTextSemantics',
      ),
      hasLength(1),
    );
    expect(visitor.methodNames, isNot(contains('trim')));
    expect(visitor.methodNames, contains('extractMessageTextsFromBlobs'));
    expect(visitor.methodNames, contains('readMessageTextEnrichmentBlobs'));
    expect(visitor.methodNames, contains('writeTransaction'));
    expect(visitor.methodNames, contains('update'));
  });
}

CompilationUnit _parse(String path) {
  return parseString(
    content: File(path).readAsStringSync(),
    path: path,
    throwIfDiagnostics: false,
  ).unit;
}

String _path(String relativePath) {
  return '${Directory.current.path}/$relativePath';
}

final class _BoundaryVisitor extends RecursiveAstVisitor<void> {
  final List<String> methodNames = <String>[];
  int awaitCount = 0;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    awaitCount += 1;
    super.visitAwaitExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    methodNames.add(node.methodName.name);
    super.visitMethodInvocation(node);
  }
}
