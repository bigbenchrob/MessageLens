# Stray Handles Management — Test Plan

> **Branch:** `Ftr.strays`  
> **Last updated:** 2026-02-22

---

## Unit Tests

### Handle Normalization

```dart
// test/features/handles/domain/normalize_handle_test.dart

group('normalizeHandleIdentifier', () {
  test('phone: strips formatting', () {
    expect(normalizeHandleIdentifier('(604) 828-6252'), equals('6048286252'));
    expect(normalizeHandleIdentifier('+1 604-828-6252'), equals('+16048286252'));
    expect(normalizeHandleIdentifier('604.828.6252'), equals('6048286252'));
  });
  
  test('phone: preserves leading +', () {
    expect(normalizeHandleIdentifier('+16048286252'), equals('+16048286252'));
  });
  
  test('email: lowercases', () {
    expect(normalizeHandleIdentifier('Test@Example.COM'), equals('test@example.com'));
  });
  
  test('email: trims whitespace', () {
    expect(normalizeHandleIdentifier('  test@example.com  '), equals('test@example.com'));
  });
  
  test('short code: preserved as-is', () {
    expect(normalizeHandleIdentifier('72345'), equals('72345'));
  });
});
```

### Junk Score Calculator

```dart
// test/features/handles/domain/junk_score_test.dart

group('calculateJunkScore', () {
  test('short code scores +3', () {
    final handle = StrayHandleSummary(handleValue: '72345', totalMessages: 5, ...);
    expect(calculateJunkScore(handle, []), greaterThanOrEqualTo(3));
  });
  
  test('single message scores +2', () {
    final handle = StrayHandleSummary(totalMessages: 1, ...);
    expect(calculateJunkScore(handle, []), greaterThanOrEqualTo(2));
  });
  
  test('OTP keywords score +2', () {
    final messages = [MessageSummary(text: 'Your verification code is 123456')];
    expect(calculateJunkScore(anyHandle, messages), greaterThanOrEqualTo(2));
  });
  
  test('unsubscribe keywords score +2', () {
    final messages = [MessageSummary(text: 'Reply STOP to unsubscribe')];
    expect(calculateJunkScore(anyHandle, messages), greaterThanOrEqualTo(2));
  });
  
  test('typical spam pattern scores >= 3', () {
    final handle = StrayHandleSummary(handleValue: '22395', totalMessages: 1, ...);
    final messages = [MessageSummary(text: 'Your code is 123456')];
    expect(calculateJunkScore(handle, messages), greaterThanOrEqualTo(3));
  });
  
  test('legitimate contact scores < 3', () {
    final handle = StrayHandleSummary(handleValue: '+16048286252', totalMessages: 47, ...);
    final messages = [MessageSummary(text: 'See you on Sunday!')];
    expect(calculateJunkScore(handle, messages), lessThan(3));
  });
});
```

---

## Integration Tests

### Dismissal Persistence

```dart
// test/features/handles/infrastructure/dismissal_persistence_test.dart

group('dismissal persistence', () {
  test('dismissal survives database close/reopen', () async {
    final overlayDb = await openTestOverlayDb();
    
    await overlayDb.dismissHandle('+16048286252');
    await overlayDb.close();
    
    final reopened = await openTestOverlayDb();
    final isDismissed = await reopened.isHandleDismissed('+16048286252');
    
    expect(isDismissed, isTrue);
  });
  
  test('dismissal keyed by normalized value', () async {
    final overlayDb = await openTestOverlayDb();
    
    // Dismiss with one format
    await overlayDb.dismissHandle('+1 (604) 828-6252');
    
    // Check with different format
    final isDismissed = await overlayDb.isHandleDismissed('6048286252');
    
    expect(isDismissed, isTrue);
  });
  
  test('restore clears dismissal', () async {
    final overlayDb = await openTestOverlayDb();
    
    await overlayDb.dismissHandle('+16048286252');
    await overlayDb.restoreHandle('+16048286252');
    
    final isDismissed = await overlayDb.isHandleDismissed('+16048286252');
    
    expect(isDismissed, isFalse);
  });
});
```

### Provider Exclusion

```dart
// test/features/handles/infrastructure/stray_handles_exclusion_test.dart

group('strayHandlesProvider exclusion', () {
  test('dismissed handles excluded from strayHandlesProvider', () async {
    // Setup: create handle with messages, then dismiss
    await setupTestHandle(handleId: 1, handleValue: '+16048286252');
    await overlayDb.dismissHandle('+16048286252');
    
    final strays = await container.read(strayHandlesProvider.future);
    
    expect(strays.map((h) => h.handleId), isNot(contains(1)));
  });
  
  test('dismissed handles included in dismissedHandlesProvider', () async {
    await setupTestHandle(handleId: 1, handleValue: '+16048286252');
    await overlayDb.dismissHandle('+16048286252');
    
    final dismissed = await container.read(dismissedHandlesProvider.future);
    
    expect(dismissed.map((h) => h.handleId), contains(1));
  });
});
```

### Search Exclusion

```dart
// test/features/messages/infrastructure/search_exclusion_test.dart

group('search excludes dismissed handles', () {
  test('dismissed handle messages not in search results', () async {
    // Setup: message from handle with unique text
    await insertTestMessage(
      handleId: 1,
      handleValue: '+16048286252',
      text: 'UniqueTestPhrase12345',
    );
    
    // Before dismiss: searchable
    var results = await searchMessages('UniqueTestPhrase12345');
    expect(results, isNotEmpty);
    
    // Dismiss handle
    await overlayDb.dismissHandle('+16048286252');
    
    // After dismiss: not searchable
    results = await searchMessages('UniqueTestPhrase12345');
    expect(results, isEmpty);
  });
});
```

### All Messages Exclusion

```dart
// test/features/messages/infrastructure/all_messages_exclusion_test.dart

group('All Messages excludes dismissed handles', () {
  test('dismissed handle messages not in global timeline', () async {
    final messageId = await insertTestMessage(
      handleId: 1,
      handleValue: '+16048286252',
    );
    
    // Before dismiss: in timeline
    var timeline = await container.read(globalTimelineProvider.future);
    expect(timeline.map((m) => m.id), contains(messageId));
    
    // Dismiss handle
    await overlayDb.dismissHandle('+16048286252');
    
    // After dismiss: not in timeline
    timeline = await container.read(globalTimelineProvider.future);
    expect(timeline.map((m) => m.id), isNot(contains(messageId)));
  });
});
```

---

## Acceptance Tests (Manual)

### AT-1: Blitz Dismiss Workflow

**Preconditions:**
- App has 20+ stray handles
- At least 10 match spam heuristics

**Steps:**
1. Navigate to "From stray phone numbers"
2. Select "Spam / One-off" tab
3. Click Dismiss button on first row
4. Verify: Row disappears, next row auto-selected
5. Press Enter key
6. Verify: Selected row dismissed, next row selected
7. Repeat steps 3-6 until list empty

**Expected:**
- [ ] Each dismiss takes < 1 second
- [ ] No confirmation dialogs interrupt flow
- [ ] Keyboard-only dismissal works
- [ ] Selection never requires mouse repositioning

### AT-2: Search Exclusion

**Preconditions:**
- Known message with unique text from stray handle

**Steps:**
1. Search for unique text → verify message found
2. Dismiss the handle
3. Search for same text again

**Expected:**
- [ ] Message not found after dismissal
- [ ] No error or partial results

### AT-3: All Messages Exclusion

**Preconditions:**
- Known message from stray handle with identifiable date/content

**Steps:**
1. View All Messages, locate the message
2. Dismiss the handle
3. Refresh All Messages view

**Expected:**
- [ ] Message no longer visible
- [ ] Message count decremented

### AT-4: Label-First Flow

**Preconditions:**
- Stray handle with messages

**Steps:**
1. Select handle in All Strays mode
2. Click "Label handle…"
3. Enter "?Test Label" and confirm
4. Navigate to contacts

**Expected:**
- [ ] Handle disappears from stray list
- [ ] Virtual contact "?Test Label" visible in contacts
- [ ] Messages from handle visible under that contact

### AT-5: Label Restores Dismissed

**Preconditions:**
- Dismissed handle

**Steps:**
1. View Dismissed handles
2. Click "Label handle…" on a dismissed handle
3. Enter label and confirm
4. Search for a message from that handle

**Expected:**
- [ ] Handle removed from Dismissed list
- [ ] Messages now appear in search results

### AT-6: Persistence Across Restart

**Steps:**
1. Dismiss 3 handles
2. Quit and restart app
3. Check stray handles list

**Expected:**
- [ ] Dismissed handles still absent from list
- [ ] Dismissed handles visible in Dismissed mode

### AT-7: Persistence Across Re-Import

**Steps:**
1. Dismiss 3 handles, note their values
2. Trigger re-import workflow
3. Check stray handles list

**Expected:**
- [ ] Same handles still dismissed (by value, not ID)
- [ ] No duplicate dismissal entries

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Dismiss last handle in list | Selection clears, empty state shown |
| Dismiss while search active | Handle removed from filtered results |
| Label empty string | Validation error, no action |
| Label with only whitespace | Validation error, no action |
| Label existing virtual contact name | Reuse existing virtual participant |
| Restore then re-dismiss | Works normally, timestamps updated |
| Handle in multiple chats dismissed | All messages excluded from all chats |
