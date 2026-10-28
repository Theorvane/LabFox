// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gitlab_milestone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitLabMilestone {
  int get id;
  int get iid;
  String get title;
  String get state;
  @JsonKey(name: 'project_id')
  int? get projectId;
  @JsonKey(name: 'group_id')
  int? get groupId;
  String? get description;
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @JsonKey(name: 'due_date')
  DateTime? get dueDate;
  bool? get expired;
  @JsonKey(name: 'web_url')
  String? get webUrl;

  /// Create a copy of GitLabMilestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GitLabMilestoneCopyWith<GitLabMilestone> get copyWith =>
      _$GitLabMilestoneCopyWithImpl<GitLabMilestone>(
        this as GitLabMilestone,
        _$identity,
      );

  /// Serializes this GitLabMilestone to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GitLabMilestone &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.expired, expired) || other.expired == expired) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    iid,
    title,
    state,
    projectId,
    groupId,
    description,
    startDate,
    dueDate,
    expired,
    webUrl,
  );

  @override
  String toString() {
    return 'GitLabMilestone(id: $id, iid: $iid, title: $title, state: $state, projectId: $projectId, groupId: $groupId, description: $description, startDate: $startDate, dueDate: $dueDate, expired: $expired, webUrl: $webUrl)';
  }
}

/// @nodoc
abstract mixin class $GitLabMilestoneCopyWith<$Res> {
  factory $GitLabMilestoneCopyWith(
    GitLabMilestone value,
    $Res Function(GitLabMilestone) _then,
  ) = _$GitLabMilestoneCopyWithImpl;
  @useResult
  $Res call({
    int id,
    int iid,
    String title,
    String state,
    @JsonKey(name: 'project_id') int? projectId,
    @JsonKey(name: 'group_id') int? groupId,
    String? description,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    bool? expired,
    @JsonKey(name: 'web_url') String? webUrl,
  });
}

/// @nodoc
class _$GitLabMilestoneCopyWithImpl<$Res>
    implements $GitLabMilestoneCopyWith<$Res> {
  _$GitLabMilestoneCopyWithImpl(this._self, this._then);

  final GitLabMilestone _self;
  final $Res Function(GitLabMilestone) _then;

  /// Create a copy of GitLabMilestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? iid = null,
    Object? title = null,
    Object? state = null,
    Object? projectId = freezed,
    Object? groupId = freezed,
    Object? description = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
    Object? expired = freezed,
    Object? webUrl = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        iid: null == iid
            ? _self.iid
            : iid // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        projectId: freezed == projectId
            ? _self.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as int?,
        groupId: freezed == groupId
            ? _self.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as int?,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _self.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dueDate: freezed == dueDate
            ? _self.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expired: freezed == expired
            ? _self.expired
            : expired // ignore: cast_nullable_to_non_nullable
                  as bool?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [GitLabMilestone].
extension GitLabMilestonePatterns on GitLabMilestone {
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
    TResult Function(_GitLabMilestone value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GitLabMilestone() when $default != null:
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
    TResult Function(_GitLabMilestone value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabMilestone():
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
    TResult? Function(_GitLabMilestone value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabMilestone() when $default != null:
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
      int iid,
      String title,
      String state,
      @JsonKey(name: 'project_id') int? projectId,
      @JsonKey(name: 'group_id') int? groupId,
      String? description,
      @JsonKey(name: 'start_date') DateTime? startDate,
      @JsonKey(name: 'due_date') DateTime? dueDate,
      bool? expired,
      @JsonKey(name: 'web_url') String? webUrl,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GitLabMilestone() when $default != null:
        return $default(
          _that.id,
          _that.iid,
          _that.title,
          _that.state,
          _that.projectId,
          _that.groupId,
          _that.description,
          _that.startDate,
          _that.dueDate,
          _that.expired,
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
      int iid,
      String title,
      String state,
      @JsonKey(name: 'project_id') int? projectId,
      @JsonKey(name: 'group_id') int? groupId,
      String? description,
      @JsonKey(name: 'start_date') DateTime? startDate,
      @JsonKey(name: 'due_date') DateTime? dueDate,
      bool? expired,
      @JsonKey(name: 'web_url') String? webUrl,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabMilestone():
        return $default(
          _that.id,
          _that.iid,
          _that.title,
          _that.state,
          _that.projectId,
          _that.groupId,
          _that.description,
          _that.startDate,
          _that.dueDate,
          _that.expired,
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
      int iid,
      String title,
      String state,
      @JsonKey(name: 'project_id') int? projectId,
      @JsonKey(name: 'group_id') int? groupId,
      String? description,
      @JsonKey(name: 'start_date') DateTime? startDate,
      @JsonKey(name: 'due_date') DateTime? dueDate,
      bool? expired,
      @JsonKey(name: 'web_url') String? webUrl,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabMilestone() when $default != null:
        return $default(
          _that.id,
          _that.iid,
          _that.title,
          _that.state,
          _that.projectId,
          _that.groupId,
          _that.description,
          _that.startDate,
          _that.dueDate,
          _that.expired,
          _that.webUrl,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GitLabMilestone implements GitLabMilestone {
  const _GitLabMilestone({
    required this.id,
    required this.iid,
    required this.title,
    required this.state,
    @JsonKey(name: 'project_id') this.projectId,
    @JsonKey(name: 'group_id') this.groupId,
    this.description,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'due_date') this.dueDate,
    this.expired,
    @JsonKey(name: 'web_url') this.webUrl,
  });
  factory _GitLabMilestone.fromJson(Map<String, dynamic> json) =>
      _$GitLabMilestoneFromJson(json);

  @override
  final int id;
  @override
  final int iid;
  @override
  final String title;
  @override
  final String state;
  @override
  @JsonKey(name: 'project_id')
  final int? projectId;
  @override
  @JsonKey(name: 'group_id')
  final int? groupId;
  @override
  final String? description;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  @override
  final bool? expired;
  @override
  @JsonKey(name: 'web_url')
  final String? webUrl;

  /// Create a copy of GitLabMilestone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GitLabMilestoneCopyWith<_GitLabMilestone> get copyWith =>
      __$GitLabMilestoneCopyWithImpl<_GitLabMilestone>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GitLabMilestoneToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GitLabMilestone &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.expired, expired) || other.expired == expired) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    iid,
    title,
    state,
    projectId,
    groupId,
    description,
    startDate,
    dueDate,
    expired,
    webUrl,
  );

  @override
  String toString() {
    return 'GitLabMilestone(id: $id, iid: $iid, title: $title, state: $state, projectId: $projectId, groupId: $groupId, description: $description, startDate: $startDate, dueDate: $dueDate, expired: $expired, webUrl: $webUrl)';
  }
}

/// @nodoc
abstract mixin class _$GitLabMilestoneCopyWith<$Res>
    implements $GitLabMilestoneCopyWith<$Res> {
  factory _$GitLabMilestoneCopyWith(
    _GitLabMilestone value,
    $Res Function(_GitLabMilestone) _then,
  ) = __$GitLabMilestoneCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    int iid,
    String title,
    String state,
    @JsonKey(name: 'project_id') int? projectId,
    @JsonKey(name: 'group_id') int? groupId,
    String? description,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    bool? expired,
    @JsonKey(name: 'web_url') String? webUrl,
  });
}

/// @nodoc
class __$GitLabMilestoneCopyWithImpl<$Res>
    implements _$GitLabMilestoneCopyWith<$Res> {
  __$GitLabMilestoneCopyWithImpl(this._self, this._then);

  final _GitLabMilestone _self;
  final $Res Function(_GitLabMilestone) _then;

  /// Create a copy of GitLabMilestone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? iid = null,
    Object? title = null,
    Object? state = null,
    Object? projectId = freezed,
    Object? groupId = freezed,
    Object? description = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
    Object? expired = freezed,
    Object? webUrl = freezed,
  }) {
    return _then(
      _GitLabMilestone(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        iid: null == iid
            ? _self.iid
            : iid // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        projectId: freezed == projectId
            ? _self.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as int?,
        groupId: freezed == groupId
            ? _self.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as int?,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _self.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dueDate: freezed == dueDate
            ? _self.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expired: freezed == expired
            ? _self.expired
            : expired // ignore: cast_nullable_to_non_nullable
                  as bool?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}
