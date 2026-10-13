import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectionPath = _path(
    'lib/essentials/source_scoped_import/application/attachments/'
    'attachment_source_projection.dart',
  );
  final importerPath = _path(
    'lib/essentials/source_scoped_import/application/attachments/'
    'attachment_importer.dart',
  );

  test(
    'Attachments source projection has a bounded pure dependency surface',
    () {
      final unit = _parse(projectionPath);
      final imports = unit.directives
          .whereType<ImportDirective>()
          .map((directive) => directive.uri.stringValue)
          .toSet();

      expect(imports, <String?>{
        '../../../../core/util/date_converter.dart',
        '../../domain/source_scoped_row_key.dart',
      });
      expect(
        imports.any(
          (uri) =>
              uri == null ||
              RegExp(
                r'(sqflite|drift|riverpod|flutter|dart:io|app_czar|journey|'
                r'archive|reset|environment|importer|graph|payload|filesystem)',
              ).hasMatch(uri),
        ),
        isFalse,
      );

      final projection = unit.declarations
          .whereType<FunctionDeclaration>()
          .singleWhere(
            (declaration) =>
                declaration.name.lexeme == 'projectSourceAttachment',
          );
      expect(projection.functionExpression.body.isAsynchronous, isFalse);
      expect(projection.functionExpression.body.isGenerator, isFalse);

      final visitor = _BoundaryVisitor();
      unit.accept(visitor);
      expect(visitor.awaitCount, 0);
      expect(visitor.methodNames, isNot(contains('now')));
      expect(visitor.methodNames, contains('pack'));
      expect(visitor.methodNames, contains('appleToIsoString'));
      expect(visitor.methodNames, isNot(contains('insertIgnore')));
      expect(visitor.methodNames, isNot(contains('writeTransaction')));
      expect(visitor.methodNames, isNot(contains('exists')));
      expect(visitor.methodNames, isNot(contains('readAsBytes')));
    },
  );

  test('production Attachments importer uses the one canonical projection', () {
    final unit = _parse(importerPath);
    final imports = unit.directives
        .whereType<ImportDirective>()
        .map((directive) => directive.uri.stringValue)
        .toSet();

    expect(imports, contains('attachment_source_projection.dart'));
    expect(imports, isNot(contains('../../domain/source_scoped_row_key.dart')));
    expect(
      imports,
      isNot(contains('../../../../core/util/date_converter.dart')),
    );

    final visitor = _BoundaryVisitor();
    unit.accept(visitor);
    expect(
      visitor.methodNames.where((name) => name == 'projectSourceAttachment'),
      hasLength(1),
    );
    expect(visitor.methodNames, contains('rawQuery'));
    expect(visitor.methodNames, contains('insertImportBatch'));
    expect(visitor.methodNames, contains('writeTransaction'));
    expect(visitor.methodNames, contains('insertIgnore'));
    expect(visitor.methodNames, contains('publishSourceImportProgress'));
    expect(
      visitor.declarationNames,
      isNot(
        contains(
          anyOf(<String>[
            '_requiredInt',
            '_nullableInt',
            '_nullableString',
            '_hasNoDescriptiveMetadata',
          ]),
        ),
      ),
    );
    expect(visitor.methodNames, isNot(contains('pack')));
    expect(visitor.methodNames, isNot(contains('appleToIsoString')));
  });

  test(
    'projection does not depend on mutation, payload, or archive owners',
    () {
      final unit = _parse(projectionPath);
      final imports = unit.directives.whereType<ImportDirective>().map(
        (directive) => directive.uri.stringValue,
      );

      expect(imports, isNot(contains('attachment_importer.dart')));
      expect(
        imports.any(
          (uri) =>
              uri?.contains('attachment_archive') == true ||
              uri?.contains('message_attachment') == true,
        ),
        isFalse,
      );
    },
  );
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
