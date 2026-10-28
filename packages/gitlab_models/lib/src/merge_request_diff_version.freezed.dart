// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_request_diff_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MergeRequestDiffVersion {
  int get id;
  @JsonKey(name: 'base_commit_sha')
  String? get baseCommitSha;
  @JsonKey(name: 'start_commit_sha')
  String? get startCommitSha;
  @JsonKey(name: 'head_commit_sha')
  String? get headCommitSha;
  @JsonKey(name: 'merge_request_id')
  int? get mergeRequestId;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  String? get state;
  @JsonKey(name: 'real_size')
  String? get realSize;
  @JsonKey(name: 'patch_id_sha')
  String? get patchIdSha;
  @JsonKey(name: 'diffs')
  List<MergeRequestVersionFile>? get files;

  /// Create a copy of MergeRequestDiffVersion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MergeRequestDiffVersionCopyWith<MergeRequestDiffVersion> get copyWith =>
      _$MergeRequestDiffVersionCopyWithImpl<MergeRequestDiffVersion>(
        this as MergeRequestDiffVersion,
        _$identity,
      );

  /// Serializes this MergeRequestDiffVersion to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MergeRequestDiffVersion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.baseCommitSha, baseCommitSha) ||
                other.baseCommitSha == baseCommitSha) &&
            (identical(other.startCommitSha, startCommitSha) ||
                other.startCommitSha == startCommitSha) &&
            (identical(other.headCommitSha, headCommitSha) ||
                other.headCommitSha == headCommitSha) &&
            (identical(other.mergeRequestId, mergeRequestId) ||
                other.mergeRequestId == mergeRequestId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.realSize, realSize) ||
                other.realSize == realSize) &&
            (identical(other.patchIdSha, patchIdSha) ||
                other.patchIdSha == patchIdSha) &&
            const DeepCollectionEquality().equals(other.files, files));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    baseCommitSha,
    startCommitSha,
    headCommitSha,
    mergeRequestId,
    createdAt,
    state,
    realSize,
    patchIdSha,
    const DeepCollectionEquality().hash(files),
  );

  @override
  String toString() {
    return 'MergeRequestDiffVersion(id: $id, baseCommitSha: $baseCommitSha, startCommitSha: $startCommitSha, headCommitSha: $headCommitSha, mergeRequestId: $mergeRequestId, createdAt: $createdAt, state: $state, realSize: $realSize, patchIdSha: $patchIdSha, files: $files)';
  }
}

/// @nodoc
abstract mixin class $MergeRequestDiffVersionCopyWith<$Res> {
  factory $MergeRequestDiffVersionCopyWith(
    MergeRequestDiffVersion value,
    $Res Function(MergeRequestDiffVersion) _then,
  ) = _$MergeRequestDiffVersionCopyWithImpl;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'base_commit_sha') String? baseCommitSha,
    @JsonKey(name: 'start_commit_sha') String? startCommitSha,
    @JsonKey(name: 'head_commit_sha') String? headCommitSha,
    @JsonKey(name: 'merge_request_id') int? mergeRequestId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    String? state,
    @JsonKey(name: 'real_size') String? realSize,
    @JsonKey(name: 'patch_id_sha') String? patchIdSha,
    @JsonKey(name: 'diffs') List<MergeRequestVersionFile>? files,
  });
}

/// @nodoc
class _$MergeRequestDiffVersionCopyWithImpl<$Res>
    implements $MergeRequestDiffVersionCopyWith<$Res> {
  _$MergeRequestDiffVersionCopyWithImpl(this._self, this._then);

  final MergeRequestDiffVersion _self;
  final $Res Function(MergeRequestDiffVersion) _then;

  /// Create a copy of MergeRequestDiffVersion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? baseCommitSha = freezed,
    Object? startCommitSha = freezed,
    Object? headCommitSha = freezed,
    Object? mergeRequestId = freezed,
    Object? createdAt = freezed,
    Object? state = freezed,
    Object? realSize = freezed,
    Object? patchIdSha = freezed,
    Object? files = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        baseCommitSha: freezed == baseCommitSha
            ? _self.baseCommitSha
            : baseCommitSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        startCommitSha: freezed == startCommitSha
            ? _self.startCommitSha
            : startCommitSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        headCommitSha: freezed == headCommitSha
            ? _self.headCommitSha
            : headCommitSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        mergeRequestId: freezed == mergeRequestId
            ? _self.mergeRequestId
            : mergeRequestId // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        state: freezed == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
        realSize: freezed == realSize
            ? _self.realSize
            : realSize // ignore: cast_nullable_to_non_nullable
                  as String?,
        patchIdSha: freezed == patchIdSha
            ? _self.patchIdSha
            : patchIdSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        files: freezed == files
            ? _self.files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<MergeRequestVersionFile>?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [MergeRequestDiffVersion].
extension MergeRequestDiffVersionPatterns on MergeRequestDiffVersion {
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
    TResult Function(_MergeRequestDiffVersion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDiffVersion() when $default != null:
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
    TResult Function(_MergeRequestDiffVersion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDiffVersion():
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
    TResult? Function(_MergeRequestDiffVersion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDiffVersion() when $default != null:
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
      @JsonKey(name: 'base_commit_sha') String? baseCommitSha,
      @JsonKey(name: 'start_commit_sha') String? startCommitSha,
      @JsonKey(name: 'head_commit_sha') String? headCommitSha,
      @JsonKey(name: 'merge_request_id') int? mergeRequestId,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      String? state,
      @JsonKey(name: 'real_size') String? realSize,
      @JsonKey(name: 'patch_id_sha') String? patchIdSha,
      @JsonKey(name: 'diffs') List<MergeRequestVersionFile>? files,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDiffVersion() when $default != null:
        return $default(
          _that.id,
          _that.baseCommitSha,
          _that.startCommitSha,
          _that.headCommitSha,
          _that.mergeRequestId,
          _that.createdAt,
          _that.state,
          _that.realSize,
          _that.patchIdSha,
          _that.files,
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
      @JsonKey(name: 'base_commit_sha') String? baseCommitSha,
      @JsonKey(name: 'start_commit_sha') String? startCommitSha,
      @JsonKey(name: 'head_commit_sha') String? headCommitSha,
      @JsonKey(name: 'merge_request_id') int? mergeRequestId,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      String? state,
      @JsonKey(name: 'real_size') String? realSize,
      @JsonKey(name: 'patch_id_sha') String? patchIdSha,
      @JsonKey(name: 'diffs') List<MergeRequestVersionFile>? files,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDiffVersion():
        return $default(
          _that.id,
          _that.baseCommitSha,
          _that.startCommitSha,
          _that.headCommitSha,
          _that.mergeRequestId,
          _that.createdAt,
          _that.state,
          _that.realSize,
          _that.patchIdSha,
          _that.files,
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
      @JsonKey(name: 'base_commit_sha') String? baseCommitSha,
      @JsonKey(name: 'start_commit_sha') String? startCommitSha,
      @JsonKey(name: 'head_commit_sha') String? headCommitSha,
      @JsonKey(name: 'merge_request_id') int? mergeRequestId,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      String? state,
      @JsonKey(name: 'real_size') String? realSize,
      @JsonKey(name: 'patch_id_sha') String? patchIdSha,
      @JsonKey(name: 'diffs') List<MergeRequestVersionFile>? files,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDiffVersion() when $default != null:
        return $default(
          _that.id,
          _that.baseCommitSha,
          _that.startCommitSha,
          _that.headCommitSha,
          _that.mergeRequestId,
          _that.createdAt,
          _that.state,
          _that.realSize,
          _that.patchIdSha,
          _that.files,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MergeRequestDiffVersion implements MergeRequestDiffVersion {
  const _MergeRequestDiffVersion({
    required this.id,
    @JsonKey(name: 'base_commit_sha') this.baseCommitSha,
    @JsonKey(name: 'start_commit_sha') this.startCommitSha,
    @JsonKey(name: 'head_commit_sha') this.headCommitSha,
    @JsonKey(name: 'merge_request_id') this.mergeRequestId,
    @JsonKey(name: 'created_at') this.createdAt,
    this.state,
    @JsonKey(name: 'real_size') this.realSize,
    @JsonKey(name: 'patch_id_sha') this.patchIdSha,
    @JsonKey(name: 'diffs') final List<MergeRequestVersionFile>? files,
  }) : _files = files;
  factory _MergeRequestDiffVersion.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestDiffVersionFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'base_commit_sha')
  final String? baseCommitSha;
  @override
  @JsonKey(name: 'start_commit_sha')
  final String? startCommitSha;
  @override
  @JsonKey(name: 'head_commit_sha')
  final String? headCommitSha;
  @override
  @JsonKey(name: 'merge_request_id')
  final int? mergeRequestId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  final String? state;
  @override
  @JsonKey(name: 'real_size')
  final String? realSize;
  @override
  @JsonKey(name: 'patch_id_sha')
  final String? patchIdSha;
  final List<MergeRequestVersionFile>? _files;
  @override
  @JsonKey(name: 'diffs')
  List<MergeRequestVersionFile>? get files {
    final value = _files;
    if (value == null) return null;
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of MergeRequestDiffVersion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MergeRequestDiffVersionCopyWith<_MergeRequestDiffVersion> get copyWith =>
      __$MergeRequestDiffVersionCopyWithImpl<_MergeRequestDiffVersion>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$MergeRequestDiffVersionToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MergeRequestDiffVersion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.baseCommitSha, baseCommitSha) ||
                other.baseCommitSha == baseCommitSha) &&
            (identical(other.startCommitSha, startCommitSha) ||
                other.startCommitSha == startCommitSha) &&
            (identical(other.headCommitSha, headCommitSha) ||
                other.headCommitSha == headCommitSha) &&
            (identical(other.mergeRequestId, mergeRequestId) ||
                other.mergeRequestId == mergeRequestId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.realSize, realSize) ||
                other.realSize == realSize) &&
            (identical(other.patchIdSha, patchIdSha) ||
                other.patchIdSha == patchIdSha) &&
            const DeepCollectionEquality().equals(other._files, _files));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    baseCommitSha,
    startCommitSha,
    headCommitSha,
    mergeRequestId,
    createdAt,
    state,
    realSize,
    patchIdSha,
    const DeepCollectionEquality().hash(_files),
  );

  @override
  String toString() {
    return 'MergeRequestDiffVersion(id: $id, baseCommitSha: $baseCommitSha, startCommitSha: $startCommitSha, headCommitSha: $headCommitSha, mergeRequestId: $mergeRequestId, createdAt: $createdAt, state: $state, realSize: $realSize, patchIdSha: $patchIdSha, files: $files)';
  }
}

/// @nodoc
abstract mixin class _$MergeRequestDiffVersionCopyWith<$Res>
    implements $MergeRequestDiffVersionCopyWith<$Res> {
  factory _$MergeRequestDiffVersionCopyWith(
    _MergeRequestDiffVersion value,
    $Res Function(_MergeRequestDiffVersion) _then,
  ) = __$MergeRequestDiffVersionCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'base_commit_sha') String? baseCommitSha,
    @JsonKey(name: 'start_commit_sha') String? startCommitSha,
    @JsonKey(name: 'head_commit_sha') String? headCommitSha,
    @JsonKey(name: 'merge_request_id') int? mergeRequestId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    String? state,
    @JsonKey(name: 'real_size') String? realSize,
    @JsonKey(name: 'patch_id_sha') String? patchIdSha,
    @JsonKey(name: 'diffs') List<MergeRequestVersionFile>? files,
  });
}

/// @nodoc
class __$MergeRequestDiffVersionCopyWithImpl<$Res>
    implements _$MergeRequestDiffVersionCopyWith<$Res> {
  __$MergeRequestDiffVersionCopyWithImpl(this._self, this._then);

  final _MergeRequestDiffVersion _self;
  final $Res Function(_MergeRequestDiffVersion) _then;

  /// Create a copy of MergeRequestDiffVersion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? baseCommitSha = freezed,
    Object? startCommitSha = freezed,
    Object? headCommitSha = freezed,
    Object? mergeRequestId = freezed,
    Object? createdAt = freezed,
    Object? state = freezed,
    Object? realSize = freezed,
    Object? patchIdSha = freezed,
    Object? files = freezed,
  }) {
    return _then(
      _MergeRequestDiffVersion(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        baseCommitSha: freezed == baseCommitSha
            ? _self.baseCommitSha
            : baseCommitSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        startCommitSha: freezed == startCommitSha
            ? _self.startCommitSha
            : startCommitSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        headCommitSha: freezed == headCommitSha
            ? _self.headCommitSha
            : headCommitSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        mergeRequestId: freezed == mergeRequestId
            ? _self.mergeRequestId
            : mergeRequestId // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        state: freezed == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
        realSize: freezed == realSize
            ? _self.realSize
            : realSize // ignore: cast_nullable_to_non_nullable
                  as String?,
        patchIdSha: freezed == patchIdSha
            ? _self.patchIdSha
            : patchIdSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        files: freezed == files
            ? _self._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<MergeRequestVersionFile>?,
      ),
    );
  }
}

/// @nodoc
mixin _$MergeRequestVersionFile {
  @JsonKey(name: 'old_path')
  String get oldPath;
  @JsonKey(name: 'new_path')
  String get newPath;
  String? get diff;
  @JsonKey(name: 'a_mode')
  String? get oldMode;
  @JsonKey(name: 'b_mode')
  String? get newMode;
  @JsonKey(name: 'new_file')
  bool? get isNew;
  @JsonKey(name: 'deleted_file')
  bool? get isDeleted;
  @JsonKey(name: 'renamed_file')
  bool? get isRenamed;
  @JsonKey(name: 'collapsed')
  bool? get isCollapsed;
  @JsonKey(name: 'too_large')
  bool? get isTooLarge;
  @JsonKey(name: 'generated_file')
  bool? get isGenerated;

  /// Create a copy of MergeRequestVersionFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MergeRequestVersionFileCopyWith<MergeRequestVersionFile> get copyWith =>
      _$MergeRequestVersionFileCopyWithImpl<MergeRequestVersionFile>(
        this as MergeRequestVersionFile,
        _$identity,
      );

  /// Serializes this MergeRequestVersionFile to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MergeRequestVersionFile &&
            (identical(other.oldPath, oldPath) || other.oldPath == oldPath) &&
            (identical(other.newPath, newPath) || other.newPath == newPath) &&
            (identical(other.diff, diff) || other.diff == diff) &&
            (identical(other.oldMode, oldMode) || other.oldMode == oldMode) &&
            (identical(other.newMode, newMode) || other.newMode == newMode) &&
            (identical(other.isNew, isNew) || other.isNew == isNew) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.isRenamed, isRenamed) ||
                other.isRenamed == isRenamed) &&
            (identical(other.isCollapsed, isCollapsed) ||
                other.isCollapsed == isCollapsed) &&
            (identical(other.isTooLarge, isTooLarge) ||
                other.isTooLarge == isTooLarge) &&
            (identical(other.isGenerated, isGenerated) ||
                other.isGenerated == isGenerated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    oldPath,
    newPath,
    diff,
    oldMode,
    newMode,
    isNew,
    isDeleted,
    isRenamed,
    isCollapsed,
    isTooLarge,
    isGenerated,
  );

  @override
  String toString() {
    return 'MergeRequestVersionFile(oldPath: $oldPath, newPath: $newPath, diff: $diff, oldMode: $oldMode, newMode: $newMode, isNew: $isNew, isDeleted: $isDeleted, isRenamed: $isRenamed, isCollapsed: $isCollapsed, isTooLarge: $isTooLarge, isGenerated: $isGenerated)';
  }
}

/// @nodoc
abstract mixin class $MergeRequestVersionFileCopyWith<$Res> {
  factory $MergeRequestVersionFileCopyWith(
    MergeRequestVersionFile value,
    $Res Function(MergeRequestVersionFile) _then,
  ) = _$MergeRequestVersionFileCopyWithImpl;
  @useResult
  $Res call({
    @JsonKey(name: 'old_path') String oldPath,
    @JsonKey(name: 'new_path') String newPath,
    String? diff,
    @JsonKey(name: 'a_mode') String? oldMode,
    @JsonKey(name: 'b_mode') String? newMode,
    @JsonKey(name: 'new_file') bool? isNew,
    @JsonKey(name: 'deleted_file') bool? isDeleted,
    @JsonKey(name: 'renamed_file') bool? isRenamed,
    @JsonKey(name: 'collapsed') bool? isCollapsed,
    @JsonKey(name: 'too_large') bool? isTooLarge,
    @JsonKey(name: 'generated_file') bool? isGenerated,
  });
}

/// @nodoc
class _$MergeRequestVersionFileCopyWithImpl<$Res>
    implements $MergeRequestVersionFileCopyWith<$Res> {
  _$MergeRequestVersionFileCopyWithImpl(this._self, this._then);

  final MergeRequestVersionFile _self;
  final $Res Function(MergeRequestVersionFile) _then;

  /// Create a copy of MergeRequestVersionFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? oldPath = null,
    Object? newPath = null,
    Object? diff = freezed,
    Object? oldMode = freezed,
    Object? newMode = freezed,
    Object? isNew = freezed,
    Object? isDeleted = freezed,
    Object? isRenamed = freezed,
    Object? isCollapsed = freezed,
    Object? isTooLarge = freezed,
    Object? isGenerated = freezed,
  }) {
    return _then(
      _self.copyWith(
        oldPath: null == oldPath
            ? _self.oldPath
            : oldPath // ignore: cast_nullable_to_non_nullable
                  as String,
        newPath: null == newPath
            ? _self.newPath
            : newPath // ignore: cast_nullable_to_non_nullable
                  as String,
        diff: freezed == diff
            ? _self.diff
            : diff // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldMode: freezed == oldMode
            ? _self.oldMode
            : oldMode // ignore: cast_nullable_to_non_nullable
                  as String?,
        newMode: freezed == newMode
            ? _self.newMode
            : newMode // ignore: cast_nullable_to_non_nullable
                  as String?,
        isNew: freezed == isNew
            ? _self.isNew
            : isNew // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isDeleted: freezed == isDeleted
            ? _self.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isRenamed: freezed == isRenamed
            ? _self.isRenamed
            : isRenamed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isCollapsed: freezed == isCollapsed
            ? _self.isCollapsed
            : isCollapsed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isTooLarge: freezed == isTooLarge
            ? _self.isTooLarge
            : isTooLarge // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isGenerated: freezed == isGenerated
            ? _self.isGenerated
            : isGenerated // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [MergeRequestVersionFile].
extension MergeRequestVersionFilePatterns on MergeRequestVersionFile {
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
    TResult Function(_MergeRequestVersionFile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MergeRequestVersionFile() when $default != null:
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
    TResult Function(_MergeRequestVersionFile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestVersionFile():
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
    TResult? Function(_MergeRequestVersionFile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestVersionFile() when $default != null:
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
      @JsonKey(name: 'old_path') String oldPath,
      @JsonKey(name: 'new_path') String newPath,
      String? diff,
      @JsonKey(name: 'a_mode') String? oldMode,
      @JsonKey(name: 'b_mode') String? newMode,
      @JsonKey(name: 'new_file') bool? isNew,
      @JsonKey(name: 'deleted_file') bool? isDeleted,
      @JsonKey(name: 'renamed_file') bool? isRenamed,
      @JsonKey(name: 'collapsed') bool? isCollapsed,
      @JsonKey(name: 'too_large') bool? isTooLarge,
      @JsonKey(name: 'generated_file') bool? isGenerated,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MergeRequestVersionFile() when $default != null:
        return $default(
          _that.oldPath,
          _that.newPath,
          _that.diff,
          _that.oldMode,
          _that.newMode,
          _that.isNew,
          _that.isDeleted,
          _that.isRenamed,
          _that.isCollapsed,
          _that.isTooLarge,
          _that.isGenerated,
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
      @JsonKey(name: 'old_path') String oldPath,
      @JsonKey(name: 'new_path') String newPath,
      String? diff,
      @JsonKey(name: 'a_mode') String? oldMode,
      @JsonKey(name: 'b_mode') String? newMode,
      @JsonKey(name: 'new_file') bool? isNew,
      @JsonKey(name: 'deleted_file') bool? isDeleted,
      @JsonKey(name: 'renamed_file') bool? isRenamed,
      @JsonKey(name: 'collapsed') bool? isCollapsed,
      @JsonKey(name: 'too_large') bool? isTooLarge,
      @JsonKey(name: 'generated_file') bool? isGenerated,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestVersionFile():
        return $default(
          _that.oldPath,
          _that.newPath,
          _that.diff,
          _that.oldMode,
          _that.newMode,
          _that.isNew,
          _that.isDeleted,
          _that.isRenamed,
          _that.isCollapsed,
          _that.isTooLarge,
          _that.isGenerated,
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
      @JsonKey(name: 'old_path') String oldPath,
      @JsonKey(name: 'new_path') String newPath,
      String? diff,
      @JsonKey(name: 'a_mode') String? oldMode,
      @JsonKey(name: 'b_mode') String? newMode,
      @JsonKey(name: 'new_file') bool? isNew,
      @JsonKey(name: 'deleted_file') bool? isDeleted,
      @JsonKey(name: 'renamed_file') bool? isRenamed,
      @JsonKey(name: 'collapsed') bool? isCollapsed,
      @JsonKey(name: 'too_large') bool? isTooLarge,
      @JsonKey(name: 'generated_file') bool? isGenerated,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestVersionFile() when $default != null:
        return $default(
          _that.oldPath,
          _that.newPath,
          _that.diff,
          _that.oldMode,
          _that.newMode,
          _that.isNew,
          _that.isDeleted,
          _that.isRenamed,
          _that.isCollapsed,
          _that.isTooLarge,
          _that.isGenerated,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MergeRequestVersionFile implements MergeRequestVersionFile {
  const _MergeRequestVersionFile({
    @JsonKey(name: 'old_path') required this.oldPath,
    @JsonKey(name: 'new_path') required this.newPath,
    this.diff,
    @JsonKey(name: 'a_mode') this.oldMode,
    @JsonKey(name: 'b_mode') this.newMode,
    @JsonKey(name: 'new_file') this.isNew,
    @JsonKey(name: 'deleted_file') this.isDeleted,
    @JsonKey(name: 'renamed_file') this.isRenamed,
    @JsonKey(name: 'collapsed') this.isCollapsed,
    @JsonKey(name: 'too_large') this.isTooLarge,
    @JsonKey(name: 'generated_file') this.isGenerated,
  });
  factory _MergeRequestVersionFile.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestVersionFileFromJson(json);

  @override
  @JsonKey(name: 'old_path')
  final String oldPath;
  @override
  @JsonKey(name: 'new_path')
  final String newPath;
  @override
  final String? diff;
  @override
  @JsonKey(name: 'a_mode')
  final String? oldMode;
  @override
  @JsonKey(name: 'b_mode')
  final String? newMode;
  @override
  @JsonKey(name: 'new_file')
  final bool? isNew;
  @override
  @JsonKey(name: 'deleted_file')
  final bool? isDeleted;
  @override
  @JsonKey(name: 'renamed_file')
  final bool? isRenamed;
  @override
  @JsonKey(name: 'collapsed')
  final bool? isCollapsed;
  @override
  @JsonKey(name: 'too_large')
  final bool? isTooLarge;
  @override
  @JsonKey(name: 'generated_file')
  final bool? isGenerated;

  /// Create a copy of MergeRequestVersionFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MergeRequestVersionFileCopyWith<_MergeRequestVersionFile> get copyWith =>
      __$MergeRequestVersionFileCopyWithImpl<_MergeRequestVersionFile>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$MergeRequestVersionFileToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MergeRequestVersionFile &&
            (identical(other.oldPath, oldPath) || other.oldPath == oldPath) &&
            (identical(other.newPath, newPath) || other.newPath == newPath) &&
            (identical(other.diff, diff) || other.diff == diff) &&
            (identical(other.oldMode, oldMode) || other.oldMode == oldMode) &&
            (identical(other.newMode, newMode) || other.newMode == newMode) &&
            (identical(other.isNew, isNew) || other.isNew == isNew) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.isRenamed, isRenamed) ||
                other.isRenamed == isRenamed) &&
            (identical(other.isCollapsed, isCollapsed) ||
                other.isCollapsed == isCollapsed) &&
            (identical(other.isTooLarge, isTooLarge) ||
                other.isTooLarge == isTooLarge) &&
            (identical(other.isGenerated, isGenerated) ||
                other.isGenerated == isGenerated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    oldPath,
    newPath,
    diff,
    oldMode,
    newMode,
    isNew,
    isDeleted,
    isRenamed,
    isCollapsed,
    isTooLarge,
    isGenerated,
  );

  @override
  String toString() {
    return 'MergeRequestVersionFile(oldPath: $oldPath, newPath: $newPath, diff: $diff, oldMode: $oldMode, newMode: $newMode, isNew: $isNew, isDeleted: $isDeleted, isRenamed: $isRenamed, isCollapsed: $isCollapsed, isTooLarge: $isTooLarge, isGenerated: $isGenerated)';
  }
}

/// @nodoc
abstract mixin class _$MergeRequestVersionFileCopyWith<$Res>
    implements $MergeRequestVersionFileCopyWith<$Res> {
  factory _$MergeRequestVersionFileCopyWith(
    _MergeRequestVersionFile value,
    $Res Function(_MergeRequestVersionFile) _then,
  ) = __$MergeRequestVersionFileCopyWithImpl;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'old_path') String oldPath,
    @JsonKey(name: 'new_path') String newPath,
    String? diff,
    @JsonKey(name: 'a_mode') String? oldMode,
    @JsonKey(name: 'b_mode') String? newMode,
    @JsonKey(name: 'new_file') bool? isNew,
    @JsonKey(name: 'deleted_file') bool? isDeleted,
    @JsonKey(name: 'renamed_file') bool? isRenamed,
    @JsonKey(name: 'collapsed') bool? isCollapsed,
    @JsonKey(name: 'too_large') bool? isTooLarge,
    @JsonKey(name: 'generated_file') bool? isGenerated,
  });
}

/// @nodoc
class __$MergeRequestVersionFileCopyWithImpl<$Res>
    implements _$MergeRequestVersionFileCopyWith<$Res> {
  __$MergeRequestVersionFileCopyWithImpl(this._self, this._then);

  final _MergeRequestVersionFile _self;
  final $Res Function(_MergeRequestVersionFile) _then;

  /// Create a copy of MergeRequestVersionFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? oldPath = null,
    Object? newPath = null,
    Object? diff = freezed,
    Object? oldMode = freezed,
    Object? newMode = freezed,
    Object? isNew = freezed,
    Object? isDeleted = freezed,
    Object? isRenamed = freezed,
    Object? isCollapsed = freezed,
    Object? isTooLarge = freezed,
    Object? isGenerated = freezed,
  }) {
    return _then(
      _MergeRequestVersionFile(
        oldPath: null == oldPath
            ? _self.oldPath
            : oldPath // ignore: cast_nullable_to_non_nullable
                  as String,
        newPath: null == newPath
            ? _self.newPath
            : newPath // ignore: cast_nullable_to_non_nullable
                  as String,
        diff: freezed == diff
            ? _self.diff
            : diff // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldMode: freezed == oldMode
            ? _self.oldMode
            : oldMode // ignore: cast_nullable_to_non_nullable
                  as String?,
        newMode: freezed == newMode
            ? _self.newMode
            : newMode // ignore: cast_nullable_to_non_nullable
                  as String?,
        isNew: freezed == isNew
            ? _self.isNew
            : isNew // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isDeleted: freezed == isDeleted
            ? _self.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isRenamed: freezed == isRenamed
            ? _self.isRenamed
            : isRenamed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isCollapsed: freezed == isCollapsed
            ? _self.isCollapsed
            : isCollapsed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isTooLarge: freezed == isTooLarge
            ? _self.isTooLarge
            : isTooLarge // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isGenerated: freezed == isGenerated
            ? _self.isGenerated
            : isGenerated // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}
