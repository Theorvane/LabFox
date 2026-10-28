import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the store copy against the limits the consoles enforce.
///
/// Play truncates release notes at 500 characters per language and the App
/// Store caps several listing fields, but neither tells you until submission —
/// by which point the copy has usually been edited by someone who did not
/// count. The English release note currently sits at 466 of 500, so the next
/// small edit is what breaks it.
void main() {
  /// The fenced code blocks in a store copy file, in order. Each block is one
  /// field that gets pasted into a console.
  List<String> fields(String path) {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: '$path is missing');
    return RegExp(r'```\n(.*?)\n```', dotAll: true)
        .allMatches(file.readAsStringSync())
        .map((m) => m.group(1)!.trim())
        .toList();
  }

  void expectWithin(String label, String text, int limit) {
    expect(
      text.length,
      lessThanOrEqualTo(limit),
      reason:
          '$label is ${text.length} characters; the store allows $limit. '
          'Shorten it rather than raising the limit.',
    );
  }

  void expectFreeListing(String label, String text) {
    expect(
      text,
      contains('https://www.sloki9637.com/privacy'),
      reason: '$label must include the privacy policy URL',
    );
    expect(text.toLowerCase(), isNot(contains('subscription')));
  }

  group('release notes', () {
    // Play's cap is the binding one, so both languages are checked against it.
    for (final entry in const {
      'English': '../../docs/store/release-notes.md',
      'Korean': '../../docs/store/release-notes.ko.md',
    }.entries) {
      test('${entry.key} fits what the stores accept', () {
        final blocks = fields(entry.value);
        expect(
          blocks.length,
          greaterThanOrEqualTo(2),
          reason: 'expected a Play block and an App Store block',
        );
        expectWithin('${entry.key} Play release notes', blocks[0], 500);
        expectWithin('${entry.key} App Store release notes', blocks[1], 4000);
      });
    }
  });

  group('listing', () {
    test('English fields fit', () {
      final blocks = fields('../../docs/store/listing.md');
      expectWithin('app name', blocks[0], 30);
      expectWithin('subtitle', blocks[1], 30);
      expectWithin('short description', blocks[2], 80);
      expectWithin('full description', blocks[3], 4000);
      expectFreeListing('English full description', blocks[3]);
    });

    test('Korean fields fit', () {
      final blocks = fields('../../docs/store/listing.ko.md');
      expectWithin('app name', blocks[0], 30);
      expectWithin('subtitle', blocks[1], 30);
      expectWithin('short description', blocks[2], 80);
      expectWithin('full description', blocks[3], 4000);
      expectFreeListing('Korean full description', blocks[3]);
    });
  });
}
