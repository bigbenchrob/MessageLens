import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectionPath = _path(
    'lib/essentials/source_scoped_import/application/contacts/'
    'contact_source_projection.dart',
  );
  final importerPath = _path(
    'lib/essentials/source_scoped_import/application/contacts/'
    'contact_importer.dart',
  );

  test('contact source projection has a bounded pure dependency surface', () {
    final unit = _parse(projectionPath);
    final imports = unit.directives
        .whereType<ImportDirective>()
        .map((directive) => directive.uri.stringValue)
        .toSet();

    expect(imports, <String?>{
      '../../../../core/util/date_converter.dart',
      '../../../db/shared/handle_identifier_utils.dart',
      '../../domain/source_scoped_row_key.dart',
    });
    expect(
      imports.any(
        (uri) =>
            uri == null ||
            RegExp(
              r'(sqflite|drift|riverpod|flutter|dart:io|app_czar|journey|'
              r'archive|reset|environment)',
            ).hasMatch(uri),
      ),
      isFalse,
    );

    final declarations = unit.declarations.whereType<FunctionDeclaration>();
    final contactProjection = declarations.singleWhere(
      (declaration) => declaration.name.lexeme == 'projectSourceContact',
    );
    final channelProjection = declarations.singleWhere(
      (declaration) => declaration.name.lexeme == 'projectSourceContactChannel',
    );
    for (final declaration in <FunctionDeclaration>[
      contactProjection,
      channelProjection,
    ]) {
      expect(declaration.functionExpression.body.isAsynchronous, isFalse);
      expect(declaration.functionExpression.body.isGenerator, isFalse);
    }

    final visitor = _BoundaryVisitor();
    unit.accept(visitor);
    expect(visitor.awaitCount, 0);
    expect(visitor.methodNames, isNot(contains('now')));
    expect(visitor.methodNames, contains('pack'));
    expect(visitor.methodNames, contains('appleToIsoString'));
    expect(visitor.methodNames, contains('normalizeHandleIdentifier'));
  });

  test('production importer uses only the shared canonical projections', () {
    final unit = _parse(importerPath);
    final imports = unit.directives
        .whereType<ImportDirective>()
        .map((directive) => directive.uri.stringValue)
        .toSet();
    expect(imports, contains('contact_source_projection.dart'));
    expect(imports, isNot(contains('../../domain/source_scoped_row_key.dart')));

    final visitor = _BoundaryVisitor();
    unit.accept(visitor);
    expect(
      visitor.methodNames.where((name) => name == 'projectSourceContact'),
      hasLength(1),
    );
    expect(
      visitor.methodNames.where(
        (name) => name == 'projectSourceContactChannel',
      ),
      hasLength(2),
    );
    expect(
      visitor.methodNames,
      isNot(
        contains(
          anyOf(<String>[
            'readTrimmedContactSourceText',
            'buildContactDisplayName',
            'projectContactEmailAddress',
            'projectContactPhoneNumber',
            'projectContactCreatedAtUtc',
            'pack',
          ]),
        ),
      ),
    );
    expect(visitor.declarationNames, isNot(contains('_readNullableInt')));
    expect(visitor.declarationNames, isNot(contains('_insertChannel')));
  });

  test('projection does not depend on the mutating importer', () {
    final unit = _parse(projectionPath);
    final imports = unit.directives.whereType<ImportDirective>().map(
      (directive) => directive.uri.stringValue,
    );

    expect(imports, isNot(contains('contact_importer.dart')));
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
