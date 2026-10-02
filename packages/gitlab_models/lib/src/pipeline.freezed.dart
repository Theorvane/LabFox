// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipeline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pipeline {
  int get id;
  String get status;
  String? get ref;
  String? get sha;

  /// Why the pipeline ran: `push`, `schedule`, `merge_request_event`, and
  /// others GitLab adds over time. Null on instances that omit it.
  String? get source;
  @JsonKey(name: 'web_url')
  String? get webUrl;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Pipeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PipelineCopyWith<Pipeline> get copyWith =>
      _$PipelineCopyWithImpl<Pipeline>(this as Pipeline, _$identity);

  /// Serializes this Pipeline to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Pipeline &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.sha, sha) || other.sha == sha) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    status,
    ref,
    sha,
    source,
    webUrl,
    createdAt,
    updatedAt,
  );

  @override
  String toString() {
    return 'Pipeline(id: $id, status: $status, ref: $ref, sha: $sha, source: $source, webUrl: $webUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $PipelineCopyWith<$Res> {
  factory $PipelineCopyWith(Pipeline value, $Res Function(Pipeline) _then) =
      _$PipelineCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String status,
    String? ref,
    String? sha,
    String? source,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$PipelineCopyWithImpl<$Res> implements $PipelineCopyWith<$Res> {
  _$PipelineCopyWithImpl(this._self, this._then);

  final Pipeline _self;
  final $Res Function(Pipeline) _then;

  /// Create a copy of Pipeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? ref = freezed,
    Object? sha = freezed,
    Object? source = freezed,
    Object? webUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        sha: freezed == sha
            ? _self.sha
            : sha // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: freezed == source
            ? _self.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Pipeline].
extension PipelinePatterns on Pipeline {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Pipeline value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Pipeline() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Pipeline value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pipeline():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Pipeline value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pipeline() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String status,
      String? ref,
      String? sha,
      String? source,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Pipeline() when $default != null:
        return $default(
          _that.id,
          _that.status,
          _that.ref,
          _that.sha,
          _that.source,
          _that.webUrl,
          _that.createdAt,
          _that.updatedAt,
        );
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String status,
      String? ref,
      String? sha,
      String? source,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pipeline():
        return $default(
          _that.id,
          _that.status,
          _that.ref,
          _that.sha,
          _that.source,
          _that.webUrl,
          _that.createdAt,
          _that.updatedAt,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String status,
      String? ref,
      String? sha,
      String? source,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pipeline() when $default != null:
        return $default(
          _that.id,
          _that.status,
          _that.ref,
          _that.sha,
          _that.source,
          _that.webUrl,
          _that.createdAt,
          _that.updatedAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Pipeline extends Pipeline {
  const _Pipeline({
    required this.id,
    required this.status,
    this.ref,
    this.sha,
    this.source,
    @JsonKey(name: 'web_url') this.webUrl,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : super._();
  factory _Pipeline.fromJson(Map<String, dynamic> json) =>
      _$PipelineFromJson(json);

  @override
  final int id;
  @override
  final String status;
  @override
  final String? ref;
  @override
  final String? sha;

  /// Why the pipeline ran: `push`, `schedule`, `merge_request_event`, and
  /// others GitLab adds over time. Null on instances that omit it.
  @override
  final String? source;
  @override
  @JsonKey(name: 'web_url')
  final String? webUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of Pipeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PipelineCopyWith<_Pipeline> get copyWith =>
      __$PipelineCopyWithImpl<_Pipeline>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PipelineToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Pipeline &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.sha, sha) || other.sha == sha) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    status,
    ref,
    sha,
    source,
    webUrl,
    createdAt,
    updatedAt,
  );

  @override
  String toString() {
    return 'Pipeline(id: $id, status: $status, ref: $ref, sha: $sha, source: $source, webUrl: $webUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$PipelineCopyWith<$Res>
    implements $PipelineCopyWith<$Res> {
  factory _$PipelineCopyWith(_Pipeline value, $Res Function(_Pipeline) _then) =
      __$PipelineCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String status,
    String? ref,
    String? sha,
    String? source,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$PipelineCopyWithImpl<$Res> implements _$PipelineCopyWith<$Res> {
  __$PipelineCopyWithImpl(this._self, this._then);

  final _Pipeline _self;
  final $Res Function(_Pipeline) _then;

  /// Create a copy of Pipeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? ref = freezed,
    Object? sha = freezed,
    Object? source = freezed,
    Object? webUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _Pipeline(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        sha: freezed == sha
            ? _self.sha
            : sha // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: freezed == source
            ? _self.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}
