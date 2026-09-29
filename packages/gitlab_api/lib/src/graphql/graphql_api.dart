import 'package:dio/dio.dart';

import '../common/exceptions.dart';
import '../gitlab_client.dart';

/// Transport for repository-owned, explicitly selected named read queries.
///
/// Resource APIs remain responsible for DTOs, nullable-resource semantics, and
/// connection cursors. This transport never treats partial results as complete.
class GraphQLApi {
  const GraphQLApi(this._dio, {required String endpoint})
    : _endpoint = endpoint;

  final Dio _dio;
  final String _endpoint;

  /// The document must start with the selected named query (not a mutation).
  ///
  /// Sending operationName explicitly prevents other operations in a document
  /// from being selected. This is not a general GraphQL document validator;
  /// callers supply static, repository-owned query documents, never user input.
  Future<Map<String, dynamic>> query({
    required String document,
    required String operationName,
    Map<String, dynamic> variables = const {},
  }) async {
    final selected = RegExp(
      r'^\s*query\s+([_A-Za-z][_0-9A-Za-z]*)\s*(?:\(|\{|@)',
    ).firstMatch(document);
    if (selected == null || selected.group(1) != operationName) {
      throw ArgumentError('An explicitly selected named query is required');
    }
    try {
      final response = await _dio.post<dynamic>(
        _endpoint,
        data: {
          'query': document,
          'operationName': operationName,
          'variables': variables,
        },
        options: Options(contentType: Headers.jsonContentType),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'reading GraphQL data',
        );
      }
      final body = response.data;
      if (body is! Map<String, dynamic> ||
          (body.containsKey('errors') &&
              (body['errors'] is! List ||
                  (body['errors'] as List).isNotEmpty)) ||
          body['data'] is! Map<String, dynamic>) {
        throw const GitLabServerException(
          'GraphQL query failed or returned incomplete data',
        );
      }
      return body['data'] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw mapError(error, context: 'reading GraphQL data');
    }
  }
}
