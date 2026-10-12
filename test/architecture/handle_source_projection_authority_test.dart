import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectionPath = _path(
    'lib/essentials/source_scoped_import/application/handles/'
    'handle_source_projection.dart',
  );
  final importerPath = _path(
    'lib/essentials/source_scoped_import/application/handles/'
    'handle_importer.dart',
  );

  test('Handles source projection has a bounded pure dependency surface', () {
    final unit = _parse(projectionPath);
    final imports = unit.directives
        .whereType<ImportDirective>()
        .map((directive) => directive.uri.stringValue)
        .toSet();

    expect(imports, <String?>{
      '../../../db/shared/handle_identifier_utils.dart',
      '../../domain/source_scoped_row_key.dart',
    });
    expect(
      imports.any(
        (uri) =>
            uri == null ||
            RegExp(
              r'(sqflite|drift|riverpod|flutter|dart:io|app_czar|journey|'
              r'archive|reset|environment|importer|graph|contact)',
            ).hasMatch(uri),
      ),
      isFalse,
    );

    final projection = unit.declarations
        .whereType<FunctionDeclaration>()
        .singleWhere(
          (declaration) => declaration.name.lexeme == 'projectSourceHandle',
        );
    expect(projection.functionExpression.body.isAsynchronous, isFalse);
    expect(projection.functionExpression.body.isGenerator, isFalse);

    final visitor = _BoundaryVisitor();
    unit.accept(visitor);
    expect(visitor.awaitCount, 0);
    expect(visitor.methodNames, isNot(contains('now')));
    expect(visitor.methodNames, contains('pack'));
    expect(visitor.methodNames, isNot(contains('insertIgnore')));
    expect(visitor.methodNames, isNot(contains('update')));
    expect(visitor.methodNames, isNot(contains('writeTransaction')));
  });

  test('production Handles importer uses the one canonical projection', () {
    final unit = _parse(importerPath);
    final imports = unit.directives
        .whereType<ImportDirective>()
        .map((directive) => directive.uri.stringValue)
        .toSet();

    expect(imports, contains('handle_source_projection.dart'));
    expect(imports, isNot(contains('../../domain/source_scoped_row_key.dart')));

    final visitor = _BoundaryVisitor();
    unit.accept(visitor);
    expect(
      visitor.methodNames.where((name) => name == 'projectSourceHandle'),
      hasLength(1),
    );
    expect(visitor.methodNames, contains('rawQuery'));
    expect(visitor.methodNames, contains('writeTransaction'));
    expect(visitor.methodNames, contains('insertIgnore'));
    expect(visitor.methodNames, contains('update'));
    expect(visitor.methodNames, contains('publishSourceImportProgress'));
    expect(
      visitor.declarationNames,
      containsAll(<String>[
        'reconcileLocalAccountIdentity',
        '_readLocalAccountHandleKeys',
        '_handleGroupingKey',
      ]),
    );
    expect(visitor.declarationNames, isNot(contains('_interpretIdentifier')));
    expect(visitor.methodNames, isNot(contains('pack')));
  });

  test('projection does not depend on mutating or graph authorities', () {
    final unit = _parse(projectionPath);
    final imports = unit.directives.whereType<ImportDirective>().map(
      (directive) => directive.uri.stringValue,
    );

    expect(imports, isNot(contains('handle_importer.dart')));
    expect(
      imports.any(
        (uri) => uri?.contains('handle_projection_repository.dart') ?? false,
      ),
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
}
