// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipeline_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PipelineSchedule {
  int get id;
  String get description;
  String get ref;
  String get cron;
  @JsonKey(name: 'cron_timezone')
  String? get cronTimezone;
  bool get active;
  @JsonKey(name: 'next_run_at')
  DateTime? get nextRunAt;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @JsonKey(name: 'last_pipeline')
  ScheduleLastPipeline? get lastPipeline;
  ScheduleOwner? get owner;

  /// Create a copy of PipelineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PipelineScheduleCopyWith<PipelineSchedule> get copyWith =>
      _$PipelineScheduleCopyWithImpl<PipelineSchedule>(
        this as PipelineSchedule,
        _$identity,
      );

  /// Serializes this PipelineSchedule to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PipelineSchedule &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.cron, cron) || other.cron == cron) &&
            (identical(other.cronTimezone, cronTimezone) ||
                other.cronTimezone == cronTimezone) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.nextRunAt, nextRunAt) ||
                other.nextRunAt == nextRunAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastPipeline, lastPipeline) ||
                other.lastPipeline == lastPipeline) &&
            (identical(other.owner, owner) || other.owner == owner));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    description,
    ref,
    cron,
    cronTimezone,
    active,
    nextRunAt,
    createdAt,
    updatedAt,
    lastPipeline,
    owner,
  );

  @override
  String toString() {
    return 'PipelineSchedule(id: $id, description: $description, ref: $ref, cron: $cron, cronTimezone: $cronTimezone, active: $active, nextRunAt: $nextRunAt, createdAt: $createdAt, updatedAt: $updatedAt, lastPipeline: $lastPipeline, owner: $owner)';
  }
}

/// @nodoc
abstract mixin class $PipelineScheduleCopyWith<$Res> {
  factory $PipelineScheduleCopyWith(
    PipelineSchedule value,
    $Res Function(PipelineSchedule) _then,
  ) = _$PipelineScheduleCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String description,
    String ref,
    String cron,
    @JsonKey(name: 'cron_timezone') String? cronTimezone,
    bool active,
    @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'last_pipeline') ScheduleLastPipeline? lastPipeline,
    ScheduleOwner? owner,
  });

  $ScheduleLastPipelineCopyWith<$Res>? get lastPipeline;
  $ScheduleOwnerCopyWith<$Res>? get owner;
}

/// @nodoc
class _$PipelineScheduleCopyWithImpl<$Res>
    implements $PipelineScheduleCopyWith<$Res> {
  _$PipelineScheduleCopyWithImpl(this._self, this._then);

  final PipelineSchedule _self;
  final $Res Function(PipelineSchedule) _then;

  /// Create a copy of PipelineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? ref = null,
    Object? cron = null,
    Object? cronTimezone = freezed,
    Object? active = null,
    Object? nextRunAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastPipeline = freezed,
    Object? owner = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        description: null == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        ref: null == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String,
        cron: null == cron
            ? _self.cron
            : cron // ignore: cast_nullable_to_non_nullable
                  as String,
        cronTimezone: freezed == cronTimezone
            ? _self.cronTimezone
            : cronTimezone // ignore: cast_nullable_to_non_nullable
                  as String?,
        active: null == active
            ? _self.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
        nextRunAt: freezed == nextRunAt
            ? _self.nextRunAt
            : nextRunAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastPipeline: freezed == lastPipeline
            ? _self.lastPipeline
            : lastPipeline // ignore: cast_nullable_to_non_nullable
                  as ScheduleLastPipeline?,
        owner: freezed == owner
            ? _self.owner
            : owner // ignore: cast_nullable_to_non_nullable
                  as ScheduleOwner?,
      ),
    );
  }

  /// Create a copy of PipelineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleLastPipelineCopyWith<$Res>? get lastPipeline {
    if (_self.lastPipeline == null) {
      return null;
    }

    return $ScheduleLastPipelineCopyWith<$Res>(_self.lastPipeline!, (value) {
      return _then(_self.copyWith(lastPipeline: value));
    });
  }

  /// Create a copy of PipelineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleOwnerCopyWith<$Res>? get owner {
    if (_self.owner == null) {
      return null;
    }

    return $ScheduleOwnerCopyWith<$Res>(_self.owner!, (value) {
      return _then(_self.copyWith(owner: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PipelineSchedule].
extension PipelineSchedulePatterns on PipelineSchedule {
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
    TResult Function(_PipelineSchedule value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PipelineSchedule() when $default != null:
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
    TResult Function(_PipelineSchedule value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineSchedule():
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
    TResult? Function(_PipelineSchedule value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineSchedule() when $default != null:
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
      String description,
      String ref,
      String cron,
      @JsonKey(name: 'cron_timezone') String? cronTimezone,
      bool active,
      @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'last_pipeline') ScheduleLastPipeline? lastPipeline,
      ScheduleOwner? owner,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PipelineSchedule() when $default != null:
        return $default(
          _that.id,
          _that.description,
          _that.ref,
          _that.cron,
          _that.cronTimezone,
          _that.active,
          _that.nextRunAt,
          _that.createdAt,
          _that.updatedAt,
          _that.lastPipeline,
          _that.owner,
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
      String description,
      String ref,
      String cron,
      @JsonKey(name: 'cron_timezone') String? cronTimezone,
      bool active,
      @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'last_pipeline') ScheduleLastPipeline? lastPipeline,
      ScheduleOwner? owner,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineSchedule():
        return $default(
          _that.id,
          _that.description,
          _that.ref,
          _that.cron,
          _that.cronTimezone,
          _that.active,
          _that.nextRunAt,
          _that.createdAt,
          _that.updatedAt,
          _that.lastPipeline,
          _that.owner,
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
      String description,
      String ref,
      String cron,
      @JsonKey(name: 'cron_timezone') String? cronTimezone,
      bool active,
      @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'last_pipeline') ScheduleLastPipeline? lastPipeline,
      ScheduleOwner? owner,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineSchedule() when $default != null:
        return $default(
          _that.id,
          _that.description,
          _that.ref,
          _that.cron,
          _that.cronTimezone,
          _that.active,
          _that.nextRunAt,
          _that.createdAt,
          _that.updatedAt,
          _that.lastPipeline,
          _that.owner,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PipelineSchedule implements PipelineSchedule {
  const _PipelineSchedule({
    required this.id,
    required this.description,
    required this.ref,
    required this.cron,
    @JsonKey(name: 'cron_timezone') this.cronTimezone,
    required this.active,
    @JsonKey(name: 'next_run_at') this.nextRunAt,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'last_pipeline') this.lastPipeline,
    this.owner,
  });
  factory _PipelineSchedule.fromJson(Map<String, dynamic> json) =>
      _$PipelineScheduleFromJson(json);

  @override
  final int id;
  @override
  final String description;
  @override
  final String ref;
  @override
  final String cron;
  @override
  @JsonKey(name: 'cron_timezone')
  final String? cronTimezone;
  @override
  final bool active;
  @override
  @JsonKey(name: 'next_run_at')
  final DateTime? nextRunAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'last_pipeline')
  final ScheduleLastPipeline? lastPipeline;
  @override
  final ScheduleOwner? owner;

  /// Create a copy of PipelineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PipelineScheduleCopyWith<_PipelineSchedule> get copyWith =>
      __$PipelineScheduleCopyWithImpl<_PipelineSchedule>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PipelineScheduleToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PipelineSchedule &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.cron, cron) || other.cron == cron) &&
            (identical(other.cronTimezone, cronTimezone) ||
                other.cronTimezone == cronTimezone) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.nextRunAt, nextRunAt) ||
                other.nextRunAt == nextRunAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastPipeline, lastPipeline) ||
                other.lastPipeline == lastPipeline) &&
            (identical(other.owner, owner) || other.owner == owner));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    description,
    ref,
    cron,
    cronTimezone,
    active,
    nextRunAt,
    createdAt,
    updatedAt,
    lastPipeline,
    owner,
  );

  @override
  String toString() {
    return 'PipelineSchedule(id: $id, description: $description, ref: $ref, cron: $cron, cronTimezone: $cronTimezone, active: $active, nextRunAt: $nextRunAt, createdAt: $createdAt, updatedAt: $updatedAt, lastPipeline: $lastPipeline, owner: $owner)';
  }
}

/// @nodoc
abstract mixin class _$PipelineScheduleCopyWith<$Res>
    implements $PipelineScheduleCopyWith<$Res> {
  factory _$PipelineScheduleCopyWith(
    _PipelineSchedule value,
    $Res Function(_PipelineSchedule) _then,
  ) = __$PipelineScheduleCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String description,
    String ref,
    String cron,
    @JsonKey(name: 'cron_timezone') String? cronTimezone,
    bool active,
    @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'last_pipeline') ScheduleLastPipeline? lastPipeline,
    ScheduleOwner? owner,
  });

  @override
  $ScheduleLastPipelineCopyWith<$Res>? get lastPipeline;
  @override
  $ScheduleOwnerCopyWith<$Res>? get owner;
}

/// @nodoc
class __$PipelineScheduleCopyWithImpl<$Res>
    implements _$PipelineScheduleCopyWith<$Res> {
  __$PipelineScheduleCopyWithImpl(this._self, this._then);

  final _PipelineSchedule _self;
  final $Res Function(_PipelineSchedule) _then;

  /// Create a copy of PipelineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? ref = null,
    Object? cron = null,
    Object? cronTimezone = freezed,
    Object? active = null,
    Object? nextRunAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastPipeline = freezed,
    Object? owner = freezed,
  }) {
    return _then(
      _PipelineSchedule(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        description: null == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        ref: null == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String,
        cron: null == cron
            ? _self.cron
            : cron // ignore: cast_nullable_to_non_nullable
                  as String,
        cronTimezone: freezed == cronTimezone
            ? _self.cronTimezone
            : cronTimezone // ignore: cast_nullable_to_non_nullable
                  as String?,
        active: null == active
            ? _self.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
        nextRunAt: freezed == nextRunAt
            ? _self.nextRunAt
            : nextRunAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastPipeline: freezed == lastPipeline
            ? _self.lastPipeline
            : lastPipeline // ignore: cast_nullable_to_non_nullable
                  as ScheduleLastPipeline?,
        owner: freezed == owner
            ? _self.owner
            : owner // ignore: cast_nullable_to_non_nullable
                  as ScheduleOwner?,
      ),
    );
  }

  /// Create a copy of PipelineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleLastPipelineCopyWith<$Res>? get lastPipeline {
    if (_self.lastPipeline == null) {
      return null;
    }

    return $ScheduleLastPipelineCopyWith<$Res>(_self.lastPipeline!, (value) {
      return _then(_self.copyWith(lastPipeline: value));
    });
  }

  /// Create a copy of PipelineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleOwnerCopyWith<$Res>? get owner {
    if (_self.owner == null) {
      return null;
    }

    return $ScheduleOwnerCopyWith<$Res>(_self.owner!, (value) {
      return _then(_self.copyWith(owner: value));
    });
  }
}

/// @nodoc
mixin _$ScheduleLastPipeline {
  int get id;
  String? get status;
  String? get ref;
  String? get sha;

  /// Create a copy of ScheduleLastPipeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleLastPipelineCopyWith<ScheduleLastPipeline> get copyWith =>
      _$ScheduleLastPipelineCopyWithImpl<ScheduleLastPipeline>(
        this as ScheduleLastPipeline,
        _$identity,
      );

  /// Serializes this ScheduleLastPipeline to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleLastPipeline &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.sha, sha) || other.sha == sha));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, ref, sha);

  @override
  String toString() {
    return 'ScheduleLastPipeline(id: $id, status: $status, ref: $ref, sha: $sha)';
  }
}

/// @nodoc
abstract mixin class $ScheduleLastPipelineCopyWith<$Res> {
  factory $ScheduleLastPipelineCopyWith(
    ScheduleLastPipeline value,
    $Res Function(ScheduleLastPipeline) _then,
  ) = _$ScheduleLastPipelineCopyWithImpl;
  @useResult
  $Res call({int id, String? status, String? ref, String? sha});
}

/// @nodoc
class _$ScheduleLastPipelineCopyWithImpl<$Res>
    implements $ScheduleLastPipelineCopyWith<$Res> {
  _$ScheduleLastPipelineCopyWithImpl(this._self, this._then);

  final ScheduleLastPipeline _self;
  final $Res Function(ScheduleLastPipeline) _then;

  /// Create a copy of ScheduleLastPipeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = freezed,
    Object? ref = freezed,
    Object? sha = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        sha: freezed == sha
            ? _self.sha
            : sha // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ScheduleLastPipeline].
extension ScheduleLastPipelinePatterns on ScheduleLastPipeline {
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
    TResult Function(_ScheduleLastPipeline value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleLastPipeline() when $default != null:
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
    TResult Function(_ScheduleLastPipeline value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleLastPipeline():
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
    TResult? Function(_ScheduleLastPipeline value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleLastPipeline() when $default != null:
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
    TResult Function(int id, String? status, String? ref, String? sha)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleLastPipeline() when $default != null:
        return $default(_that.id, _that.status, _that.ref, _that.sha);
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
    TResult Function(int id, String? status, String? ref, String? sha) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleLastPipeline():
        return $default(_that.id, _that.status, _that.ref, _that.sha);
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
    TResult? Function(int id, String? status, String? ref, String? sha)?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleLastPipeline() when $default != null:
        return $default(_that.id, _that.status, _that.ref, _that.sha);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ScheduleLastPipeline implements ScheduleLastPipeline {
  const _ScheduleLastPipeline({
    required this.id,
    this.status,
    this.ref,
    this.sha,
  });
  factory _ScheduleLastPipeline.fromJson(Map<String, dynamic> json) =>
      _$ScheduleLastPipelineFromJson(json);

  @override
  final int id;
  @override
  final String? status;
  @override
  final String? ref;
  @override
  final String? sha;

  /// Create a copy of ScheduleLastPipeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleLastPipelineCopyWith<_ScheduleLastPipeline> get copyWith =>
      __$ScheduleLastPipelineCopyWithImpl<_ScheduleLastPipeline>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$ScheduleLastPipelineToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleLastPipeline &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.sha, sha) || other.sha == sha));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, ref, sha);

  @override
  String toString() {
    return 'ScheduleLastPipeline(id: $id, status: $status, ref: $ref, sha: $sha)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleLastPipelineCopyWith<$Res>
    implements $ScheduleLastPipelineCopyWith<$Res> {
  factory _$ScheduleLastPipelineCopyWith(
    _ScheduleLastPipeline value,
    $Res Function(_ScheduleLastPipeline) _then,
  ) = __$ScheduleLastPipelineCopyWithImpl;
  @override
  @useResult
  $Res call({int id, String? status, String? ref, String? sha});
}

/// @nodoc
class __$ScheduleLastPipelineCopyWithImpl<$Res>
    implements _$ScheduleLastPipelineCopyWith<$Res> {
  __$ScheduleLastPipelineCopyWithImpl(this._self, this._then);

  final _ScheduleLastPipeline _self;
  final $Res Function(_ScheduleLastPipeline) _then;

  /// Create a copy of ScheduleLastPipeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? status = freezed,
    Object? ref = freezed,
    Object? sha = freezed,
  }) {
    return _then(
      _ScheduleLastPipeline(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        sha: freezed == sha
            ? _self.sha
            : sha // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
mixin _$ScheduleOwner {
  int? get id;
  String? get name;
  String? get username;

  /// Create a copy of ScheduleOwner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleOwnerCopyWith<ScheduleOwner> get copyWith =>
      _$ScheduleOwnerCopyWithImpl<ScheduleOwner>(
        this as ScheduleOwner,
        _$identity,
      );

  /// Serializes this ScheduleOwner to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleOwner &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, username);

  @override
  String toString() {
    return 'ScheduleOwner(id: $id, name: $name, username: $username)';
  }
}

/// @nodoc
abstract mixin class $ScheduleOwnerCopyWith<$Res> {
  factory $ScheduleOwnerCopyWith(
    ScheduleOwner value,
    $Res Function(ScheduleOwner) _then,
  ) = _$ScheduleOwnerCopyWithImpl;
  @useResult
  $Res call({int? id, String? name, String? username});
}

/// @nodoc
class _$ScheduleOwnerCopyWithImpl<$Res>
    implements $ScheduleOwnerCopyWith<$Res> {
  _$ScheduleOwnerCopyWithImpl(this._self, this._then);

  final ScheduleOwner _self;
  final $Res Function(ScheduleOwner) _then;

  /// Create a copy of ScheduleOwner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? username = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: freezed == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        username: freezed == username
            ? _self.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ScheduleOwner].
extension ScheduleOwnerPatterns on ScheduleOwner {
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
    TResult Function(_ScheduleOwner value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleOwner() when $default != null:
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
    TResult Function(_ScheduleOwner value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleOwner():
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
    TResult? Function(_ScheduleOwner value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleOwner() when $default != null:
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
    TResult Function(int? id, String? name, String? username)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleOwner() when $default != null:
        return $default(_that.id, _that.name, _that.username);
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
    TResult Function(int? id, String? name, String? username) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleOwner():
        return $default(_that.id, _that.name, _that.username);
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
    TResult? Function(int? id, String? name, String? username)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleOwner() when $default != null:
        return $default(_that.id, _that.name, _that.username);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ScheduleOwner implements ScheduleOwner {
  const _ScheduleOwner({this.id, this.name, this.username});
  factory _ScheduleOwner.fromJson(Map<String, dynamic> json) =>
      _$ScheduleOwnerFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? username;

  /// Create a copy of ScheduleOwner
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleOwnerCopyWith<_ScheduleOwner> get copyWith =>
      __$ScheduleOwnerCopyWithImpl<_ScheduleOwner>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScheduleOwnerToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleOwner &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, username);

  @override
  String toString() {
    return 'ScheduleOwner(id: $id, name: $name, username: $username)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleOwnerCopyWith<$Res>
    implements $ScheduleOwnerCopyWith<$Res> {
  factory _$ScheduleOwnerCopyWith(
    _ScheduleOwner value,
    $Res Function(_ScheduleOwner) _then,
  ) = __$ScheduleOwnerCopyWithImpl;
  @override
  @useResult
  $Res call({int? id, String? name, String? username});
}

/// @nodoc
class __$ScheduleOwnerCopyWithImpl<$Res>
    implements _$ScheduleOwnerCopyWith<$Res> {
  __$ScheduleOwnerCopyWithImpl(this._self, this._then);

  final _ScheduleOwner _self;
  final $Res Function(_ScheduleOwner) _then;

  /// Create a copy of ScheduleOwner
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? username = freezed,
  }) {
    return _then(
      _ScheduleOwner(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: freezed == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        username: freezed == username
            ? _self.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}
