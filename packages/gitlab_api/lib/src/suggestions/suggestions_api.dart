import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../gitlab_client.dart';
import 'suggestion_payload.dart';

/// Account-bound operations on global MR code suggestion identities.
class SuggestionsApi {
  SuggestionsApi(this._dio);
  final Dio _dio;

  /// Applies one suggestion and confirms its identity and applied server state.
  ///
  /// The optional commit message is preserved exactly; null uses server defaults.
  /// Writes never follow redirects or replay after authentication failure.
  /// An unconfirmed response can follow an accepted write: callers must reload
  /// discussions and inspect the current state before offering a manual retry.
  Future<Suggestion> apply(int suggestionId, {String? commitMessage}) async {
    if (suggestionId < 1) {
      throw ArgumentError.value(suggestionId, 'suggestionId');
    }
    try {
      final response = await _dio.put<dynamic>(
        '/suggestions/$suggestionId/apply',
        data: {'commit_message': ?commitMessage},
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'applying a code suggestion',
        );
      }
      return _confirmed(response.data, suggestionId);
    } on DioException catch (error) {
      throw mapError(error, context: 'applying a code suggestion');
    }
  }

  static Suggestion _confirmed(Object? payload, int suggestionId) {
    try {
      if (payload is! Map<String, dynamic>) throw const FormatException();
      validateSuggestionPayloads([payload]);
      final suggestion = Suggestion.fromJson(payload);
      if (suggestion.id != suggestionId || suggestion.applied != true) {
        throw const FormatException();
      }
      return suggestion;
    } on FormatException {
      throw const GitLabServerException(
        'Invalid suggestion application response.',
      );
    } on TypeError {
      throw const GitLabServerException(
        'Invalid suggestion application response.',
      );
    }
  }
}
