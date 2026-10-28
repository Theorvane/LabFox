// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Job {
  int get id;
  String get name;
  String get status;
  String? get stage;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'started_at')
  DateTime? get startedAt;
  @JsonKey(name: 'finished_at')
  DateTime? get finishedAt;
  @JsonKey(name: 'web_url')
  String? get webUrl;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $JobCopyWith<Job> get copyWith =>
      _$JobCopyWithImpl<Job>(this as Job, _$identity);

  /// Serializes this Job to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Job &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    status,
    stage,
    createdAt,
    startedAt,
    finishedAt,
    webUrl,
  );

  @override
  String toString() {
    return 'Job(id: $id, name: $name, status: $status, stage: $stage, createdAt: $createdAt, startedAt: $startedAt, finishedAt: $finishedAt, webUrl: $webUrl)';
  }
}

/// @nodoc
abstract mixin class $JobCopyWith<$Res> {
  factory $JobCopyWith(Job value, $Res Function(Job) _then) = _$JobCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String name,
    String status,
    String? stage,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'finished_at') DateTime? finishedAt,
    @JsonKey(name: 'web_url') String? webUrl,
  });
}

/// @nodoc
class _$JobCopyWithImpl<$Res> implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._self, this._then);

  final Job _self;
  final $Res Function(Job) _then;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? stage = freezed,
    Object? createdAt = freezed,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
    Object? webUrl = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        stage: freezed == stage
            ? _self.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        startedAt: freezed == startedAt
            ? _self.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        finishedAt: freezed == finishedAt
            ? _self.finishedAt
            : finishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Job].
extension JobPatterns on Job {
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
    TResult Function(_Job value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Job() when $default != null:
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
  TResult map<TResult extends Object?>(TResult Function(_Job value) $default) {
    final _that = this;
    switch (_that) {
      case _Job():
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
    TResult? Function(_Job value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Job() when $default != null:
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
      String name,
      String status,
      String? stage,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'started_at') DateTime? startedAt,
      @JsonKey(name: 'finished_at') DateTime? finishedAt,
      @JsonKey(name: 'web_url') String? webUrl,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Job() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.status,
          _that.stage,
          _that.createdAt,
          _that.startedAt,
          _that.finishedAt,
          _that.webUrl,
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
      String name,
      String status,
      String? stage,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'started_at') DateTime? startedAt,
      @JsonKey(name: 'finished_at') DateTime? finishedAt,
      @JsonKey(name: 'web_url') String? webUrl,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Job():
        return $default(
          _that.id,
          _that.name,
          _that.status,
          _that.stage,
          _that.createdAt,
          _that.startedAt,
          _that.finishedAt,
          _that.webUrl,
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
      String name,
      String status,
      String? stage,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'started_at') DateTime? startedAt,
      @JsonKey(name: 'finished_at') DateTime? finishedAt,
      @JsonKey(name: 'web_url') String? webUrl,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Job() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.status,
          _that.stage,
          _that.createdAt,
          _that.startedAt,
          _that.finishedAt,
          _that.webUrl,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Job extends Job {
  const _Job({
    required this.id,
    required this.name,
    required this.status,
    this.stage,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'started_at') this.startedAt,
    @JsonKey(name: 'finished_at') this.finishedAt,
    @JsonKey(name: 'web_url') this.webUrl,
  }) : super._();
  factory _Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String status;
  @override
  final String? stage;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @override
  @JsonKey(name: 'finished_at')
  final DateTime? finishedAt;
  @override
  @JsonKey(name: 'web_url')
  final String? webUrl;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$JobCopyWith<_Job> get copyWith =>
      __$JobCopyWithImpl<_Job>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$JobToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Job &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    status,
    stage,
    createdAt,
    startedAt,
    finishedAt,
    webUrl,
  );

  @override
  String toString() {
    return 'Job(id: $id, name: $name, status: $status, stage: $stage, createdAt: $createdAt, startedAt: $startedAt, finishedAt: $finishedAt, webUrl: $webUrl)';
  }
}

/// @nodoc
abstract mixin class _$JobCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$JobCopyWith(_Job value, $Res Function(_Job) _then) =
      __$JobCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String status,
    String? stage,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'finished_at') DateTime? finishedAt,
    @JsonKey(name: 'web_url') String? webUrl,
  });
}

/// @nodoc
class __$JobCopyWithImpl<$Res> implements _$JobCopyWith<$Res> {
  __$JobCopyWithImpl(this._self, this._then);

  final _Job _self;
  final $Res Function(_Job) _then;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? stage = freezed,
    Object? createdAt = freezed,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
    Object? webUrl = freezed,
  }) {
    return _then(
      _Job(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        stage: freezed == stage
            ? _self.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        startedAt: freezed == startedAt
            ? _self.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        finishedAt: freezed == finishedAt
            ? _self.finishedAt
            : finishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}
