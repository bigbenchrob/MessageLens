import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectionPath = _path(
    'lib/essentials/source_scoped_import/application/'
    'message_attachment_joins/'
    'message_attachment_relationship_source_projection.dart',
  );
  final importerPath = _path(
    'lib/essentials/source_scoped_import/application/'
    'message_attachment_joins/message_attachment_join_importer.dart',
  );

  test('Message-Attachment relationship projection has a bounded pure '
      'dependency surface', () {
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
              declaration.name.lexeme ==
              'projectSourceMessageAttachmentRelationship',
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
    'production importer owns endpoint proof and uses one projection afterward',
    () {
      final unit = _parse(importerPath);
      final source = File(importerPath).readAsStringSync();
      final imports = unit.directives
          .whereType<ImportDirective>()
          .map((directive) => directive.uri.stringValue)
          .toSet();

      expect(
        imports,
        contains('message_attachment_relationship_source_projection.dart'),
      );
      expect(
        imports,
        isNot(contains('../../domain/source_scoped_row_key.dart')),
      );

      final visitor = _BoundaryVisitor();
      unit.accept(visitor);
      expect(
        visitor.methodNames.where(
          (name) => name == 'projectSourceMessageAttachmentRelationship',
        ),
        hasLength(1),
      );
      expect(visitor.methodNames, contains('openReadOnly'));
      expect(visitor.methodNames, contains('rawQuery'));
      expect(visitor.methodNames, contains('insertImportBatch'));
      expect(visitor.methodNames, contains('writeTransaction'));
      expect(visitor.methodNames, contains('insertIgnore'));
      expect(visitor.methodNames, contains('publishSourceImportProgress'));
      expect(visitor.methodNames, contains('close'));
      expect(visitor.methodNames, isNot(contains('pack')));
      expect(visitor.declarationNames, contains('_requiredInt'));
      expect(visitor.declarationNames, contains('_nullableEndpointRowId'));

      expect(
        source,
        contains('SELECT maj.ROWID AS source_rowid, maj.message_id, '),
      );
      expect(
        source,
        contains('LEFT JOIN message m ON m.ROWID = maj.message_id '),
      );
      expect(
        source,
        contains('LEFT JOIN attachment a ON a.ROWID = maj.attachment_id '),
      );
      expect(source, contains('WHERE maj.message_id > ?'));
      expect(source, contains('ORDER BY message_id ASC, attachment_id ASC'));
      expect(source, contains("row['existing_message_rowid']"));
      expect(source, contains("row['existing_attachment_rowid']"));
      expect(
        source.indexOf('rawQuery('),
        lessThan(source.indexOf('insertImportBatch(')),
      );
      expect(
        source.indexOf('if (rows.isEmpty)'),
        lessThan(source.indexOf('insertImportBatch(')),
      );
      expect(
        source.indexOf('if (!hasEndpoints)'),
        lessThan(source.indexOf('projectSourceMessageAttachmentRelationship(')),
      );
      for (final ledgerKey in <String>[
        "'message_source_id':",
        "'attachment_source_id':",
        "'source_message_rowid':",
        "'source_attachment_rowid':",
        "'message_ss_id':",
        "'attachment_ss_id':",
        "'batch_id':",
      ]) {
        expect(source, isNot(contains(ledgerKey)));
      }
    },
  );

  test('projection does not own join identity or endpoint evidence', () {
    final unit = _parse(projectionPath);
    final source = File(projectionPath).readAsStringSync();
    final imports = unit.directives.whereType<ImportDirective>().map(
      (directive) => directive.uri.stringValue,
    );

    expect(imports, isNot(contains('message_attachment_join_importer.dart')));
    expect(
      imports.any((uri) => uri?.contains('conversation_graph') == true),
      isFalse,
    );
    expect(source, isNot(contains('source_rowid')));
    expect(source, isNot(contains('existing_message_rowid')));
    expect(source, isNot(contains('existing_attachment_rowid')));
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
