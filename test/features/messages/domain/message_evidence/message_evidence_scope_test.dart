import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';

void main() {
  group('message search scope execution identity', () {
    test('keeps prefix and exact searches distinct', () {
      const prefix = MessageSearchEvidenceScope(query: 'post');
      const exact = MessageSearchEvidenceScope(query: 'post ');

      expect(prefix, isNot(exact));
      expect(prefix.stableKey, isNot(exact.stableKey));
    });

    test('shares identity for raw spacing with equivalent parsed intent', () {
      const first = MessageSearchEvidenceScope(query: '  post ');
      const second = MessageSearchEvidenceScope(query: 'post    ');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.stableKey, second.stableKey);
    });

    test('contact search scopes use the same structured identity', () {
      const prefix = ContactMessageSearchEvidenceScope(
        contactId: 7,
        query: 'post',
      );
      const exact = ContactMessageSearchEvidenceScope(
        contactId: 7,
        query: 'post ',
      );
      const equivalentExact = ContactMessageSearchEvidenceScope(
        contactId: 7,
        query: '  post   ',
      );

      expect(prefix, isNot(exact));
      expect(exact, equivalentExact);
      expect(exact.stableKey, equivalentExact.stableKey);
    });
  });
}
