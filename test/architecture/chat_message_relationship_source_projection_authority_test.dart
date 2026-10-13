import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectionPath = _path(
    'lib/essentials/source_scoped_import/application/chat_message_joins/'
    'chat_message_relationship_source_projection.dart',
  );
  final importerPath = _path(
    'lib/essentials/source_scoped_import/application/chat_message_joins/'
    'chat_message_join_importer.dart',
  );

  test('Chat-Message relationship projection has a bounded pure dependency '
      'surface', () {
    final unit = _parse(projectionPath);
    final imports = unit.directives
        .whereType<ImportDirective>()
        .map((directive) => directive.uri.stringValue)
        .toSet();

    expect(imports, <String?>{'../../domain/source_scoped_row_key.dart'});
    expect(
      imports.any(
        (uri) =>
            uri == null ||
            RegExp(
              r'(sqflite|drift|riverpod|flutter|dart:io|app_czar|journey|'
              r'archive|reset|environment|importer|graph|database|ledger|'
              r'progress|batch|clock|filesystem)',
            ).hasMatch(uri),
      ),
      isFalse,
    );

    final projection = unit.declarations
        .whereType<FunctionDeclaration>()
        .singleWhere(
          (declaration) =>
              declaration.name.lexeme == 'projectSourceChatMessageRelationship',
        );
    expect(projection.functionExpression.body.isAsynchronous, isFalse);
    expect(projection.functionExpression.body.isGenerator, isFalse);

    final visitor = _BoundaryVisitor();
    unit.accept(visitor);
    expect(visitor.awaitCount, 0);
    expect(visitor.methodNames, contains('pack'));
    expect(visitor.methodNames, isNot(contains('now')));
    expect(visitor.methodNames, isNot(contains('rawQuery')));
    expect(visitor.methodNames, isNot(contains('insertIgnore')));
    expect(visitor.methodNames, isNot(contains('writeTransaction')));
    expect(visitor.methodNames, isNot(contains('publishSourceImportProgress')));
    expect(
      visitor.typeNames,
      isNot(contains(anyOf(<String>['Future', 'Stream']))),
    );
  });

  test(
    'production importer uses one projection after importer-owned admission',
    () {
      final unit = _parse(importerPath);
      final imports = unit.directives
          .whereType<ImportDirective>()
          .map((directive) => directive.uri.stringValue)
          .toSet();

      expect(
        imports,
        contains('chat_message_relationship_source_projection.dart'),
      );
      expect(
        imports,
        isNot(contains('../../domain/source_scoped_row_key.dart')),
      );

      final visitor = _BoundaryVisitor();
      unit.accept(visitor);
      expect(
        visitor.methodNames.where(
          (name) => name == 'projectSourceChatMessageRelationship',
        ),
        hasLength(1),
      );
      expect(visitor.methodNames, contains('rawQuery'));
      expect(visitor.methodNames, contains('writeTransaction'));
      expect(visitor.methodNames, contains('insertIgnore'));
      expect(visitor.methodNames, contains('publishSourceImportProgress'));
      expect(visitor.methodNames, isNot(contains('pack')));
      expect(visitor.declarationNames, contains('_nullableEndpointRowId'));
      expect(visitor.declarationNames, isNot(contains('_requiredInt')));
      expect(visitor.declarationNames, isNot(contains('_nullableInt')));
    },
  );

  test('projection does not depend on importer or graph authorities', () {
    final unit = _parse(projectionPath);
    final imports = unit.directives.whereType<ImportDirective>().map(
      (directive) => directive.uri.stringValue,
    );

    expect(imports, isNot(contains('chat_message_join_importer.dart')));
    expect(
      imports.any((uri) => uri?.contains('conversation_graph') == true),
      isFalse,
    );
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
  final List<String> declarationNames = <String>[];
  final List<String> typeNames = <String>[];
  int awaitCount = 0;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    awaitCount += 1;
    super.visitAwaitExpression(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    declarationNames.add(node.name.lexeme);
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    declarationNames.add(node.name.lexeme);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    methodNames.add(node.methodName.name);
    super.visitMethodInvocation(node);
  }

  @override
  void visitNamedType(NamedType node) {
    typeNames.add(node.name2.lexeme);
    super.visitNamedType(node);
  }
}
