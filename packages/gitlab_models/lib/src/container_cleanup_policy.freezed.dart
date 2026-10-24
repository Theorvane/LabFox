// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_cleanup_policy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContainerCleanupPolicy {
  bool? get enabled;
  String? get cadence;
  @JsonKey(name: 'keep_n')
  int? get keepN;
  @JsonKey(name: 'older_than')
  String? get olderThan;
  @JsonKey(name: 'name_regex_delete')
  String? get nameRegexDelete;
  @JsonKey(name: 'name_regex')
  String? get nameRegex;
  @JsonKey(name: 'name_regex_keep')
  String? get nameRegexKeep;
  @JsonKey(name: 'next_run_at')
  DateTime? get nextRunAt;

  /// Create a copy of ContainerCleanupPolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContainerCleanupPolicyCopyWith<ContainerCleanupPolicy> get copyWith =>
      _$ContainerCleanupPolicyCopyWithImpl<ContainerCleanupPolicy>(
        this as ContainerCleanupPolicy,
        _$identity,
      );

  /// Serializes this ContainerCleanupPolicy to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContainerCleanupPolicy &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.cadence, cadence) || other.cadence == cadence) &&
            (identical(other.keepN, keepN) || other.keepN == keepN) &&
            (identical(other.olderThan, olderThan) ||
                other.olderThan == olderThan) &&
            (identical(other.nameRegexDelete, nameRegexDelete) ||
                other.nameRegexDelete == nameRegexDelete) &&
            (identical(other.nameRegex, nameRegex) ||
                other.nameRegex == nameRegex) &&
            (identical(other.nameRegexKeep, nameRegexKeep) ||
                other.nameRegexKeep == nameRegexKeep) &&
            (identical(other.nextRunAt, nextRunAt) ||
                other.nextRunAt == nextRunAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enabled,
    cadence,
    keepN,
    olderThan,
    nameRegexDelete,
    nameRegex,
    nameRegexKeep,
    nextRunAt,
  );

  @override
  String toString() {
    return 'ContainerCleanupPolicy(enabled: $enabled, cadence: $cadence, keepN: $keepN, olderThan: $olderThan, nameRegexDelete: $nameRegexDelete, nameRegex: $nameRegex, nameRegexKeep: $nameRegexKeep, nextRunAt: $nextRunAt)';
  }
}

/// @nodoc
abstract mixin class $ContainerCleanupPolicyCopyWith<$Res> {
  factory $ContainerCleanupPolicyCopyWith(
    ContainerCleanupPolicy value,
    $Res Function(ContainerCleanupPolicy) _then,
  ) = _$ContainerCleanupPolicyCopyWithImpl;
  @useResult
  $Res call({
    bool? enabled,
    String? cadence,
    @JsonKey(name: 'keep_n') int? keepN,
    @JsonKey(name: 'older_than') String? olderThan,
    @JsonKey(name: 'name_regex_delete') String? nameRegexDelete,
    @JsonKey(name: 'name_regex') String? nameRegex,
    @JsonKey(name: 'name_regex_keep') String? nameRegexKeep,
    @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
  });
}

/// @nodoc
class _$ContainerCleanupPolicyCopyWithImpl<$Res>
    implements $ContainerCleanupPolicyCopyWith<$Res> {
  _$ContainerCleanupPolicyCopyWithImpl(this._self, this._then);

  final ContainerCleanupPolicy _self;
  final $Res Function(ContainerCleanupPolicy) _then;

  /// Create a copy of ContainerCleanupPolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = freezed,
    Object? cadence = freezed,
    Object? keepN = freezed,
    Object? olderThan = freezed,
    Object? nameRegexDelete = freezed,
    Object? nameRegex = freezed,
    Object? nameRegexKeep = freezed,
    Object? nextRunAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        enabled: freezed == enabled
            ? _self.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool?,
        cadence: freezed == cadence
            ? _self.cadence
            : cadence // ignore: cast_nullable_to_non_nullable
                  as String?,
        keepN: freezed == keepN
            ? _self.keepN
            : keepN // ignore: cast_nullable_to_non_nullable
                  as int?,
        olderThan: freezed == olderThan
            ? _self.olderThan
            : olderThan // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameRegexDelete: freezed == nameRegexDelete
            ? _self.nameRegexDelete
            : nameRegexDelete // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameRegex: freezed == nameRegex
            ? _self.nameRegex
            : nameRegex // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameRegexKeep: freezed == nameRegexKeep
            ? _self.nameRegexKeep
            : nameRegexKeep // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextRunAt: freezed == nextRunAt
            ? _self.nextRunAt
            : nextRunAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ContainerCleanupPolicy].
extension ContainerCleanupPolicyPatterns on ContainerCleanupPolicy {
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
    TResult Function(_ContainerCleanupPolicy value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ContainerCleanupPolicy() when $default != null:
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
    TResult Function(_ContainerCleanupPolicy value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContainerCleanupPolicy():
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
    TResult? Function(_ContainerCleanupPolicy value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContainerCleanupPolicy() when $default != null:
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
      bool? enabled,
      String? cadence,
      @JsonKey(name: 'keep_n') int? keepN,
      @JsonKey(name: 'older_than') String? olderThan,
      @JsonKey(name: 'name_regex_delete') String? nameRegexDelete,
      @JsonKey(name: 'name_regex') String? nameRegex,
      @JsonKey(name: 'name_regex_keep') String? nameRegexKeep,
      @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ContainerCleanupPolicy() when $default != null:
        return $default(
          _that.enabled,
          _that.cadence,
          _that.keepN,
          _that.olderThan,
          _that.nameRegexDelete,
          _that.nameRegex,
          _that.nameRegexKeep,
          _that.nextRunAt,
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
      bool? enabled,
      String? cadence,
      @JsonKey(name: 'keep_n') int? keepN,
      @JsonKey(name: 'older_than') String? olderThan,
      @JsonKey(name: 'name_regex_delete') String? nameRegexDelete,
      @JsonKey(name: 'name_regex') String? nameRegex,
      @JsonKey(name: 'name_regex_keep') String? nameRegexKeep,
      @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContainerCleanupPolicy():
        return $default(
          _that.enabled,
          _that.cadence,
          _that.keepN,
          _that.olderThan,
          _that.nameRegexDelete,
          _that.nameRegex,
          _that.nameRegexKeep,
          _that.nextRunAt,
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
      bool? enabled,
      String? cadence,
      @JsonKey(name: 'keep_n') int? keepN,
      @JsonKey(name: 'older_than') String? olderThan,
      @JsonKey(name: 'name_regex_delete') String? nameRegexDelete,
      @JsonKey(name: 'name_regex') String? nameRegex,
      @JsonKey(name: 'name_regex_keep') String? nameRegexKeep,
      @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContainerCleanupPolicy() when $default != null:
        return $default(
          _that.enabled,
          _that.cadence,
          _that.keepN,
          _that.olderThan,
          _that.nameRegexDelete,
          _that.nameRegex,
          _that.nameRegexKeep,
          _that.nextRunAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ContainerCleanupPolicy implements ContainerCleanupPolicy {
  const _ContainerCleanupPolicy({
    this.enabled,
    this.cadence,
    @JsonKey(name: 'keep_n') this.keepN,
    @JsonKey(name: 'older_than') this.olderThan,
    @JsonKey(name: 'name_regex_delete') this.nameRegexDelete,
    @JsonKey(name: 'name_regex') this.nameRegex,
    @JsonKey(name: 'name_regex_keep') this.nameRegexKeep,
    @JsonKey(name: 'next_run_at') this.nextRunAt,
  });
  factory _ContainerCleanupPolicy.fromJson(Map<String, dynamic> json) =>
      _$ContainerCleanupPolicyFromJson(json);

  @override
  final bool? enabled;
  @override
  final String? cadence;
  @override
  @JsonKey(name: 'keep_n')
  final int? keepN;
  @override
  @JsonKey(name: 'older_than')
  final String? olderThan;
  @override
  @JsonKey(name: 'name_regex_delete')
  final String? nameRegexDelete;
  @override
  @JsonKey(name: 'name_regex')
  final String? nameRegex;
  @override
  @JsonKey(name: 'name_regex_keep')
  final String? nameRegexKeep;
  @override
  @JsonKey(name: 'next_run_at')
  final DateTime? nextRunAt;

  /// Create a copy of ContainerCleanupPolicy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ContainerCleanupPolicyCopyWith<_ContainerCleanupPolicy> get copyWith =>
      __$ContainerCleanupPolicyCopyWithImpl<_ContainerCleanupPolicy>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$ContainerCleanupPolicyToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ContainerCleanupPolicy &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.cadence, cadence) || other.cadence == cadence) &&
            (identical(other.keepN, keepN) || other.keepN == keepN) &&
            (identical(other.olderThan, olderThan) ||
                other.olderThan == olderThan) &&
            (identical(other.nameRegexDelete, nameRegexDelete) ||
                other.nameRegexDelete == nameRegexDelete) &&
            (identical(other.nameRegex, nameRegex) ||
                other.nameRegex == nameRegex) &&
            (identical(other.nameRegexKeep, nameRegexKeep) ||
                other.nameRegexKeep == nameRegexKeep) &&
            (identical(other.nextRunAt, nextRunAt) ||
                other.nextRunAt == nextRunAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enabled,
    cadence,
    keepN,
    olderThan,
    nameRegexDelete,
    nameRegex,
    nameRegexKeep,
    nextRunAt,
  );

  @override
  String toString() {
    return 'ContainerCleanupPolicy(enabled: $enabled, cadence: $cadence, keepN: $keepN, olderThan: $olderThan, nameRegexDelete: $nameRegexDelete, nameRegex: $nameRegex, nameRegexKeep: $nameRegexKeep, nextRunAt: $nextRunAt)';
  }
}

/// @nodoc
abstract mixin class _$ContainerCleanupPolicyCopyWith<$Res>
    implements $ContainerCleanupPolicyCopyWith<$Res> {
  factory _$ContainerCleanupPolicyCopyWith(
    _ContainerCleanupPolicy value,
    $Res Function(_ContainerCleanupPolicy) _then,
  ) = __$ContainerCleanupPolicyCopyWithImpl;
  @override
  @useResult
  $Res call({
    bool? enabled,
    String? cadence,
    @JsonKey(name: 'keep_n') int? keepN,
    @JsonKey(name: 'older_than') String? olderThan,
    @JsonKey(name: 'name_regex_delete') String? nameRegexDelete,
    @JsonKey(name: 'name_regex') String? nameRegex,
    @JsonKey(name: 'name_regex_keep') String? nameRegexKeep,
    @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
  });
}

/// @nodoc
class __$ContainerCleanupPolicyCopyWithImpl<$Res>
    implements _$ContainerCleanupPolicyCopyWith<$Res> {
  __$ContainerCleanupPolicyCopyWithImpl(this._self, this._then);

  final _ContainerCleanupPolicy _self;
  final $Res Function(_ContainerCleanupPolicy) _then;

  /// Create a copy of ContainerCleanupPolicy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? enabled = freezed,
    Object? cadence = freezed,
    Object? keepN = freezed,
    Object? olderThan = freezed,
    Object? nameRegexDelete = freezed,
    Object? nameRegex = freezed,
    Object? nameRegexKeep = freezed,
    Object? nextRunAt = freezed,
  }) {
    return _then(
      _ContainerCleanupPolicy(
        enabled: freezed == enabled
            ? _self.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool?,
        cadence: freezed == cadence
            ? _self.cadence
            : cadence // ignore: cast_nullable_to_non_nullable
                  as String?,
        keepN: freezed == keepN
            ? _self.keepN
            : keepN // ignore: cast_nullable_to_non_nullable
                  as int?,
        olderThan: freezed == olderThan
            ? _self.olderThan
            : olderThan // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameRegexDelete: freezed == nameRegexDelete
            ? _self.nameRegexDelete
            : nameRegexDelete // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameRegex: freezed == nameRegex
            ? _self.nameRegex
            : nameRegex // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameRegexKeep: freezed == nameRegexKeep
            ? _self.nameRegexKeep
            : nameRegexKeep // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextRunAt: freezed == nextRunAt
            ? _self.nextRunAt
            : nextRunAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}
