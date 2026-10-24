// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'protected_environment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProtectedEnvironment {
  String get name;
  @JsonKey(name: 'deploy_access_levels')
  List<ProtectedEnvironmentAccess> get deployAccessLevels;
  @JsonKey(name: 'approval_rules')
  List<ProtectedEnvironmentAccess> get approvalRules;
  @JsonKey(name: 'required_approval_count')
  int get requiredApprovalCount;

  /// Create a copy of ProtectedEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProtectedEnvironmentCopyWith<ProtectedEnvironment> get copyWith =>
      _$ProtectedEnvironmentCopyWithImpl<ProtectedEnvironment>(
        this as ProtectedEnvironment,
        _$identity,
      );

  /// Serializes this ProtectedEnvironment to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProtectedEnvironment &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other.deployAccessLevels,
              deployAccessLevels,
            ) &&
            const DeepCollectionEquality().equals(
              other.approvalRules,
              approvalRules,
            ) &&
            (identical(other.requiredApprovalCount, requiredApprovalCount) ||
                other.requiredApprovalCount == requiredApprovalCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(deployAccessLevels),
    const DeepCollectionEquality().hash(approvalRules),
    requiredApprovalCount,
  );

  @override
  String toString() {
    return 'ProtectedEnvironment(name: $name, deployAccessLevels: $deployAccessLevels, approvalRules: $approvalRules, requiredApprovalCount: $requiredApprovalCount)';
  }
}

/// @nodoc
abstract mixin class $ProtectedEnvironmentCopyWith<$Res> {
  factory $ProtectedEnvironmentCopyWith(
    ProtectedEnvironment value,
    $Res Function(ProtectedEnvironment) _then,
  ) = _$ProtectedEnvironmentCopyWithImpl;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'deploy_access_levels')
    List<ProtectedEnvironmentAccess> deployAccessLevels,
    @JsonKey(name: 'approval_rules')
    List<ProtectedEnvironmentAccess> approvalRules,
    @JsonKey(name: 'required_approval_count') int requiredApprovalCount,
  });
}

/// @nodoc
class _$ProtectedEnvironmentCopyWithImpl<$Res>
    implements $ProtectedEnvironmentCopyWith<$Res> {
  _$ProtectedEnvironmentCopyWithImpl(this._self, this._then);

  final ProtectedEnvironment _self;
  final $Res Function(ProtectedEnvironment) _then;

  /// Create a copy of ProtectedEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? deployAccessLevels = null,
    Object? approvalRules = null,
    Object? requiredApprovalCount = null,
  }) {
    return _then(
      _self.copyWith(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        deployAccessLevels: null == deployAccessLevels
            ? _self.deployAccessLevels
            : deployAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedEnvironmentAccess>,
        approvalRules: null == approvalRules
            ? _self.approvalRules
            : approvalRules // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedEnvironmentAccess>,
        requiredApprovalCount: null == requiredApprovalCount
            ? _self.requiredApprovalCount
            : requiredApprovalCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ProtectedEnvironment].
extension ProtectedEnvironmentPatterns on ProtectedEnvironment {
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
    TResult Function(_ProtectedEnvironment value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironment() when $default != null:
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
    TResult Function(_ProtectedEnvironment value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironment():
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
    TResult? Function(_ProtectedEnvironment value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironment() when $default != null:
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
      String name,
      @JsonKey(name: 'deploy_access_levels')
      List<ProtectedEnvironmentAccess> deployAccessLevels,
      @JsonKey(name: 'approval_rules')
      List<ProtectedEnvironmentAccess> approvalRules,
      @JsonKey(name: 'required_approval_count') int requiredApprovalCount,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironment() when $default != null:
        return $default(
          _that.name,
          _that.deployAccessLevels,
          _that.approvalRules,
          _that.requiredApprovalCount,
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
      String name,
      @JsonKey(name: 'deploy_access_levels')
      List<ProtectedEnvironmentAccess> deployAccessLevels,
      @JsonKey(name: 'approval_rules')
      List<ProtectedEnvironmentAccess> approvalRules,
      @JsonKey(name: 'required_approval_count') int requiredApprovalCount,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironment():
        return $default(
          _that.name,
          _that.deployAccessLevels,
          _that.approvalRules,
          _that.requiredApprovalCount,
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
      String name,
      @JsonKey(name: 'deploy_access_levels')
      List<ProtectedEnvironmentAccess> deployAccessLevels,
      @JsonKey(name: 'approval_rules')
      List<ProtectedEnvironmentAccess> approvalRules,
      @JsonKey(name: 'required_approval_count') int requiredApprovalCount,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironment() when $default != null:
        return $default(
          _that.name,
          _that.deployAccessLevels,
          _that.approvalRules,
          _that.requiredApprovalCount,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProtectedEnvironment implements ProtectedEnvironment {
  const _ProtectedEnvironment({
    required this.name,
    @JsonKey(name: 'deploy_access_levels')
    final List<ProtectedEnvironmentAccess> deployAccessLevels =
        const <ProtectedEnvironmentAccess>[],
    @JsonKey(name: 'approval_rules')
    final List<ProtectedEnvironmentAccess> approvalRules =
        const <ProtectedEnvironmentAccess>[],
    @JsonKey(name: 'required_approval_count') this.requiredApprovalCount = 0,
  }) : _deployAccessLevels = deployAccessLevels,
       _approvalRules = approvalRules;
  factory _ProtectedEnvironment.fromJson(Map<String, dynamic> json) =>
      _$ProtectedEnvironmentFromJson(json);

  @override
  final String name;
  final List<ProtectedEnvironmentAccess> _deployAccessLevels;
  @override
  @JsonKey(name: 'deploy_access_levels')
  List<ProtectedEnvironmentAccess> get deployAccessLevels {
    if (_deployAccessLevels is EqualUnmodifiableListView)
      return _deployAccessLevels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deployAccessLevels);
  }

  final List<ProtectedEnvironmentAccess> _approvalRules;
  @override
  @JsonKey(name: 'approval_rules')
  List<ProtectedEnvironmentAccess> get approvalRules {
    if (_approvalRules is EqualUnmodifiableListView) return _approvalRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_approvalRules);
  }

  @override
  @JsonKey(name: 'required_approval_count')
  final int requiredApprovalCount;

  /// Create a copy of ProtectedEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProtectedEnvironmentCopyWith<_ProtectedEnvironment> get copyWith =>
      __$ProtectedEnvironmentCopyWithImpl<_ProtectedEnvironment>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$ProtectedEnvironmentToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProtectedEnvironment &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._deployAccessLevels,
              _deployAccessLevels,
            ) &&
            const DeepCollectionEquality().equals(
              other._approvalRules,
              _approvalRules,
            ) &&
            (identical(other.requiredApprovalCount, requiredApprovalCount) ||
                other.requiredApprovalCount == requiredApprovalCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(_deployAccessLevels),
    const DeepCollectionEquality().hash(_approvalRules),
    requiredApprovalCount,
  );

  @override
  String toString() {
    return 'ProtectedEnvironment(name: $name, deployAccessLevels: $deployAccessLevels, approvalRules: $approvalRules, requiredApprovalCount: $requiredApprovalCount)';
  }
}

/// @nodoc
abstract mixin class _$ProtectedEnvironmentCopyWith<$Res>
    implements $ProtectedEnvironmentCopyWith<$Res> {
  factory _$ProtectedEnvironmentCopyWith(
    _ProtectedEnvironment value,
    $Res Function(_ProtectedEnvironment) _then,
  ) = __$ProtectedEnvironmentCopyWithImpl;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'deploy_access_levels')
    List<ProtectedEnvironmentAccess> deployAccessLevels,
    @JsonKey(name: 'approval_rules')
    List<ProtectedEnvironmentAccess> approvalRules,
    @JsonKey(name: 'required_approval_count') int requiredApprovalCount,
  });
}

/// @nodoc
class __$ProtectedEnvironmentCopyWithImpl<$Res>
    implements _$ProtectedEnvironmentCopyWith<$Res> {
  __$ProtectedEnvironmentCopyWithImpl(this._self, this._then);

  final _ProtectedEnvironment _self;
  final $Res Function(_ProtectedEnvironment) _then;

  /// Create a copy of ProtectedEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? deployAccessLevels = null,
    Object? approvalRules = null,
    Object? requiredApprovalCount = null,
  }) {
    return _then(
      _ProtectedEnvironment(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        deployAccessLevels: null == deployAccessLevels
            ? _self._deployAccessLevels
            : deployAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedEnvironmentAccess>,
        approvalRules: null == approvalRules
            ? _self._approvalRules
            : approvalRules // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedEnvironmentAccess>,
        requiredApprovalCount: null == requiredApprovalCount
            ? _self.requiredApprovalCount
            : requiredApprovalCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
mixin _$ProtectedEnvironmentAccess {
  int? get id;
  @JsonKey(name: 'access_level')
  int? get accessLevel;
  @JsonKey(name: 'access_level_description')
  String? get description;
  @JsonKey(name: 'user_id')
  int? get userId;
  @JsonKey(name: 'group_id')
  int? get groupId;
  @JsonKey(name: 'group_inheritance_type')
  int? get groupInheritanceType;
  @JsonKey(name: 'required_approvals')
  int? get requiredApprovals;

  /// Create a copy of ProtectedEnvironmentAccess
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProtectedEnvironmentAccessCopyWith<ProtectedEnvironmentAccess>
  get copyWith =>
      _$ProtectedEnvironmentAccessCopyWithImpl<ProtectedEnvironmentAccess>(
        this as ProtectedEnvironmentAccess,
        _$identity,
      );

  /// Serializes this ProtectedEnvironmentAccess to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProtectedEnvironmentAccess &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accessLevel, accessLevel) ||
                other.accessLevel == accessLevel) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupInheritanceType, groupInheritanceType) ||
                other.groupInheritanceType == groupInheritanceType) &&
            (identical(other.requiredApprovals, requiredApprovals) ||
                other.requiredApprovals == requiredApprovals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    accessLevel,
    description,
    userId,
    groupId,
    groupInheritanceType,
    requiredApprovals,
  );

  @override
  String toString() {
    return 'ProtectedEnvironmentAccess(id: $id, accessLevel: $accessLevel, description: $description, userId: $userId, groupId: $groupId, groupInheritanceType: $groupInheritanceType, requiredApprovals: $requiredApprovals)';
  }
}

/// @nodoc
abstract mixin class $ProtectedEnvironmentAccessCopyWith<$Res> {
  factory $ProtectedEnvironmentAccessCopyWith(
    ProtectedEnvironmentAccess value,
    $Res Function(ProtectedEnvironmentAccess) _then,
  ) = _$ProtectedEnvironmentAccessCopyWithImpl;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'access_level') int? accessLevel,
    @JsonKey(name: 'access_level_description') String? description,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'group_id') int? groupId,
    @JsonKey(name: 'group_inheritance_type') int? groupInheritanceType,
    @JsonKey(name: 'required_approvals') int? requiredApprovals,
  });
}

/// @nodoc
class _$ProtectedEnvironmentAccessCopyWithImpl<$Res>
    implements $ProtectedEnvironmentAccessCopyWith<$Res> {
  _$ProtectedEnvironmentAccessCopyWithImpl(this._self, this._then);

  final ProtectedEnvironmentAccess _self;
  final $Res Function(ProtectedEnvironmentAccess) _then;

  /// Create a copy of ProtectedEnvironmentAccess
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? accessLevel = freezed,
    Object? description = freezed,
    Object? userId = freezed,
    Object? groupId = freezed,
    Object? groupInheritanceType = freezed,
    Object? requiredApprovals = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        accessLevel: freezed == accessLevel
            ? _self.accessLevel
            : accessLevel // ignore: cast_nullable_to_non_nullable
                  as int?,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _self.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int?,
        groupId: freezed == groupId
            ? _self.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as int?,
        groupInheritanceType: freezed == groupInheritanceType
            ? _self.groupInheritanceType
            : groupInheritanceType // ignore: cast_nullable_to_non_nullable
                  as int?,
        requiredApprovals: freezed == requiredApprovals
            ? _self.requiredApprovals
            : requiredApprovals // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ProtectedEnvironmentAccess].
extension ProtectedEnvironmentAccessPatterns on ProtectedEnvironmentAccess {
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
    TResult Function(_ProtectedEnvironmentAccess value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironmentAccess() when $default != null:
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
    TResult Function(_ProtectedEnvironmentAccess value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironmentAccess():
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
    TResult? Function(_ProtectedEnvironmentAccess value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironmentAccess() when $default != null:
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
      int? id,
      @JsonKey(name: 'access_level') int? accessLevel,
      @JsonKey(name: 'access_level_description') String? description,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'group_id') int? groupId,
      @JsonKey(name: 'group_inheritance_type') int? groupInheritanceType,
      @JsonKey(name: 'required_approvals') int? requiredApprovals,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironmentAccess() when $default != null:
        return $default(
          _that.id,
          _that.accessLevel,
          _that.description,
          _that.userId,
          _that.groupId,
          _that.groupInheritanceType,
          _that.requiredApprovals,
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
      int? id,
      @JsonKey(name: 'access_level') int? accessLevel,
      @JsonKey(name: 'access_level_description') String? description,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'group_id') int? groupId,
      @JsonKey(name: 'group_inheritance_type') int? groupInheritanceType,
      @JsonKey(name: 'required_approvals') int? requiredApprovals,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironmentAccess():
        return $default(
          _that.id,
          _that.accessLevel,
          _that.description,
          _that.userId,
          _that.groupId,
          _that.groupInheritanceType,
          _that.requiredApprovals,
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
      int? id,
      @JsonKey(name: 'access_level') int? accessLevel,
      @JsonKey(name: 'access_level_description') String? description,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'group_id') int? groupId,
      @JsonKey(name: 'group_inheritance_type') int? groupInheritanceType,
      @JsonKey(name: 'required_approvals') int? requiredApprovals,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedEnvironmentAccess() when $default != null:
        return $default(
          _that.id,
          _that.accessLevel,
          _that.description,
          _that.userId,
          _that.groupId,
          _that.groupInheritanceType,
          _that.requiredApprovals,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProtectedEnvironmentAccess implements ProtectedEnvironmentAccess {
  const _ProtectedEnvironmentAccess({
    this.id,
    @JsonKey(name: 'access_level') this.accessLevel,
    @JsonKey(name: 'access_level_description') this.description,
    @JsonKey(name: 'user_id') this.userId,
    @JsonKey(name: 'group_id') this.groupId,
    @JsonKey(name: 'group_inheritance_type') this.groupInheritanceType,
    @JsonKey(name: 'required_approvals') this.requiredApprovals,
  });
  factory _ProtectedEnvironmentAccess.fromJson(Map<String, dynamic> json) =>
      _$ProtectedEnvironmentAccessFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'access_level')
  final int? accessLevel;
  @override
  @JsonKey(name: 'access_level_description')
  final String? description;
  @override
  @JsonKey(name: 'user_id')
  final int? userId;
  @override
  @JsonKey(name: 'group_id')
  final int? groupId;
  @override
  @JsonKey(name: 'group_inheritance_type')
  final int? groupInheritanceType;
  @override
  @JsonKey(name: 'required_approvals')
  final int? requiredApprovals;

  /// Create a copy of ProtectedEnvironmentAccess
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProtectedEnvironmentAccessCopyWith<_ProtectedEnvironmentAccess>
  get copyWith =>
      __$ProtectedEnvironmentAccessCopyWithImpl<_ProtectedEnvironmentAccess>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$ProtectedEnvironmentAccessToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProtectedEnvironmentAccess &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accessLevel, accessLevel) ||
                other.accessLevel == accessLevel) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupInheritanceType, groupInheritanceType) ||
                other.groupInheritanceType == groupInheritanceType) &&
            (identical(other.requiredApprovals, requiredApprovals) ||
                other.requiredApprovals == requiredApprovals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    accessLevel,
    description,
    userId,
    groupId,
    groupInheritanceType,
    requiredApprovals,
  );

  @override
  String toString() {
    return 'ProtectedEnvironmentAccess(id: $id, accessLevel: $accessLevel, description: $description, userId: $userId, groupId: $groupId, groupInheritanceType: $groupInheritanceType, requiredApprovals: $requiredApprovals)';
  }
}

/// @nodoc
abstract mixin class _$ProtectedEnvironmentAccessCopyWith<$Res>
    implements $ProtectedEnvironmentAccessCopyWith<$Res> {
  factory _$ProtectedEnvironmentAccessCopyWith(
    _ProtectedEnvironmentAccess value,
    $Res Function(_ProtectedEnvironmentAccess) _then,
  ) = __$ProtectedEnvironmentAccessCopyWithImpl;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'access_level') int? accessLevel,
    @JsonKey(name: 'access_level_description') String? description,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'group_id') int? groupId,
    @JsonKey(name: 'group_inheritance_type') int? groupInheritanceType,
    @JsonKey(name: 'required_approvals') int? requiredApprovals,
  });
}

/// @nodoc
class __$ProtectedEnvironmentAccessCopyWithImpl<$Res>
    implements _$ProtectedEnvironmentAccessCopyWith<$Res> {
  __$ProtectedEnvironmentAccessCopyWithImpl(this._self, this._then);

  final _ProtectedEnvironmentAccess _self;
  final $Res Function(_ProtectedEnvironmentAccess) _then;

  /// Create a copy of ProtectedEnvironmentAccess
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? accessLevel = freezed,
    Object? description = freezed,
    Object? userId = freezed,
    Object? groupId = freezed,
    Object? groupInheritanceType = freezed,
    Object? requiredApprovals = freezed,
  }) {
    return _then(
      _ProtectedEnvironmentAccess(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        accessLevel: freezed == accessLevel
            ? _self.accessLevel
            : accessLevel // ignore: cast_nullable_to_non_nullable
                  as int?,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _self.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int?,
        groupId: freezed == groupId
            ? _self.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as int?,
        groupInheritanceType: freezed == groupInheritanceType
            ? _self.groupInheritanceType
            : groupInheritanceType // ignore: cast_nullable_to_non_nullable
                  as int?,
        requiredApprovals: freezed == requiredApprovals
            ? _self.requiredApprovals
            : requiredApprovals // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}
