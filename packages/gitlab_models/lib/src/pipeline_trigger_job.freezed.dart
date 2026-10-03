// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipeline_trigger_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PipelineTriggerJob {
  int get id;
  String get name;
  String get status;
  String? get stage;
  @JsonKey(name: 'downstream_pipeline')
  Pipeline? get downstreamPipeline;

  /// Create a copy of PipelineTriggerJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PipelineTriggerJobCopyWith<PipelineTriggerJob> get copyWith =>
      _$PipelineTriggerJobCopyWithImpl<PipelineTriggerJob>(
        this as PipelineTriggerJob,
        _$identity,
      );

  /// Serializes this PipelineTriggerJob to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PipelineTriggerJob &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.downstreamPipeline, downstreamPipeline) ||
                other.downstreamPipeline == downstreamPipeline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, status, stage, downstreamPipeline);

  @override
  String toString() {
    return 'PipelineTriggerJob(id: $id, name: $name, status: $status, stage: $stage, downstreamPipeline: $downstreamPipeline)';
  }
}

/// @nodoc
abstract mixin class $PipelineTriggerJobCopyWith<$Res> {
  factory $PipelineTriggerJobCopyWith(
    PipelineTriggerJob value,
    $Res Function(PipelineTriggerJob) _then,
  ) = _$PipelineTriggerJobCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String name,
    String status,
    String? stage,
    @JsonKey(name: 'downstream_pipeline') Pipeline? downstreamPipeline,
  });

  $PipelineCopyWith<$Res>? get downstreamPipeline;
}

/// @nodoc
class _$PipelineTriggerJobCopyWithImpl<$Res>
    implements $PipelineTriggerJobCopyWith<$Res> {
  _$PipelineTriggerJobCopyWithImpl(this._self, this._then);

  final PipelineTriggerJob _self;
  final $Res Function(PipelineTriggerJob) _then;

  /// Create a copy of PipelineTriggerJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? stage = freezed,
    Object? downstreamPipeline = freezed,
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
        downstreamPipeline: freezed == downstreamPipeline
            ? _self.downstreamPipeline
            : downstreamPipeline // ignore: cast_nullable_to_non_nullable
                  as Pipeline?,
      ),
    );
  }

  /// Create a copy of PipelineTriggerJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PipelineCopyWith<$Res>? get downstreamPipeline {
    if (_self.downstreamPipeline == null) {
      return null;
    }

    return $PipelineCopyWith<$Res>(_self.downstreamPipeline!, (value) {
      return _then(_self.copyWith(downstreamPipeline: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PipelineTriggerJob].
extension PipelineTriggerJobPatterns on PipelineTriggerJob {
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
    TResult Function(_PipelineTriggerJob value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PipelineTriggerJob() when $default != null:
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
    TResult Function(_PipelineTriggerJob value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineTriggerJob():
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
    TResult? Function(_PipelineTriggerJob value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineTriggerJob() when $default != null:
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
      @JsonKey(name: 'downstream_pipeline') Pipeline? downstreamPipeline,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PipelineTriggerJob() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.status,
          _that.stage,
          _that.downstreamPipeline,
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
      @JsonKey(name: 'downstream_pipeline') Pipeline? downstreamPipeline,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineTriggerJob():
        return $default(
          _that.id,
          _that.name,
          _that.status,
          _that.stage,
          _that.downstreamPipeline,
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
      @JsonKey(name: 'downstream_pipeline') Pipeline? downstreamPipeline,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineTriggerJob() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.status,
          _that.stage,
          _that.downstreamPipeline,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PipelineTriggerJob extends PipelineTriggerJob {
  const _PipelineTriggerJob({
    required this.id,
    required this.name,
    required this.status,
    this.stage,
    @JsonKey(name: 'downstream_pipeline') this.downstreamPipeline,
  }) : super._();
  factory _PipelineTriggerJob.fromJson(Map<String, dynamic> json) =>
      _$PipelineTriggerJobFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String status;
  @override
  final String? stage;
  @override
  @JsonKey(name: 'downstream_pipeline')
  final Pipeline? downstreamPipeline;

  /// Create a copy of PipelineTriggerJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PipelineTriggerJobCopyWith<_PipelineTriggerJob> get copyWith =>
      __$PipelineTriggerJobCopyWithImpl<_PipelineTriggerJob>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PipelineTriggerJobToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PipelineTriggerJob &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.downstreamPipeline, downstreamPipeline) ||
                other.downstreamPipeline == downstreamPipeline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, status, stage, downstreamPipeline);

  @override
  String toString() {
    return 'PipelineTriggerJob(id: $id, name: $name, status: $status, stage: $stage, downstreamPipeline: $downstreamPipeline)';
  }
}

/// @nodoc
abstract mixin class _$PipelineTriggerJobCopyWith<$Res>
    implements $PipelineTriggerJobCopyWith<$Res> {
  factory _$PipelineTriggerJobCopyWith(
    _PipelineTriggerJob value,
    $Res Function(_PipelineTriggerJob) _then,
  ) = __$PipelineTriggerJobCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String status,
    String? stage,
    @JsonKey(name: 'downstream_pipeline') Pipeline? downstreamPipeline,
  });

  @override
  $PipelineCopyWith<$Res>? get downstreamPipeline;
}

/// @nodoc
class __$PipelineTriggerJobCopyWithImpl<$Res>
    implements _$PipelineTriggerJobCopyWith<$Res> {
  __$PipelineTriggerJobCopyWithImpl(this._self, this._then);

  final _PipelineTriggerJob _self;
  final $Res Function(_PipelineTriggerJob) _then;

  /// Create a copy of PipelineTriggerJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? stage = freezed,
    Object? downstreamPipeline = freezed,
  }) {
    return _then(
      _PipelineTriggerJob(
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
        downstreamPipeline: freezed == downstreamPipeline
            ? _self.downstreamPipeline
            : downstreamPipeline // ignore: cast_nullable_to_non_nullable
                  as Pipeline?,
      ),
    );
  }

  /// Create a copy of PipelineTriggerJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PipelineCopyWith<$Res>? get downstreamPipeline {
    if (_self.downstreamPipeline == null) {
      return null;
    }

    return $PipelineCopyWith<$Res>(_self.downstreamPipeline!, (value) {
      return _then(_self.copyWith(downstreamPipeline: value));
    });
  }
}
