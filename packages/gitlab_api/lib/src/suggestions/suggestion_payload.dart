// Validate before generated numeric parsing so suggestion identities and
// line coordinates cannot be truncated or confused with another patch.
void validateSuggestionPayloads(Object? value, {Set<int>? seenIds}) {
  if (value == null) return;
  if (value is! List) throw const FormatException();
  final ids = seenIds ?? <int>{};
  for (final entry in value) {
    if (entry is! Map<String, dynamic>) throw const FormatException();
    final id = entry['id'];
    if (id is! int || id < 1 || !ids.add(id)) throw const FormatException();
    for (final key in ['from_line', 'to_line']) {
      final line = entry[key];
      if (line != null && (line is! int || line < 1)) {
        throw const FormatException();
      }
    }
    final from = entry['from_line'], to = entry['to_line'];
    if (from is int && to is int && to < from) throw const FormatException();
    for (final key in ['from_content', 'to_content']) {
      final content = entry[key];
      if (content != null && content is! String) {
        throw const FormatException();
      }
    }
    for (final key in ['appliable', 'applicable', 'applied']) {
      final flag = entry[key];
      if (flag != null && flag is! bool) throw const FormatException();
    }
    final legacy = entry['appliable'], documented = entry['applicable'];
    if (legacy != null && documented != null && legacy != documented) {
      throw const FormatException();
    }
  }
}
