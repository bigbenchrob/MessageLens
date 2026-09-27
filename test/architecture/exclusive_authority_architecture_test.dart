import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

const _genericRoot = 'lib/essentials/exclusive_authority';
const _registryPath =
    '$_genericRoot/application/exclusive_authority_registry_provider.dart';
const _registryGeneratedPath =
    '$_genericRoot/application/exclusive_authority_registry_provider.g.dart';
const _keyPath = '$_genericRoot/domain/exclusive_authority_key.dart';
const _keyTestSupportPath =
    '$_genericRoot/domain/exclusive_authority_key_test_support.dart';
const _registryTestSupportPath =
    '$_genericRoot/application/exclusive_authority_registry_test_support.dart';
const _publicSeamPath = '$_genericRoot/feature_level_providers.dart';
const _diagnosticPath =
    '$_genericRoot/domain/exclusive_authority_registry_state.dart';
const _archiveAdapterPath =
    'lib/essentials/archive_environment/application/'
    'archive_mutation_coordinator_provider.dart';

const _soleProductionKeyRule = 'sole-production-key';
const _friendSeamRule = 'friend-test-seam';
const _dartSyntaxRule = 'dart-syntax';
const _soleAdopterRule = 'sole-production-adopter';
const _providerUseRule = 'provider-lifecycle-and-state-use';
const _registryProofSurfaceRule = 'registry-proof-api-surface';

void main() {
  const productionPolicy = _ExclusiveAuthorityProductionPolicy();

  test('generic essential has no domain or presentation dependencies', () {
    const forbiddenImportFragments = <String>[
      '/onboarding/',
      '/archive_environment/',
      '/db/',
      '/contacts/',
      '/presence/',
      '/features/',
      'fda',
      'recovery',
      'presentation',
      'dart:ffi',
    ];
    final violations = <String>[];

    for (final file in _dartFilesUnder(_genericRoot)) {
      for (final import in _importsIn(file.readAsStringSync())) {
        if (forbiddenImportFragments.any(import.contains)) {
          violations.add('${file.path}: $import');
        }
      }
    }

    expect(violations, isEmpty);
  });

  test('only the registry implementation constructs tenure', () {
    expect(_dartSourcesContaining('ExclusiveAuthorityTenure._('), {
      _registryPath,
    });
  });

  test('production authority boundary matches the unified census', () {
    final violations = productionPolicy.audit(_productionSources());

    expect(violations, isEmpty, reason: _formatViolations(violations));
  });

  group('unified production policy rejects equivalent mutations', () {
    test('second production key with an explicit type', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        '  static const ExclusiveAuthorityKey another = '
            "ExclusiveAuthorityKey._('another');\n"
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
      );
    });

    test('second production key with an inferred type', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        "  static const another = ExclusiveAuthorityKey._('another');\n"
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
      );
    });

    test('getter-created second production key', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        '  static ExclusiveAuthorityKey get another =>\n'
            "      ExclusiveAuthorityKey._('another');\n"
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
      );
    });

    test('private constructor tear-off for a second key', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        '  static final anotherFactory = ExclusiveAuthorityKey._;\n'
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
        detailContains: 'constructor tear-off',
      );
    });

    test('second private named constructor', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        '  const ExclusiveAuthorityKey._secondary(this.diagnosticName);\n\n'
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
      );
    });

    test('public unnamed generative constructor', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        '  const ExclusiveAuthorityKey(this.diagnosticName);\n\n'
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
      );
    });

    test('public named constructor', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        '  const ExclusiveAuthorityKey.named(this.diagnosticName);\n\n'
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
      );
    });

    test('factory constructor returning a key', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        '  factory ExclusiveAuthorityKey.factory() =>\n'
            "      ExclusiveAuthorityKey._('factory');\n\n"
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
      );
    });

    test('redirecting constructor', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        '  const ExclusiveAuthorityKey.redirect(String diagnosticName)\n'
            '      : this._(diagnosticName);\n\n'
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
      );
    });

    test('second construction site using an alternate constructor', () {
      final sources = _validVirtualProductionSources();
      sources[_keyPath] = sources[_keyPath]!.replaceFirst(
        '  final String diagnosticName;',
        '  const ExclusiveAuthorityKey.named(this.diagnosticName);\n\n'
            '  static const another = '
            "ExclusiveAuthorityKey.named('another');\n\n"
            '  final String diagnosticName;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
        detailContains: 'constructor invocation',
      );
    });

    test('typedef alias construction fails at key library boundary', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualKeyLibrary(sources, '''
typedef KeyAlias = ExclusiveAuthorityKey;
const another = KeyAlias._('another');
''');

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
        path: _keyPath,
        detailContains: 'typedef KeyAlias',
      );
    });

    test('transitive typedef alias construction fails at boundary', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualKeyLibrary(sources, '''
typedef KeyAlias1 = ExclusiveAuthorityKey;
typedef KeyAlias2 = KeyAlias1;
const another = KeyAlias2._('another');
''');

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
        path: _keyPath,
        detailContains: 'typedef KeyAlias2',
      );
    });

    test('typedef alias constructor tear-off fails at boundary', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualKeyLibrary(sources, '''
typedef KeyAlias = ExclusiveAuthorityKey;
final constructor = KeyAlias._;
''');

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
        path: _keyPath,
        detailContains: 'variable constructor',
      );
    });

    test('top-level key variable alias fails at boundary', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualKeyLibrary(
        sources,
        'const existingAlias = ExclusiveAuthorityKey.archiveMutation;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
        path: _keyPath,
        detailContains: 'variable existingAlias',
      );
    });

    test('top-level key getter alias fails at boundary', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualKeyLibrary(
        sources,
        'ExclusiveAuthorityKey get keyAlias => '
        'ExclusiveAuthorityKey.archiveMutation;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
        path: _keyPath,
        detailContains: 'getter keyAlias',
      );
    });

    test('top-level key function alias fails at boundary', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualKeyLibrary(
        sources,
        'ExclusiveAuthorityKey keyAlias() => '
        'ExclusiveAuthorityKey.archiveMutation;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _soleProductionKeyRule,
        path: _keyPath,
        detailContains: 'function keyAlias',
      );
    });

    test('friend helper used by another generic production file', () {
      final sources = _validVirtualProductionSources();
      sources['$_genericRoot/application/friend_misuse.dart'] = '''
void misuse() {
  ExclusiveAuthorityRegistryTestSupport.instance;
}
''';

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _friendSeamRule,
      );
    });

    test('additional top-level friend mechanism', () {
      final sources = _validVirtualProductionSources();
      sources[_keyTestSupportPath] =
          '${sources[_keyTestSupportPath]}\n'
          'ExclusiveAuthorityKey anotherTestKey() =>\n'
          '    ExclusiveAuthorityKeyTestSupport.independent;\n';

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _friendSeamRule,
        path: _keyTestSupportPath,
        detailContains: 'function anotherTestKey',
      );
    });

    test('typed mutable friend alias used without known helper spelling', () {
      final sources = _validVirtualProductionSources();
      sources[_keyTestSupportPath] =
          '${sources[_keyTestSupportPath]}\n'
          'ExclusiveAuthorityKey independentAlias =\n'
          '    ExclusiveAuthorityKeyTestSupport.independent;\n';
      sources['$_genericRoot/application/friend_alias_misuse.dart'] = '''
Object readAlias() => independentAlias;
''';

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _friendSeamRule,
        path: _keyTestSupportPath,
        detailContains: 'variable independentAlias',
      );
    });

    test('typed final top-level friend alias', () {
      final sources = _validVirtualProductionSources();
      sources[_keyTestSupportPath] =
          '${sources[_keyTestSupportPath]}\n'
          'final ExclusiveAuthorityKey finalAlias =\n'
          '    ExclusiveAuthorityKeyTestSupport.independent;\n';

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _friendSeamRule,
        path: _keyTestSupportPath,
        detailContains: 'variable finalAlias',
      );
    });

    test('late typed top-level friend variable', () {
      final sources = _validVirtualProductionSources();
      sources[_keyTestSupportPath] =
          '${sources[_keyTestSupportPath]}\n'
          'late ExclusiveAuthorityKey lateAlias;\n';

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _friendSeamRule,
        path: _keyTestSupportPath,
        detailContains: 'variable lateAlias',
      );
    });

    test('top-level friend getter alias', () {
      final sources = _validVirtualProductionSources();
      sources[_keyTestSupportPath] =
          '${sources[_keyTestSupportPath]}\n'
          'ExclusiveAuthorityKey get getterAlias =>\n'
          '    ExclusiveAuthorityKeyTestSupport.independent;\n';

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _friendSeamRule,
        path: _keyTestSupportPath,
        detailContains: 'getter getterAlias',
      );
    });

    test('top-level friend function returning the test key', () {
      final sources = _validVirtualProductionSources();
      sources[_keyTestSupportPath] =
          '${sources[_keyTestSupportPath]}\n'
          'ExclusiveAuthorityKey friendFunction() =>\n'
          '    ExclusiveAuthorityKeyTestSupport.independent;\n';

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _friendSeamRule,
        path: _keyTestSupportPath,
        detailContains: 'function friendFunction',
      );
    });

    test('top-level friend typedef', () {
      final sources = _validVirtualProductionSources();
      sources[_keyTestSupportPath] =
          '${sources[_keyTestSupportPath]}\n'
          'typedef FriendKeyFactory = ExclusiveAuthorityKey Function();\n';

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _friendSeamRule,
        path: _keyTestSupportPath,
        detailContains: 'typedef FriendKeyFactory',
      );
    });

    test('named friend extension', () {
      final sources = _validVirtualProductionSources();
      sources[_keyTestSupportPath] =
          '${sources[_keyTestSupportPath]}\n'
          'extension FriendKeyExtension on ExclusiveAuthorityKey {}\n';

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _friendSeamRule,
        path: _keyTestSupportPath,
        detailContains: 'extension FriendKeyExtension',
      );
    });

    test('direct provider refresh', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualAdapter(
        sources,
        'void refreshAuthority() { '
        'ref.refresh(exclusiveAuthorityRegistryProvider); }',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _providerUseRule,
      );
    });

    test('prefixed provider refresh', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualAdapter(
        sources,
        'void refreshAuthority() { '
        'ref.refresh(authority.exclusiveAuthorityRegistryProvider); }',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _providerUseRule,
      );
    });

    test('provider alias handed to a lifecycle helper', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualAdapter(
        sources,
        'void handOffAuthorityProvider() { '
        'final provider = exclusiveAuthorityRegistryProvider; '
        'invalidateLater(provider); }',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _providerUseRule,
      );
    });

    test('wrapper-mediated provider invalidation', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualAdapter(
        sources,
        'void invalidateAuthority(provider) { ref.invalidate(provider); }\n'
        'void misuseWrapper() { '
        'invalidateAuthority(exclusiveAuthorityRegistryProvider); }',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _providerUseRule,
      );
    });

    test('adapter cannot authorize from diagnosticFor isHeld', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualAdapter(
        sources,
        'bool diagnosticAuthority() => '
        'ref.read(exclusiveAuthorityRegistryProvider)'
        '.diagnosticFor(ExclusiveAuthorityKey.archiveMutation).isHeld;',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _providerUseRule,
      );
    });

    test('adapter cannot branch on stored inferred diagnostic state', () {
      final sources = _validVirtualProductionSources();
      _appendToVirtualAdapter(
        sources,
        'bool inferredDiagnosticAuthority() { '
        'final authorityState = '
        'ref.read(exclusiveAuthorityRegistryProvider); '
        'return authorityState.diagnostics.isNotEmpty; }',
      );

      _expectRuleViolation(
        policy: productionPolicy,
        sources: sources,
        rule: _providerUseRule,
      );
    });

    test('approved notifier and requireCurrent proof path succeeds', () {
      final violations = productionPolicy.audit(
        _validVirtualProductionSources(),
      );

      expect(violations, isEmpty, reason: _formatViolations(violations));
    });

    test('only the two designated friend files remain allowed', () {
      final violations = productionPolicy
          .audit(_validVirtualProductionSources())
          .where((violation) => violation.rule == _friendSeamRule)
          .toList(growable: false);

      expect(violations, isEmpty, reason: _formatViolations(violations));
    });
  });

  test('tenure has no serialization or public release surface', () {
    final registrySource = File(_registryPath).readAsStringSync();

    expect(registrySource, isNot(contains('toJson')));
    expect(registrySource, isNot(contains('fromJson')));
    expect(registrySource, isNot(contains('json_serializable')));
    expect(
      registrySource,
      isNot(RegExp(r'\n  (?:Future<[^>]+>|void) release\w*\(')),
    );
    expect(registrySource, contains('void _releaseScope('));
  });

  test('generic registry exposes no ambient current-tenure lookup', () {
    final registrySource = File(_registryPath).readAsStringSync();

    expect(registrySource, isNot(contains('Zone.current')));
    expect(registrySource, isNot(contains('currentBall')));
    expect(registrySource, isNot(contains('currentTenure')));
    expect(registrySource, contains('void requireCurrent({'));
  });

  test('diagnostics contain no proof object or private identity', () {
    final diagnostics = File(_diagnosticPath).readAsStringSync();

    expect(diagnostics, isNot(contains('ExclusiveAuthorityTenure')));
    expect(diagnostics, isNot(contains('registryIdentity')));
    expect(diagnostics, isNot(contains('tenureIdentity')));
    expect(diagnostics, contains('bool isHeld'));
    expect(diagnostics, contains('int? tenureOccurrence'));
  });

  test('labels and occurrences are never proof equality', () {
    final registrySource = File(_registryPath).readAsStringSync();

    expect(registrySource, isNot(contains('ownerLabel ==')));
    expect(registrySource, isNot(contains('diagnosticOccurrence ==')));
    expect(registrySource, contains('identical(live.tenure, tenure)'));
    expect(
      registrySource,
      contains('identical(tenure._registryIdentity, _registryIdentity)'),
    );
  });

  test('presentation cannot consume tenure as workflow state', () {
    final violations = <String>[];
    for (final file in _dartFilesUnder('lib')) {
      if (!file.path.contains('/presentation/')) {
        continue;
      }
      final source = file.readAsStringSync();
      if (source.contains('ExclusiveAuthorityTenure') ||
          source.contains('exclusiveAuthorityRegistryProvider')) {
        violations.add(file.path);
      }
    }

    expect(violations, isEmpty);
  });

  test('native single-instance authority remains unrelated', () {
    final genericSources = _dartFilesUnder(
      _genericRoot,
    ).map((file) => file.readAsStringSync()).join('\n');

    expect(genericSources, isNot(contains('SingleInstance')));
    expect(genericSources, isNot(contains('flock')));
    expect(genericSources, isNot(contains('ProcessLock')));
  });
}

final class _ExclusiveAuthorityProductionPolicy {
  const _ExclusiveAuthorityProductionPolicy();

  static const _friendPaths = <String>{
    _keyTestSupportPath,
    _registryTestSupportPath,
  };

  static const _genericConsumerSymbols = <String>{
    'ExclusiveAuthorityRegistry',
    'ExclusiveAuthorityTenure',
    'ExclusiveAuthorityKey',
    'ExclusiveAuthorityDiagnostic',
    'ExclusiveAuthorityRegistryState',
    'ExclusiveAuthorityDeniedException',
    'ExclusiveAuthorityProofDeniedException',
    'ExclusiveAuthorityProofDenialReason',
    'exclusiveAuthorityRegistryProvider',
  };

  static const _approvedRegistryMembers = <String>{
    'requireCurrent',
    'runExclusive',
    'runReentrant',
  };

  List<_ArchitectureViolation> audit(Map<String, String> sources) {
    final violations = <_ArchitectureViolation>[];
    final parsedSources = _parseProductionSources(sources, violations);
    _auditProductionKeys(parsedSources, violations);
    _auditFriendSeams(sources, parsedSources, violations);
    _auditProductionAdopters(sources, violations);
    _auditProviderAndProofUse(sources, violations);
    return violations;
  }

  void _auditProductionKeys(
    Map<String, CompilationUnit> parsedSources,
    List<_ArchitectureViolation> violations,
  ) {
    final keyUnit = _requiredParsedSource(
      parsedSources: parsedSources,
      path: _keyPath,
      rule: _soleProductionKeyRule,
      violations: violations,
    );
    final friendUnit = _requiredParsedSource(
      parsedSources: parsedSources,
      path: _keyTestSupportPath,
      rule: _soleProductionKeyRule,
      violations: violations,
    );
    if (keyUnit == null || friendUnit == null) {
      return;
    }

    final keyLibraryDeclarations = _topLevelDeclarationCensus(keyUnit);
    const expectedKeyLibraryDeclarations = <String>{
      'class ExclusiveAuthorityKey',
    };
    if (!_matchesExactDeclarationCensus(
      keyLibraryDeclarations,
      expectedKeyLibraryDeclarations,
    )) {
      violations.add(
        _ArchitectureViolation(
          rule: _soleProductionKeyRule,
          path: _keyPath,
          detail:
              'Privileged key library must declare exactly '
              '$expectedKeyLibraryDeclarations; found '
              '${keyLibraryDeclarations.map((item) => item.description).toList()}.',
        ),
      );
    }

    final keyDeclarations = <({String path, ClassDeclaration declaration})>[];
    for (final entry in parsedSources.entries) {
      for (final declaration
          in entry.value.declarations.whereType<ClassDeclaration>()) {
        if (declaration.name.lexeme == 'ExclusiveAuthorityKey') {
          keyDeclarations.add((path: entry.key, declaration: declaration));
        }
      }
    }
    if (keyDeclarations.length != 1 ||
        (keyDeclarations.length == 1 &&
            keyDeclarations.single.path != _keyPath)) {
      violations.add(
        _ArchitectureViolation(
          rule: _soleProductionKeyRule,
          path: _keyPath,
          detail:
              'Expected exactly one ExclusiveAuthorityKey class declaration '
              'at $_keyPath; found ${keyDeclarations.map((item) => item.path).toList()}.',
        ),
      );
      if (keyDeclarations.length != 1) {
        return;
      }
    }

    final keyDeclaration = keyDeclarations.single.declaration;
    if (keyDeclaration.finalKeyword == null) {
      violations.add(
        const _ArchitectureViolation(
          rule: _soleProductionKeyRule,
          path: _keyPath,
          detail: 'ExclusiveAuthorityKey must remain a final closed type.',
        ),
      );
    }

    final constructors = keyDeclaration.members
        .whereType<ConstructorDeclaration>()
        .toList(growable: false);
    if (constructors.length != 1) {
      violations.add(
        _ArchitectureViolation(
          rule: _soleProductionKeyRule,
          path: _keyPath,
          detail:
              'Expected exactly one approved private generative constructor; '
              'found ${constructors.length}: '
              '${constructors.map(_describeConstructor).toList()}.',
        ),
      );
    }
    for (final constructor in constructors) {
      final redirectsGeneratively = constructor.initializers.any(
        (initializer) => initializer is RedirectingConstructorInvocation,
      );
      final isApproved =
          constructor.name?.lexeme == '_' &&
          constructor.constKeyword != null &&
          constructor.externalKeyword == null &&
          constructor.factoryKeyword == null &&
          constructor.redirectedConstructor == null &&
          !redirectsGeneratively;
      if (!isApproved) {
        violations.add(
          _ArchitectureViolation(
            rule: _soleProductionKeyRule,
            path: _keyPath,
            detail:
                'Unapproved authority-key constructor declaration at offset '
                '${constructor.offset}: ${_describeConstructor(constructor)}. '
                'Only const ExclusiveAuthorityKey._(...) may exist.',
          ),
        );
      }
    }

    final archiveFields = keyDeclaration.members
        .whereType<FieldDeclaration>()
        .expand(
          (field) => field.fields.variables
              .where((variable) => variable.name.lexeme == 'archiveMutation')
              .map((variable) => (field: field, variable: variable)),
        )
        .toList(growable: false);
    final hasCanonicalArchiveField =
        archiveFields.length == 1 &&
        _isCanonicalArchiveMutationField(
          archiveFields.single.field,
          archiveFields.single.variable,
        );
    if (!hasCanonicalArchiveField) {
      violations.add(
        const _ArchitectureViolation(
          rule: _soleProductionKeyRule,
          path: _keyPath,
          detail:
              'archiveMutation must remain the single canonical const field '
              'constructed by ExclusiveAuthorityKey._("archiveMutation").',
        ),
      );
    }

    final constructorNames = constructors
        .map((constructor) => constructor.name?.lexeme ?? 'new')
        .toSet();
    final uses = <_AuthorityKeyConstructionUse>[];
    for (final entry in parsedSources.entries) {
      final visitor = _AuthorityKeyConstructionVisitor(
        path: entry.key,
        constructorNames: constructorNames,
      );
      entry.value.accept(visitor);
      uses.addAll(visitor.uses);
    }
    const expectedUses = <({String path, String constructorName, String kind})>[
      (path: _keyPath, constructorName: '_', kind: 'invocation'),
      (path: _keyTestSupportPath, constructorName: '_', kind: 'invocation'),
    ];
    final remainingUses = uses.toList();
    for (final expected in expectedUses) {
      final matchIndex = remainingUses.indexWhere(
        (use) =>
            use.path == expected.path &&
            use.constructorName == expected.constructorName &&
            use.kind == expected.kind,
      );
      if (matchIndex == -1) {
        violations.add(
          _ArchitectureViolation(
            rule: _soleProductionKeyRule,
            path: expected.path,
            detail:
                'Missing approved ${expected.kind} construction site '
                'ExclusiveAuthorityKey.${expected.constructorName}.',
          ),
        );
      } else {
        remainingUses.removeAt(matchIndex);
      }
    }
    for (final use in remainingUses) {
      violations.add(
        _ArchitectureViolation(
          rule: _soleProductionKeyRule,
          path: use.path,
          detail:
              'Unapproved authority-key constructor ${use.kind} at offset '
              '${use.offset}: ExclusiveAuthorityKey.${use.constructorName}.',
        ),
      );
    }

    final memberUses = <_AuthorityKeyMemberUse>[];
    for (final entry in parsedSources.entries) {
      final visitor = _AuthorityKeyMemberUseVisitor(path: entry.key);
      entry.value.accept(visitor);
      memberUses.addAll(visitor.uses);
    }
    for (final use in memberUses) {
      if (use.path == _keyPath || use.path == _keyTestSupportPath) {
        continue;
      }
      if (use.path != _archiveAdapterPath ||
          use.memberName != 'archiveMutation') {
        violations.add(
          _ArchitectureViolation(
            rule: _soleProductionKeyRule,
            path: use.path,
            detail:
                'Production key member use "${use.memberName}" at offset '
                '${use.offset} is not the approved ArchiveMutationCoordinator '
                'archiveMutation use.',
          ),
        );
      }
    }
  }

  void _auditFriendSeams(
    Map<String, String> sources,
    Map<String, CompilationUnit> parsedSources,
    List<_ArchitectureViolation> violations,
  ) {
    final discoveredFriendPaths = sources.keys
        .where(
          (path) =>
              path.startsWith(_genericRoot) &&
              path.endsWith('_test_support.dart'),
        )
        .toSet();
    if (!_sameSet(discoveredFriendPaths, _friendPaths)) {
      violations.add(
        _ArchitectureViolation(
          rule: _friendSeamRule,
          path: _genericRoot,
          detail:
              'Designated friend files are ${_friendPaths.toList()}; found '
              '${discoveredFriendPaths.toList()}.',
        ),
      );
    }

    final keyFriendSource = _requiredSource(
      sources: sources,
      path: _keyTestSupportPath,
      rule: _friendSeamRule,
      violations: violations,
    );
    final registryFriendSource = _requiredSource(
      sources: sources,
      path: _registryTestSupportPath,
      rule: _friendSeamRule,
      violations: violations,
    );
    final keySource = _requiredSource(
      sources: sources,
      path: _keyPath,
      rule: _friendSeamRule,
      violations: violations,
    );
    final registrySource = _requiredSource(
      sources: sources,
      path: _registryPath,
      rule: _friendSeamRule,
      violations: violations,
    );
    final publicSeam = _requiredSource(
      sources: sources,
      path: _publicSeamPath,
      rule: _friendSeamRule,
      violations: violations,
    );
    if (keyFriendSource == null ||
        registryFriendSource == null ||
        keySource == null ||
        registrySource == null ||
        publicSeam == null) {
      return;
    }

    final keyFriendUnit = _requiredParsedSource(
      parsedSources: parsedSources,
      path: _keyTestSupportPath,
      rule: _friendSeamRule,
      violations: violations,
    );
    final registryFriendUnit = _requiredParsedSource(
      parsedSources: parsedSources,
      path: _registryTestSupportPath,
      rule: _friendSeamRule,
      violations: violations,
    );
    if (keyFriendUnit == null || registryFriendUnit == null) {
      return;
    }

    final keyFriendDeclarations = _topLevelDeclarationCensus(keyFriendUnit);
    final registryFriendDeclarations = _topLevelDeclarationCensus(
      registryFriendUnit,
    );
    const expectedKeyFriendDeclarations = <String>{
      'class ExclusiveAuthorityKeyTestSupport',
    };
    const expectedRegistryFriendDeclarations = <String>{
      'class ExclusiveAuthorityRegistryTestSupport',
      'class ExclusiveAuthorityScopeCleanupTestHandle',
    };
    if (!_matchesExactDeclarationCensus(
      keyFriendDeclarations,
      expectedKeyFriendDeclarations,
    )) {
      violations.add(
        _ArchitectureViolation(
          rule: _friendSeamRule,
          path: _keyTestSupportPath,
          detail:
              'Expected exactly $expectedKeyFriendDeclarations; found '
              '${keyFriendDeclarations.map((item) => item.description).toList()}.',
        ),
      );
    }
    if (!_matchesExactDeclarationCensus(
      registryFriendDeclarations,
      expectedRegistryFriendDeclarations,
    )) {
      violations.add(
        _ArchitectureViolation(
          rule: _friendSeamRule,
          path: _registryTestSupportPath,
          detail:
              'Expected exactly $expectedRegistryFriendDeclarations; found '
              '${registryFriendDeclarations.map((item) => item.description).toList()}.',
        ),
      );
    }

    final expectedRegistryParts = <String>{
      if (sources.containsKey(_registryGeneratedPath))
        'exclusive_authority_registry_provider.g.dart',
      'exclusive_authority_registry_test_support.dart',
    };
    final keyParts = _partDirectiveTargets(keySource);
    final registryParts = _partDirectiveTargets(registrySource);
    if (!_sameSet(keyParts, {'exclusive_authority_key_test_support.dart'})) {
      violations.add(
        _ArchitectureViolation(
          rule: _friendSeamRule,
          path: _keyPath,
          detail: 'Unexpected key-library parts: ${keyParts.toList()}.',
        ),
      );
    }
    if (!_sameSet(registryParts, expectedRegistryParts)) {
      violations.add(
        _ArchitectureViolation(
          rule: _friendSeamRule,
          path: _registryPath,
          detail:
              'Unexpected registry-library parts: ${registryParts.toList()}.',
        ),
      );
    }

    final friendSymbols = <String>{
      ...keyFriendDeclarations.map((declaration) => declaration.name),
      ...registryFriendDeclarations.map((declaration) => declaration.name),
      'testOnlyIndependent',
    };
    for (final entry in sources.entries) {
      if (_friendPaths.contains(entry.key)) {
        continue;
      }
      final code = _withoutComments(entry.value);
      for (final symbol in friendSymbols) {
        if (RegExp('\\b${RegExp.escape(symbol)}\\b').hasMatch(code)) {
          violations.add(
            _ArchitectureViolation(
              rule: _friendSeamRule,
              path: entry.key,
              detail: 'Production reference to test-only symbol "$symbol".',
            ),
          );
        }
      }
    }

    for (final symbol in friendSymbols) {
      if (publicSeam.contains(symbol)) {
        violations.add(
          _ArchitectureViolation(
            rule: _friendSeamRule,
            path: _publicSeamPath,
            detail: 'Public seam exports test-only symbol "$symbol".',
          ),
        );
      }
    }
    if (!publicSeam.contains('show ExclusiveAuthorityKey;')) {
      violations.add(
        const _ArchitectureViolation(
          rule: _friendSeamRule,
          path: _publicSeamPath,
          detail: 'Authority key export must remain narrowed by show.',
        ),
      );
    }
  }

  void _auditProductionAdopters(
    Map<String, String> sources,
    List<_ArchitectureViolation> violations,
  ) {
    final importers = <String>{};
    final symbolConsumers = <String>{};

    for (final entry in sources.entries) {
      if (entry.key.startsWith(_genericRoot)) {
        continue;
      }
      if (_importsIn(
        entry.value,
      ).any((import) => import.contains('exclusive_authority/'))) {
        importers.add(entry.key);
      }
      final code = _withoutComments(entry.value);
      if (_genericConsumerSymbols.any(
        (symbol) => RegExp('\\b${RegExp.escape(symbol)}\\b').hasMatch(code),
      )) {
        symbolConsumers.add(entry.key);
      }
    }

    _requireOnlyApprovedPath(
      paths: importers,
      approvedPath: _archiveAdapterPath,
      rule: _soleAdopterRule,
      kind: 'generic-authority importer',
      violations: violations,
    );
    _requireOnlyApprovedPath(
      paths: symbolConsumers,
      approvedPath: _archiveAdapterPath,
      rule: _soleAdopterRule,
      kind: 'generic-authority symbol consumer',
      violations: violations,
    );
  }

  void _auditProviderAndProofUse(
    Map<String, String> sources,
    List<_ArchitectureViolation> violations,
  ) {
    final publicSeam = _requiredSource(
      sources: sources,
      path: _publicSeamPath,
      rule: _providerUseRule,
      violations: violations,
    );
    final adapterSource = _requiredSource(
      sources: sources,
      path: _archiveAdapterPath,
      rule: _providerUseRule,
      violations: violations,
    );
    if (publicSeam == null || adapterSource == null) {
      return;
    }

    final providerPattern = RegExp(r'\bexclusiveAuthorityRegistryProvider\b');
    for (final entry in sources.entries) {
      final code = _withoutComments(_withoutImportDirectives(entry.value));
      final actualUses = providerPattern.allMatches(code).length;
      final expectedUses = switch (entry.key) {
        _archiveAdapterPath => 1,
        _publicSeamPath => 1,
        _registryGeneratedPath => 2,
        _ => 0,
      };
      if (actualUses != expectedUses) {
        violations.add(
          _ArchitectureViolation(
            rule: _providerUseRule,
            path: entry.key,
            detail:
                'Found $actualUses production provider-object occurrence(s); '
                'expected $expectedUses. Provider aliasing, escape, state '
                'reads, refresh, and invalidation are forbidden.',
          ),
        );
      }
    }

    final adapterCode = _withoutComments(
      _withoutImportDirectives(adapterSource),
    );
    final approvedGetter = RegExp(
      r'ExclusiveAuthorityRegistry\s+get\s+_exclusiveAuthorityRegistry\s*=>\s*ref\s*\.\s*read\s*\(\s*exclusiveAuthorityRegistryProvider\s*\.\s*notifier\s*\)\s*;',
    );
    final getterMatches = approvedGetter.allMatches(adapterCode).toList();
    if (getterMatches.length != 1) {
      violations.add(
        const _ArchitectureViolation(
          rule: _providerUseRule,
          path: _archiveAdapterPath,
          detail:
              'The provider must be consumed exactly once by the approved '
              'notifier getter and must not escape as a provider object.',
        ),
      );
      return;
    }

    final codeWithoutGetter = adapterCode.replaceFirst(approvedGetter, '');
    final accessorPattern = RegExp(r'\b_exclusiveAuthorityRegistry\b');
    final usedMembers = <String>{};
    for (final match in accessorPattern.allMatches(codeWithoutGetter)) {
      final suffix = codeWithoutGetter.substring(match.end);
      final memberCall = RegExp(
        r'^\s*\.\s*([A-Za-z_]\w*)(?:\s*<[^;()]+>)?\s*\(',
      ).firstMatch(suffix);
      if (memberCall == null) {
        violations.add(
          const _ArchitectureViolation(
            rule: _registryProofSurfaceRule,
            path: _archiveAdapterPath,
            detail:
                'Registry notifier escaped instead of being used by an '
                'approved direct proof/acquisition call.',
          ),
        );
        continue;
      }
      final member = memberCall.group(1)!;
      usedMembers.add(member);
      if (!_approvedRegistryMembers.contains(member)) {
        violations.add(
          _ArchitectureViolation(
            rule: _registryProofSurfaceRule,
            path: _archiveAdapterPath,
            detail:
                'Registry member "$member" is outside the approved '
                'proof/acquisition surface $_approvedRegistryMembers.',
          ),
        );
      }
    }

    if (!_sameSet(usedMembers, _approvedRegistryMembers)) {
      violations.add(
        _ArchitectureViolation(
          rule: _registryProofSurfaceRule,
          path: _archiveAdapterPath,
          detail:
              'Expected the explicit registry proof/acquisition members '
              '$_approvedRegistryMembers; found $usedMembers.',
        ),
      );
    }
  }
}

final class _ArchitectureViolation {
  const _ArchitectureViolation({
    required this.rule,
    required this.path,
    required this.detail,
  });

  final String rule;
  final String path;
  final String detail;

  @override
  String toString() => '[$rule] $path: $detail';
}

final class _AuthorityKeyConstructionUse {
  const _AuthorityKeyConstructionUse({
    required this.path,
    required this.constructorName,
    required this.kind,
    required this.offset,
  });

  final String path;
  final String constructorName;
  final String kind;
  final int offset;
}

final class _AuthorityKeyMemberUse {
  const _AuthorityKeyMemberUse({
    required this.path,
    required this.memberName,
    required this.offset,
  });

  final String path;
  final String memberName;
  final int offset;
}

final class _TopLevelDeclaration {
  const _TopLevelDeclaration({required this.name, required this.description});

  final String name;
  final String description;
}

final class _AuthorityKeyConstructionVisitor extends RecursiveAstVisitor<void> {
  _AuthorityKeyConstructionVisitor({
    required this.path,
    required this.constructorNames,
  });

  final String path;
  final Set<String> constructorNames;
  final List<_AuthorityKeyConstructionUse> uses = [];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name2.lexeme == 'ExclusiveAuthorityKey') {
      uses.add(
        _AuthorityKeyConstructionUse(
          path: path,
          constructorName: node.constructorName.name?.name ?? 'new',
          kind: 'invocation',
          offset: node.offset,
        ),
      );
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final constructorName = node.methodName.name;
    if (_isAuthorityKeyReference(node.target) &&
        constructorNames.contains(constructorName)) {
      uses.add(
        _AuthorityKeyConstructionUse(
          path: path,
          constructorName: constructorName,
          kind: 'invocation',
          offset: node.offset,
        ),
      );
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final constructorName = node.identifier.name;
    if (node.prefix.name == 'ExclusiveAuthorityKey' &&
        constructorNames.contains(constructorName)) {
      uses.add(
        _AuthorityKeyConstructionUse(
          path: path,
          constructorName: constructorName,
          kind: 'tear-off',
          offset: node.offset,
        ),
      );
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final constructorName = node.propertyName.name;
    if (_isAuthorityKeyReference(node.target) &&
        constructorNames.contains(constructorName)) {
      uses.add(
        _AuthorityKeyConstructionUse(
          path: path,
          constructorName: constructorName,
          kind: 'tear-off',
          offset: node.offset,
        ),
      );
    }
    super.visitPropertyAccess(node);
  }
}

final class _AuthorityKeyMemberUseVisitor extends RecursiveAstVisitor<void> {
  _AuthorityKeyMemberUseVisitor({required this.path});

  final String path;
  final List<_AuthorityKeyMemberUse> uses = [];

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.name == 'ExclusiveAuthorityKey') {
      uses.add(
        _AuthorityKeyMemberUse(
          path: path,
          memberName: node.identifier.name,
          offset: node.offset,
        ),
      );
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (_isAuthorityKeyReference(node.target)) {
      uses.add(
        _AuthorityKeyMemberUse(
          path: path,
          memberName: node.propertyName.name,
          offset: node.offset,
        ),
      );
    }
    super.visitPropertyAccess(node);
  }
}

Map<String, CompilationUnit> _parseProductionSources(
  Map<String, String> sources,
  List<_ArchitectureViolation> violations,
) {
  final parsedSources = <String, CompilationUnit>{};
  for (final entry in sources.entries) {
    final result = parseString(
      content: entry.value,
      path: entry.key,
      throwIfDiagnostics: false,
    );
    if (result.errors.isNotEmpty) {
      violations.add(
        _ArchitectureViolation(
          rule: _dartSyntaxRule,
          path: entry.key,
          detail: result.errors
              .map(
                (error) =>
                    '${error.errorCode.name}@${error.offset}: ${error.message}',
              )
              .join('; '),
        ),
      );
      continue;
    }
    parsedSources[entry.key] = result.unit;
  }
  return parsedSources;
}

CompilationUnit? _requiredParsedSource({
  required Map<String, CompilationUnit> parsedSources,
  required String path,
  required String rule,
  required List<_ArchitectureViolation> violations,
}) {
  final unit = parsedSources[path];
  if (unit == null) {
    violations.add(
      _ArchitectureViolation(
        rule: rule,
        path: path,
        detail: 'Required source did not produce a valid Dart syntax tree.',
      ),
    );
  }
  return unit;
}

String _describeConstructor(ConstructorDeclaration constructor) {
  final name = constructor.name?.lexeme ?? 'new';
  final visibility = name.startsWith('_') ? 'private' : 'public';
  final kind = constructor.factoryKeyword == null ? 'generative' : 'factory';
  final redirection =
      constructor.redirectedConstructor != null ||
          constructor.initializers.any(
            (initializer) => initializer is RedirectingConstructorInvocation,
          )
      ? ', redirecting'
      : '';
  final constness = constructor.constKeyword == null ? 'non-const' : 'const';
  return '$constness $visibility $kind ExclusiveAuthorityKey.$name$redirection';
}

bool _isCanonicalArchiveMutationField(
  FieldDeclaration field,
  VariableDeclaration variable,
) {
  final initializer = variable.initializer;
  if (!field.isStatic || !field.fields.isConst || initializer == null) {
    return false;
  }
  final arguments = switch (initializer) {
    InstanceCreationExpression()
        when initializer.constructorName.type.name2.lexeme ==
                'ExclusiveAuthorityKey' &&
            initializer.constructorName.name?.name == '_' =>
      initializer.argumentList.arguments,
    MethodInvocation()
        when _isAuthorityKeyReference(initializer.target) &&
            initializer.methodName.name == '_' =>
      initializer.argumentList.arguments,
    _ => null,
  };
  return arguments != null &&
      arguments.length == 1 &&
      arguments.single is SimpleStringLiteral &&
      (arguments.single as SimpleStringLiteral).value == 'archiveMutation';
}

bool _isAuthorityKeyReference(Expression? expression) {
  return switch (expression) {
    SimpleIdentifier() => expression.name == 'ExclusiveAuthorityKey',
    PrefixedIdentifier() =>
      expression.identifier.name == 'ExclusiveAuthorityKey',
    _ => false,
  };
}

List<_TopLevelDeclaration> _topLevelDeclarationCensus(CompilationUnit unit) {
  final declarations = <_TopLevelDeclaration>[];
  for (final declaration in unit.declarations) {
    switch (declaration) {
      case ClassDeclaration():
        declarations.add(
          _TopLevelDeclaration(
            name: declaration.name.lexeme,
            description: 'class ${declaration.name.lexeme}',
          ),
        );
      case EnumDeclaration():
        declarations.add(
          _TopLevelDeclaration(
            name: declaration.name.lexeme,
            description: 'enum ${declaration.name.lexeme}',
          ),
        );
      case MixinDeclaration():
        declarations.add(
          _TopLevelDeclaration(
            name: declaration.name.lexeme,
            description: 'mixin ${declaration.name.lexeme}',
          ),
        );
      case ExtensionTypeDeclaration():
        declarations.add(
          _TopLevelDeclaration(
            name: declaration.name.lexeme,
            description: 'extension type ${declaration.name.lexeme}',
          ),
        );
      case ExtensionDeclaration():
        final name = declaration.name?.lexeme;
        declarations.add(
          _TopLevelDeclaration(
            name: name ?? '<unnamed-extension@${declaration.offset}>',
            description: name == null
                ? 'unnamed extension at offset ${declaration.offset}'
                : 'extension $name',
          ),
        );
      case FunctionDeclaration():
        final kind = declaration.isGetter
            ? 'getter'
            : declaration.isSetter
            ? 'setter'
            : 'function';
        declarations.add(
          _TopLevelDeclaration(
            name: declaration.name.lexeme,
            description: '$kind ${declaration.name.lexeme}',
          ),
        );
      case TopLevelVariableDeclaration():
        for (final variable in declaration.variables.variables) {
          declarations.add(
            _TopLevelDeclaration(
              name: variable.name.lexeme,
              description: 'variable ${variable.name.lexeme}',
            ),
          );
        }
      case TypeAlias():
        declarations.add(
          _TopLevelDeclaration(
            name: declaration.name.lexeme,
            description: 'typedef ${declaration.name.lexeme}',
          ),
        );
      default:
        declarations.add(
          _TopLevelDeclaration(
            name: '<${declaration.runtimeType}@${declaration.offset}>',
            description:
                'unsupported ${declaration.runtimeType} at offset '
                '${declaration.offset}',
          ),
        );
    }
  }
  return declarations;
}

bool _matchesExactDeclarationCensus(
  List<_TopLevelDeclaration> actual,
  Set<String> expected,
) {
  final descriptions = actual
      .map((declaration) => declaration.description)
      .toSet();
  return actual.length == expected.length && _sameSet(descriptions, expected);
}

String? _requiredSource({
  required Map<String, String> sources,
  required String path,
  required String rule,
  required List<_ArchitectureViolation> violations,
}) {
  final source = sources[path];
  if (source == null) {
    violations.add(
      _ArchitectureViolation(
        rule: rule,
        path: path,
        detail: 'Required production source is missing from the census.',
      ),
    );
  }
  return source;
}

void _requireOnlyApprovedPath({
  required Set<String> paths,
  required String approvedPath,
  required String rule,
  required String kind,
  required List<_ArchitectureViolation> violations,
}) {
  if (!paths.contains(approvedPath)) {
    violations.add(
      _ArchitectureViolation(
        rule: rule,
        path: approvedPath,
        detail: 'Approved $kind is missing from the production census.',
      ),
    );
  }
  for (final path in paths.where((path) => path != approvedPath)) {
    violations.add(
      _ArchitectureViolation(
        rule: rule,
        path: path,
        detail: 'Unapproved $kind; only $approvedPath is allowed.',
      ),
    );
  }
}

Map<String, String> _productionSources() {
  return Map<String, String>.fromEntries(
    _dartFilesUnder(
      'lib',
    ).map((file) => MapEntry(file.path, file.readAsStringSync())),
  );
}

Map<String, String> _validVirtualProductionSources() {
  return <String, String>{
    _keyPath: '''
part 'exclusive_authority_key_test_support.dart';

final class ExclusiveAuthorityKey {
  const ExclusiveAuthorityKey._(this.diagnosticName);

  static const archiveMutation = ExclusiveAuthorityKey._('archiveMutation');

  final String diagnosticName;
}
''',
    _keyTestSupportPath: '''
part of 'exclusive_authority_key.dart';

abstract final class ExclusiveAuthorityKeyTestSupport {
  static const independent = ExclusiveAuthorityKey._('testOnlyIndependent');
}
''',
    _registryPath: '''
part 'exclusive_authority_registry_test_support.dart';

final class ExclusiveAuthorityRegistry {}
final class ExclusiveAuthorityTenure {}
''',
    _registryTestSupportPath: '''
part of 'exclusive_authority_registry_provider.dart';

final class ExclusiveAuthorityScopeCleanupTestHandle {}
final class ExclusiveAuthorityRegistryTestSupport {}
''',
    _publicSeamPath: '''
export 'application/exclusive_authority_registry_provider.dart'
    show ExclusiveAuthorityRegistry, ExclusiveAuthorityTenure,
        exclusiveAuthorityRegistryProvider;
export 'domain/exclusive_authority_key.dart' show ExclusiveAuthorityKey;
''',
    _archiveAdapterPath: '''
import '../../exclusive_authority/feature_level_providers.dart'
    show ExclusiveAuthorityKey, ExclusiveAuthorityRegistry,
        ExclusiveAuthorityTenure, exclusiveAuthorityRegistryProvider;

final class ArchiveMutationCoordinator {
  ExclusiveAuthorityRegistry get _exclusiveAuthorityRegistry =>
      ref.read(exclusiveAuthorityRegistryProvider.notifier);

  Future<void> acquire(ExclusiveAuthorityTenure tenure) async {
    await _exclusiveAuthorityRegistry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'owner',
      action: (_) async {},
    );
    await _exclusiveAuthorityRegistry.runReentrant<void>(
      tenure: tenure,
      action: () async {},
    );
    _exclusiveAuthorityRegistry.requireCurrent(
      authority: ExclusiveAuthorityKey.archiveMutation,
      tenure: tenure,
    );
  }
}
''',
  };
}

void _appendToVirtualAdapter(Map<String, String> sources, String addition) {
  sources[_archiveAdapterPath] = '${sources[_archiveAdapterPath]}\n$addition\n';
}

void _appendToVirtualKeyLibrary(Map<String, String> sources, String addition) {
  sources[_keyPath] = '${sources[_keyPath]}\n$addition\n';
}

void _expectRuleViolation({
  required _ExclusiveAuthorityProductionPolicy policy,
  required Map<String, String> sources,
  required String rule,
  String? path,
  String? detailContains,
}) {
  final violations = policy
      .audit(sources)
      .where(
        (violation) =>
            violation.rule == rule &&
            (path == null || violation.path == path) &&
            (detailContains == null ||
                violation.detail.contains(detailContains)),
      )
      .toList(growable: false);
  expect(
    violations,
    isNotEmpty,
    reason:
        'Expected rule $rule to reject the mutation'
        '${path == null ? '' : ' at $path'}'
        '${detailContains == null ? '' : ' with "$detailContains"'}.',
  );
}

Set<String> _importsIn(String source) {
  return RegExp(
    r'''^\s*import\s+['"]([^'"]+)['"]''',
    multiLine: true,
  ).allMatches(source).map((match) => match.group(1)!).toSet();
}

Set<String> _partDirectiveTargets(String source) {
  return RegExp(
    r'''^\s*part\s+['"]([^'"]+)['"]\s*;''',
    multiLine: true,
  ).allMatches(source).map((match) => match.group(1)!).toSet();
}

String _withoutImportDirectives(String source) {
  return source.replaceAll(
    RegExp(r'''^\s*import\s+['"][^'"]+['"][\s\S]*?;''', multiLine: true),
    '',
  );
}

String _withoutComments(String source) {
  return source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'//[^\n]*'), '');
}

bool _sameSet(Set<String> left, Set<String> right) {
  return left.length == right.length && left.containsAll(right);
}

String _formatViolations(Iterable<_ArchitectureViolation> violations) {
  return violations.map((violation) => violation.toString()).join('\n');
}

Set<String> _dartSourcesContaining(String needle) {
  final paths = <String>{};
  for (final file in _dartFilesUnder('lib')) {
    if (file.readAsStringSync().contains(needle)) {
      paths.add(file.path);
    }
  }
  return paths;
}

List<File> _dartFilesUnder(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);
}
