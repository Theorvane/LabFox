import 'package:freezed_annotation/freezed_annotation.dart';

part 'suggestion.freezed.dart';
part 'suggestion.g.dart';

/// The original and replacement code of a server-provided MR suggestion.
/// Sparse legacy metadata remains unknown; patch applicability is not permission.
@freezed
abstract class Suggestion with _$Suggestion {
  const Suggestion._();
  const factory Suggestion({
    required int id,
    @JsonKey(name: 'from_line') int? fromLine,
    @JsonKey(name: 'to_line') int? toLine,
    @JsonKey(name: 'from_content') String? fromContent,
    @JsonKey(name: 'to_content') String? toContent,
    bool? appliable,
    bool? applicable,
    bool? applied,
  }) = _Suggestion;

  /// Official discussion examples use `appliable`; the suggestions API uses
  /// `applicable`. Conflicting spellings cannot authorize an application.
  bool? get patchApplicable {
    if (appliable != null && applicable != null && appliable != applicable) {
      return null;
    }
    return applicable ?? appliable;
  }

  factory Suggestion.fromJson(Map<String, dynamic> json) =>
      _$SuggestionFromJson(json);
}
