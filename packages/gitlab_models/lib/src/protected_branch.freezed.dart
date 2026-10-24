// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'protected_branch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProtectedBranch {
  int? get id;
  String get name;
  @JsonKey(name: 'push_access_levels')
  List<ProtectedBranchAccess> get pushAccessLevels;
  @JsonKey(name: 'merge_access_levels')
  List<ProtectedBranchAccess> get mergeAccessLevels;
  @JsonKey(name: 'unprotect_access_levels')
  List<ProtectedBranchAccess> get unprotectAccessLevels;
  @JsonKey(name: 'allow_force_push')
  bool get allowForcePush;
  @JsonKey(name: 'code_owner_approval_required')
  bool get codeOwnerApprovalRequired;
  bool? get inherited;

  /// Create a copy of ProtectedBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProtectedBranchCopyWith<ProtectedBranch> get copyWith =>
      _$ProtectedBranchCopyWithImpl<ProtectedBranch>(
        this as ProtectedBranch,
        _$identity,
      );

  /// Serializes this ProtectedBranch to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProtectedBranch &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other.pushAccessLevels,
              pushAccessLevels,
            ) &&
            const DeepCollectionEquality().equals(
              other.mergeAccessLevels,
              mergeAccessLevels,
            ) &&
            const DeepCollectionEquality().equals(
              other.unprotectAccessLevels,
              unprotectAccessLevels,
            ) &&
            (identical(other.allowForcePush, allowForcePush) ||
                other.allowForcePush == allowForcePush) &&
            (identical(
                  other.codeOwnerApprovalRequired,
                  codeOwnerApprovalRequired,
                ) ||
                other.codeOwnerApprovalRequired == codeOwnerApprovalRequired) &&
            (identical(other.inherited, inherited) ||
                other.inherited == inherited));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(pushAccessLevels),
    const DeepCollectionEquality().hash(mergeAccessLevels),
    const DeepCollectionEquality().hash(unprotectAccessLevels),
    allowForcePush,
    codeOwnerApprovalRequired,
    inherited,
  );

  @override
  String toString() {
    return 'ProtectedBranch(id: $id, name: $name, pushAccessLevels: $pushAccessLevels, mergeAccessLevels: $mergeAccessLevels, unprotectAccessLevels: $unprotectAccessLevels, allowForcePush: $allowForcePush, codeOwnerApprovalRequired: $codeOwnerApprovalRequired, inherited: $inherited)';
  }
}

/// @nodoc
abstract mixin class $ProtectedBranchCopyWith<$Res> {
  factory $ProtectedBranchCopyWith(
    ProtectedBranch value,
    $Res Function(ProtectedBranch) _then,
  ) = _$ProtectedBranchCopyWithImpl;
  @useResult
  $Res call({
    int? id,
    String name,
    @JsonKey(name: 'push_access_levels')
    List<ProtectedBranchAccess> pushAccessLevels,
    @JsonKey(name: 'merge_access_levels')
    List<ProtectedBranchAccess> mergeAccessLevels,
    @JsonKey(name: 'unprotect_access_levels')
    List<ProtectedBranchAccess> unprotectAccessLevels,
    @JsonKey(name: 'allow_force_push') bool allowForcePush,
    @JsonKey(name: 'code_owner_approval_required')
    bool codeOwnerApprovalRequired,
    bool? inherited,
  });
}

/// @nodoc
class _$ProtectedBranchCopyWithImpl<$Res>
    implements $ProtectedBranchCopyWith<$Res> {
  _$ProtectedBranchCopyWithImpl(this._self, this._then);

  final ProtectedBranch _self;
  final $Res Function(ProtectedBranch) _then;

  /// Create a copy of ProtectedBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? pushAccessLevels = null,
    Object? mergeAccessLevels = null,
    Object? unprotectAccessLevels = null,
    Object? allowForcePush = null,
    Object? codeOwnerApprovalRequired = null,
    Object? inherited = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        pushAccessLevels: null == pushAccessLevels
            ? _self.pushAccessLevels
            : pushAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedBranchAccess>,
        mergeAccessLevels: null == mergeAccessLevels
            ? _self.mergeAccessLevels
            : mergeAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedBranchAccess>,
        unprotectAccessLevels: null == unprotectAccessLevels
            ? _self.unprotectAccessLevels
            : unprotectAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedBranchAccess>,
        allowForcePush: null == allowForcePush
            ? _self.allowForcePush
            : allowForcePush // ignore: cast_nullable_to_non_nullable
                  as bool,
        codeOwnerApprovalRequired: null == codeOwnerApprovalRequired
            ? _self.codeOwnerApprovalRequired
            : codeOwnerApprovalRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        inherited: freezed == inherited
            ? _self.inherited
            : inherited // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ProtectedBranch].
extension ProtectedBranchPatterns on ProtectedBranch {
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
    TResult Function(_ProtectedBranch value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranch() when $default != null:
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
    TResult Function(_ProtectedBranch value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranch():
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
    TResult? Function(_ProtectedBranch value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranch() when $default != null:
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
      String name,
      @JsonKey(name: 'push_access_levels')
      List<ProtectedBranchAccess> pushAccessLevels,
      @JsonKey(name: 'merge_access_levels')
      List<ProtectedBranchAccess> mergeAccessLevels,
      @JsonKey(name: 'unprotect_access_levels')
      List<ProtectedBranchAccess> unprotectAccessLevels,
      @JsonKey(name: 'allow_force_push') bool allowForcePush,
      @JsonKey(name: 'code_owner_approval_required')
      bool codeOwnerApprovalRequired,
      bool? inherited,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranch() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.pushAccessLevels,
          _that.mergeAccessLevels,
          _that.unprotectAccessLevels,
          _that.allowForcePush,
          _that.codeOwnerApprovalRequired,
          _that.inherited,
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
      String name,
      @JsonKey(name: 'push_access_levels')
      List<ProtectedBranchAccess> pushAccessLevels,
      @JsonKey(name: 'merge_access_levels')
      List<ProtectedBranchAccess> mergeAccessLevels,
      @JsonKey(name: 'unprotect_access_levels')
      List<ProtectedBranchAccess> unprotectAccessLevels,
      @JsonKey(name: 'allow_force_push') bool allowForcePush,
      @JsonKey(name: 'code_owner_approval_required')
      bool codeOwnerApprovalRequired,
      bool? inherited,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranch():
        return $default(
          _that.id,
          _that.name,
          _that.pushAccessLevels,
          _that.mergeAccessLevels,
          _that.unprotectAccessLevels,
          _that.allowForcePush,
          _that.codeOwnerApprovalRequired,
          _that.inherited,
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
      String name,
      @JsonKey(name: 'push_access_levels')
      List<ProtectedBranchAccess> pushAccessLevels,
      @JsonKey(name: 'merge_access_levels')
      List<ProtectedBranchAccess> mergeAccessLevels,
      @JsonKey(name: 'unprotect_access_levels')
      List<ProtectedBranchAccess> unprotectAccessLevels,
      @JsonKey(name: 'allow_force_push') bool allowForcePush,
      @JsonKey(name: 'code_owner_approval_required')
      bool codeOwnerApprovalRequired,
      bool? inherited,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranch() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.pushAccessLevels,
          _that.mergeAccessLevels,
          _that.unprotectAccessLevels,
          _that.allowForcePush,
          _that.codeOwnerApprovalRequired,
          _that.inherited,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProtectedBranch implements ProtectedBranch {
  const _ProtectedBranch({
    this.id,
    required this.name,
    @JsonKey(name: 'push_access_levels')
    final List<ProtectedBranchAccess> pushAccessLevels =
        const <ProtectedBranchAccess>[],
    @JsonKey(name: 'merge_access_levels')
    final List<ProtectedBranchAccess> mergeAccessLevels =
        const <ProtectedBranchAccess>[],
    @JsonKey(name: 'unprotect_access_levels')
    final List<ProtectedBranchAccess> unprotectAccessLevels =
        const <ProtectedBranchAccess>[],
    @JsonKey(name: 'allow_force_push') this.allowForcePush = false,
    @JsonKey(name: 'code_owner_approval_required')
    this.codeOwnerApprovalRequired = false,
    this.inherited,
  }) : _pushAccessLevels = pushAccessLevels,
       _mergeAccessLevels = mergeAccessLevels,
       _unprotectAccessLevels = unprotectAccessLevels;
  factory _ProtectedBranch.fromJson(Map<String, dynamic> json) =>
      _$ProtectedBranchFromJson(json);

  @override
  final int? id;
  @override
  final String name;
  final List<ProtectedBranchAccess> _pushAccessLevels;
  @override
  @JsonKey(name: 'push_access_levels')
  List<ProtectedBranchAccess> get pushAccessLevels {
    if (_pushAccessLevels is EqualUnmodifiableListView)
      return _pushAccessLevels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pushAccessLevels);
  }

  final List<ProtectedBranchAccess> _mergeAccessLevels;
  @override
  @JsonKey(name: 'merge_access_levels')
  List<ProtectedBranchAccess> get mergeAccessLevels {
    if (_mergeAccessLevels is EqualUnmodifiableListView)
      return _mergeAccessLevels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mergeAccessLevels);
  }

  final List<ProtectedBranchAccess> _unprotectAccessLevels;
  @override
  @JsonKey(name: 'unprotect_access_levels')
  List<ProtectedBranchAccess> get unprotectAccessLevels {
    if (_unprotectAccessLevels is EqualUnmodifiableListView)
      return _unprotectAccessLevels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unprotectAccessLevels);
  }

  @override
  @JsonKey(name: 'allow_force_push')
  final bool allowForcePush;
  @override
  @JsonKey(name: 'code_owner_approval_required')
  final bool codeOwnerApprovalRequired;
  @override
  final bool? inherited;

  /// Create a copy of ProtectedBranch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProtectedBranchCopyWith<_ProtectedBranch> get copyWith =>
      __$ProtectedBranchCopyWithImpl<_ProtectedBranch>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProtectedBranchToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProtectedBranch &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._pushAccessLevels,
              _pushAccessLevels,
            ) &&
            const DeepCollectionEquality().equals(
              other._mergeAccessLevels,
              _mergeAccessLevels,
            ) &&
            const DeepCollectionEquality().equals(
              other._unprotectAccessLevels,
              _unprotectAccessLevels,
            ) &&
            (identical(other.allowForcePush, allowForcePush) ||
                other.allowForcePush == allowForcePush) &&
            (identical(
                  other.codeOwnerApprovalRequired,
                  codeOwnerApprovalRequired,
                ) ||
                other.codeOwnerApprovalRequired == codeOwnerApprovalRequired) &&
            (identical(other.inherited, inherited) ||
                other.inherited == inherited));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_pushAccessLevels),
    const DeepCollectionEquality().hash(_mergeAccessLevels),
    const DeepCollectionEquality().hash(_unprotectAccessLevels),
    allowForcePush,
    codeOwnerApprovalRequired,
    inherited,
  );

  @override
  String toString() {
    return 'ProtectedBranch(id: $id, name: $name, pushAccessLevels: $pushAccessLevels, mergeAccessLevels: $mergeAccessLevels, unprotectAccessLevels: $unprotectAccessLevels, allowForcePush: $allowForcePush, codeOwnerApprovalRequired: $codeOwnerApprovalRequired, inherited: $inherited)';
  }
}

/// @nodoc
abstract mixin class _$ProtectedBranchCopyWith<$Res>
    implements $ProtectedBranchCopyWith<$Res> {
  factory _$ProtectedBranchCopyWith(
    _ProtectedBranch value,
    $Res Function(_ProtectedBranch) _then,
  ) = __$ProtectedBranchCopyWithImpl;
  @override
  @useResult
  $Res call({
    int? id,
    String name,
    @JsonKey(name: 'push_access_levels')
    List<ProtectedBranchAccess> pushAccessLevels,
    @JsonKey(name: 'merge_access_levels')
    List<ProtectedBranchAccess> mergeAccessLevels,
    @JsonKey(name: 'unprotect_access_levels')
    List<ProtectedBranchAccess> unprotectAccessLevels,
    @JsonKey(name: 'allow_force_push') bool allowForcePush,
    @JsonKey(name: 'code_owner_approval_required')
    bool codeOwnerApprovalRequired,
    bool? inherited,
  });
}

/// @nodoc
class __$ProtectedBranchCopyWithImpl<$Res>
    implements _$ProtectedBranchCopyWith<$Res> {
  __$ProtectedBranchCopyWithImpl(this._self, this._then);

  final _ProtectedBranch _self;
  final $Res Function(_ProtectedBranch) _then;

  /// Create a copy of ProtectedBranch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? pushAccessLevels = null,
    Object? mergeAccessLevels = null,
    Object? unprotectAccessLevels = null,
    Object? allowForcePush = null,
    Object? codeOwnerApprovalRequired = null,
    Object? inherited = freezed,
  }) {
    return _then(
      _ProtectedBranch(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        pushAccessLevels: null == pushAccessLevels
            ? _self._pushAccessLevels
            : pushAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedBranchAccess>,
        mergeAccessLevels: null == mergeAccessLevels
            ? _self._mergeAccessLevels
            : mergeAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedBranchAccess>,
        unprotectAccessLevels: null == unprotectAccessLevels
            ? _self._unprotectAccessLevels
            : unprotectAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedBranchAccess>,
        allowForcePush: null == allowForcePush
            ? _self.allowForcePush
            : allowForcePush // ignore: cast_nullable_to_non_nullable
                  as bool,
        codeOwnerApprovalRequired: null == codeOwnerApprovalRequired
            ? _self.codeOwnerApprovalRequired
            : codeOwnerApprovalRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        inherited: freezed == inherited
            ? _self.inherited
            : inherited // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
mixin _$ProtectedBranchAccess {
  int? get id;
  @JsonKey(name: 'access_level')
  int? get accessLevel;
  @JsonKey(name: 'access_level_description')
  String? get description;
  @JsonKey(name: 'user_id')
  int? get userId;
  @JsonKey(name: 'group_id')
  int? get groupId;
  @JsonKey(name: 'deploy_key_id')
  int? get deployKeyId;
  @JsonKey(name: 'member_role_id')
  int? get memberRoleId;

  /// Create a copy of ProtectedBranchAccess
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProtectedBranchAccessCopyWith<ProtectedBranchAccess> get copyWith =>
      _$ProtectedBranchAccessCopyWithImpl<ProtectedBranchAccess>(
        this as ProtectedBranchAccess,
        _$identity,
      );

  /// Serializes this ProtectedBranchAccess to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProtectedBranchAccess &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accessLevel, accessLevel) ||
                other.accessLevel == accessLevel) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.deployKeyId, deployKeyId) ||
                other.deployKeyId == deployKeyId) &&
            (identical(other.memberRoleId, memberRoleId) ||
                other.memberRoleId == memberRoleId));
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
    deployKeyId,
    memberRoleId,
  );

  @override
  String toString() {
    return 'ProtectedBranchAccess(id: $id, accessLevel: $accessLevel, description: $description, userId: $userId, groupId: $groupId, deployKeyId: $deployKeyId, memberRoleId: $memberRoleId)';
  }
}

/// @nodoc
abstract mixin class $ProtectedBranchAccessCopyWith<$Res> {
  factory $ProtectedBranchAccessCopyWith(
    ProtectedBranchAccess value,
    $Res Function(ProtectedBranchAccess) _then,
  ) = _$ProtectedBranchAccessCopyWithImpl;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'access_level') int? accessLevel,
    @JsonKey(name: 'access_level_description') String? description,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'group_id') int? groupId,
    @JsonKey(name: 'deploy_key_id') int? deployKeyId,
    @JsonKey(name: 'member_role_id') int? memberRoleId,
  });
}

/// @nodoc
class _$ProtectedBranchAccessCopyWithImpl<$Res>
    implements $ProtectedBranchAccessCopyWith<$Res> {
  _$ProtectedBranchAccessCopyWithImpl(this._self, this._then);

  final ProtectedBranchAccess _self;
  final $Res Function(ProtectedBranchAccess) _then;

  /// Create a copy of ProtectedBranchAccess
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? accessLevel = freezed,
    Object? description = freezed,
    Object? userId = freezed,
    Object? groupId = freezed,
    Object? deployKeyId = freezed,
    Object? memberRoleId = freezed,
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
        deployKeyId: freezed == deployKeyId
            ? _self.deployKeyId
            : deployKeyId // ignore: cast_nullable_to_non_nullable
                  as int?,
        memberRoleId: freezed == memberRoleId
            ? _self.memberRoleId
            : memberRoleId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ProtectedBranchAccess].
extension ProtectedBranchAccessPatterns on ProtectedBranchAccess {
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
    TResult Function(_ProtectedBranchAccess value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranchAccess() when $default != null:
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
    TResult Function(_ProtectedBranchAccess value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranchAccess():
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
    TResult? Function(_ProtectedBranchAccess value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranchAccess() when $default != null:
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
      @JsonKey(name: 'deploy_key_id') int? deployKeyId,
      @JsonKey(name: 'member_role_id') int? memberRoleId,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranchAccess() when $default != null:
        return $default(
          _that.id,
          _that.accessLevel,
          _that.description,
          _that.userId,
          _that.groupId,
          _that.deployKeyId,
          _that.memberRoleId,
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
      @JsonKey(name: 'deploy_key_id') int? deployKeyId,
      @JsonKey(name: 'member_role_id') int? memberRoleId,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranchAccess():
        return $default(
          _that.id,
          _that.accessLevel,
          _that.description,
          _that.userId,
          _that.groupId,
          _that.deployKeyId,
          _that.memberRoleId,
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
      @JsonKey(name: 'deploy_key_id') int? deployKeyId,
      @JsonKey(name: 'member_role_id') int? memberRoleId,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedBranchAccess() when $default != null:
        return $default(
          _that.id,
          _that.accessLevel,
          _that.description,
          _that.userId,
          _that.groupId,
          _that.deployKeyId,
          _that.memberRoleId,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProtectedBranchAccess implements ProtectedBranchAccess {
  const _ProtectedBranchAccess({
    this.id,
    @JsonKey(name: 'access_level') this.accessLevel,
    @JsonKey(name: 'access_level_description') this.description,
    @JsonKey(name: 'user_id') this.userId,
    @JsonKey(name: 'group_id') this.groupId,
    @JsonKey(name: 'deploy_key_id') this.deployKeyId,
    @JsonKey(name: 'member_role_id') this.memberRoleId,
  });
  factory _ProtectedBranchAccess.fromJson(Map<String, dynamic> json) =>
      _$ProtectedBranchAccessFromJson(json);

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
  @JsonKey(name: 'deploy_key_id')
  final int? deployKeyId;
  @override
  @JsonKey(name: 'member_role_id')
  final int? memberRoleId;

  /// Create a copy of ProtectedBranchAccess
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProtectedBranchAccessCopyWith<_ProtectedBranchAccess> get copyWith =>
      __$ProtectedBranchAccessCopyWithImpl<_ProtectedBranchAccess>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$ProtectedBranchAccessToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProtectedBranchAccess &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accessLevel, accessLevel) ||
                other.accessLevel == accessLevel) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.deployKeyId, deployKeyId) ||
                other.deployKeyId == deployKeyId) &&
            (identical(other.memberRoleId, memberRoleId) ||
                other.memberRoleId == memberRoleId));
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
    deployKeyId,
    memberRoleId,
  );

  @override
  String toString() {
    return 'ProtectedBranchAccess(id: $id, accessLevel: $accessLevel, description: $description, userId: $userId, groupId: $groupId, deployKeyId: $deployKeyId, memberRoleId: $memberRoleId)';
  }
}

/// @nodoc
abstract mixin class _$ProtectedBranchAccessCopyWith<$Res>
    implements $ProtectedBranchAccessCopyWith<$Res> {
  factory _$ProtectedBranchAccessCopyWith(
    _ProtectedBranchAccess value,
    $Res Function(_ProtectedBranchAccess) _then,
  ) = __$ProtectedBranchAccessCopyWithImpl;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'access_level') int? accessLevel,
    @JsonKey(name: 'access_level_description') String? description,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'group_id') int? groupId,
    @JsonKey(name: 'deploy_key_id') int? deployKeyId,
    @JsonKey(name: 'member_role_id') int? memberRoleId,
  });
}

/// @nodoc
class __$ProtectedBranchAccessCopyWithImpl<$Res>
    implements _$ProtectedBranchAccessCopyWith<$Res> {
  __$ProtectedBranchAccessCopyWithImpl(this._self, this._then);

  final _ProtectedBranchAccess _self;
  final $Res Function(_ProtectedBranchAccess) _then;

  /// Create a copy of ProtectedBranchAccess
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? accessLevel = freezed,
    Object? description = freezed,
    Object? userId = freezed,
    Object? groupId = freezed,
    Object? deployKeyId = freezed,
    Object? memberRoleId = freezed,
  }) {
    return _then(
      _ProtectedBranchAccess(
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
        deployKeyId: freezed == deployKeyId
            ? _self.deployKeyId
            : deployKeyId // ignore: cast_nullable_to_non_nullable
                  as int?,
        memberRoleId: freezed == memberRoleId
            ? _self.memberRoleId
            : memberRoleId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}
