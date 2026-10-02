// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectEvent {
  int get id;
  @JsonKey(name: 'project_id')
  int get projectId;
  @JsonKey(name: 'action_name')
  String get actionName;
  @JsonKey(name: 'target_id')
  int? get targetId;
  @JsonKey(name: 'target_iid')
  int? get targetIid;
  @JsonKey(name: 'target_type')
  String? get targetType;
  @JsonKey(name: 'target_title')
  String? get targetTitle;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  EventActor? get author;
  @JsonKey(name: 'author_username')
  String? get authorUsername;
  @JsonKey(name: 'push_data')
  EventPushData? get pushData;

  /// Create a copy of ProjectEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProjectEventCopyWith<ProjectEvent> get copyWith =>
      _$ProjectEventCopyWithImpl<ProjectEvent>(
        this as ProjectEvent,
        _$identity,
      );

  /// Serializes this ProjectEvent to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProjectEvent &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.actionName, actionName) ||
                other.actionName == actionName) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetIid, targetIid) ||
                other.targetIid == targetIid) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.targetTitle, targetTitle) ||
                other.targetTitle == targetTitle) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.authorUsername, authorUsername) ||
                other.authorUsername == authorUsername) &&
            (identical(other.pushData, pushData) ||
                other.pushData == pushData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    projectId,
    actionName,
    targetId,
    targetIid,
    targetType,
    targetTitle,
    createdAt,
    author,
    authorUsername,
    pushData,
  );

  @override
  String toString() {
    return 'ProjectEvent(id: $id, projectId: $projectId, actionName: $actionName, targetId: $targetId, targetIid: $targetIid, targetType: $targetType, targetTitle: $targetTitle, createdAt: $createdAt, author: $author, authorUsername: $authorUsername, pushData: $pushData)';
  }
}

/// @nodoc
abstract mixin class $ProjectEventCopyWith<$Res> {
  factory $ProjectEventCopyWith(
    ProjectEvent value,
    $Res Function(ProjectEvent) _then,
  ) = _$ProjectEventCopyWithImpl;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'project_id') int projectId,
    @JsonKey(name: 'action_name') String actionName,
    @JsonKey(name: 'target_id') int? targetId,
    @JsonKey(name: 'target_iid') int? targetIid,
    @JsonKey(name: 'target_type') String? targetType,
    @JsonKey(name: 'target_title') String? targetTitle,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    EventActor? author,
    @JsonKey(name: 'author_username') String? authorUsername,
    @JsonKey(name: 'push_data') EventPushData? pushData,
  });

  $EventActorCopyWith<$Res>? get author;
  $EventPushDataCopyWith<$Res>? get pushData;
}

/// @nodoc
class _$ProjectEventCopyWithImpl<$Res> implements $ProjectEventCopyWith<$Res> {
  _$ProjectEventCopyWithImpl(this._self, this._then);

  final ProjectEvent _self;
  final $Res Function(ProjectEvent) _then;

  /// Create a copy of ProjectEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? projectId = null,
    Object? actionName = null,
    Object? targetId = freezed,
    Object? targetIid = freezed,
    Object? targetType = freezed,
    Object? targetTitle = freezed,
    Object? createdAt = freezed,
    Object? author = freezed,
    Object? authorUsername = freezed,
    Object? pushData = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        projectId: null == projectId
            ? _self.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as int,
        actionName: null == actionName
            ? _self.actionName
            : actionName // ignore: cast_nullable_to_non_nullable
                  as String,
        targetId: freezed == targetId
            ? _self.targetId
            : targetId // ignore: cast_nullable_to_non_nullable
                  as int?,
        targetIid: freezed == targetIid
            ? _self.targetIid
            : targetIid // ignore: cast_nullable_to_non_nullable
                  as int?,
        targetType: freezed == targetType
            ? _self.targetType
            : targetType // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetTitle: freezed == targetTitle
            ? _self.targetTitle
            : targetTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        author: freezed == author
            ? _self.author
            : author // ignore: cast_nullable_to_non_nullable
                  as EventActor?,
        authorUsername: freezed == authorUsername
            ? _self.authorUsername
            : authorUsername // ignore: cast_nullable_to_non_nullable
                  as String?,
        pushData: freezed == pushData
            ? _self.pushData
            : pushData // ignore: cast_nullable_to_non_nullable
                  as EventPushData?,
      ),
    );
  }

  /// Create a copy of ProjectEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EventActorCopyWith<$Res>? get author {
    if (_self.author == null) {
      return null;
    }

    return $EventActorCopyWith<$Res>(_self.author!, (value) {
      return _then(_self.copyWith(author: value));
    });
  }

  /// Create a copy of ProjectEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EventPushDataCopyWith<$Res>? get pushData {
    if (_self.pushData == null) {
      return null;
    }

    return $EventPushDataCopyWith<$Res>(_self.pushData!, (value) {
      return _then(_self.copyWith(pushData: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ProjectEvent].
extension ProjectEventPatterns on ProjectEvent {
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
    TResult Function(_ProjectEvent value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectEvent() when $default != null:
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
    TResult Function(_ProjectEvent value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectEvent():
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
    TResult? Function(_ProjectEvent value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectEvent() when $default != null:
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
      @JsonKey(name: 'project_id') int projectId,
      @JsonKey(name: 'action_name') String actionName,
      @JsonKey(name: 'target_id') int? targetId,
      @JsonKey(name: 'target_iid') int? targetIid,
      @JsonKey(name: 'target_type') String? targetType,
      @JsonKey(name: 'target_title') String? targetTitle,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      EventActor? author,
      @JsonKey(name: 'author_username') String? authorUsername,
      @JsonKey(name: 'push_data') EventPushData? pushData,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectEvent() when $default != null:
        return $default(
          _that.id,
          _that.projectId,
          _that.actionName,
          _that.targetId,
          _that.targetIid,
          _that.targetType,
          _that.targetTitle,
          _that.createdAt,
          _that.author,
          _that.authorUsername,
          _that.pushData,
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
      @JsonKey(name: 'project_id') int projectId,
      @JsonKey(name: 'action_name') String actionName,
      @JsonKey(name: 'target_id') int? targetId,
      @JsonKey(name: 'target_iid') int? targetIid,
      @JsonKey(name: 'target_type') String? targetType,
      @JsonKey(name: 'target_title') String? targetTitle,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      EventActor? author,
      @JsonKey(name: 'author_username') String? authorUsername,
      @JsonKey(name: 'push_data') EventPushData? pushData,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectEvent():
        return $default(
          _that.id,
          _that.projectId,
          _that.actionName,
          _that.targetId,
          _that.targetIid,
          _that.targetType,
          _that.targetTitle,
          _that.createdAt,
          _that.author,
          _that.authorUsername,
          _that.pushData,
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
      @JsonKey(name: 'project_id') int projectId,
      @JsonKey(name: 'action_name') String actionName,
      @JsonKey(name: 'target_id') int? targetId,
      @JsonKey(name: 'target_iid') int? targetIid,
      @JsonKey(name: 'target_type') String? targetType,
      @JsonKey(name: 'target_title') String? targetTitle,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      EventActor? author,
      @JsonKey(name: 'author_username') String? authorUsername,
      @JsonKey(name: 'push_data') EventPushData? pushData,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectEvent() when $default != null:
        return $default(
          _that.id,
          _that.projectId,
          _that.actionName,
          _that.targetId,
          _that.targetIid,
          _that.targetType,
          _that.targetTitle,
          _that.createdAt,
          _that.author,
          _that.authorUsername,
          _that.pushData,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProjectEvent implements ProjectEvent {
  const _ProjectEvent({
    required this.id,
    @JsonKey(name: 'project_id') required this.projectId,
    @JsonKey(name: 'action_name') required this.actionName,
    @JsonKey(name: 'target_id') this.targetId,
    @JsonKey(name: 'target_iid') this.targetIid,
    @JsonKey(name: 'target_type') this.targetType,
    @JsonKey(name: 'target_title') this.targetTitle,
    @JsonKey(name: 'created_at') this.createdAt,
    this.author,
    @JsonKey(name: 'author_username') this.authorUsername,
    @JsonKey(name: 'push_data') this.pushData,
  });
  factory _ProjectEvent.fromJson(Map<String, dynamic> json) =>
      _$ProjectEventFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'project_id')
  final int projectId;
  @override
  @JsonKey(name: 'action_name')
  final String actionName;
  @override
  @JsonKey(name: 'target_id')
  final int? targetId;
  @override
  @JsonKey(name: 'target_iid')
  final int? targetIid;
  @override
  @JsonKey(name: 'target_type')
  final String? targetType;
  @override
  @JsonKey(name: 'target_title')
  final String? targetTitle;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  final EventActor? author;
  @override
  @JsonKey(name: 'author_username')
  final String? authorUsername;
  @override
  @JsonKey(name: 'push_data')
  final EventPushData? pushData;

  /// Create a copy of ProjectEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProjectEventCopyWith<_ProjectEvent> get copyWith =>
      __$ProjectEventCopyWithImpl<_ProjectEvent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProjectEventToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProjectEvent &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.actionName, actionName) ||
                other.actionName == actionName) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetIid, targetIid) ||
                other.targetIid == targetIid) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.targetTitle, targetTitle) ||
                other.targetTitle == targetTitle) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.authorUsername, authorUsername) ||
                other.authorUsername == authorUsername) &&
            (identical(other.pushData, pushData) ||
                other.pushData == pushData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    projectId,
    actionName,
    targetId,
    targetIid,
    targetType,
    targetTitle,
    createdAt,
    author,
    authorUsername,
    pushData,
  );

  @override
  String toString() {
    return 'ProjectEvent(id: $id, projectId: $projectId, actionName: $actionName, targetId: $targetId, targetIid: $targetIid, targetType: $targetType, targetTitle: $targetTitle, createdAt: $createdAt, author: $author, authorUsername: $authorUsername, pushData: $pushData)';
  }
}

/// @nodoc
abstract mixin class _$ProjectEventCopyWith<$Res>
    implements $ProjectEventCopyWith<$Res> {
  factory _$ProjectEventCopyWith(
    _ProjectEvent value,
    $Res Function(_ProjectEvent) _then,
  ) = __$ProjectEventCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'project_id') int projectId,
    @JsonKey(name: 'action_name') String actionName,
    @JsonKey(name: 'target_id') int? targetId,
    @JsonKey(name: 'target_iid') int? targetIid,
    @JsonKey(name: 'target_type') String? targetType,
    @JsonKey(name: 'target_title') String? targetTitle,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    EventActor? author,
    @JsonKey(name: 'author_username') String? authorUsername,
    @JsonKey(name: 'push_data') EventPushData? pushData,
  });

  @override
  $EventActorCopyWith<$Res>? get author;
  @override
  $EventPushDataCopyWith<$Res>? get pushData;
}

/// @nodoc
class __$ProjectEventCopyWithImpl<$Res>
    implements _$ProjectEventCopyWith<$Res> {
  __$ProjectEventCopyWithImpl(this._self, this._then);

  final _ProjectEvent _self;
  final $Res Function(_ProjectEvent) _then;

  /// Create a copy of ProjectEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? projectId = null,
    Object? actionName = null,
    Object? targetId = freezed,
    Object? targetIid = freezed,
    Object? targetType = freezed,
    Object? targetTitle = freezed,
    Object? createdAt = freezed,
    Object? author = freezed,
    Object? authorUsername = freezed,
    Object? pushData = freezed,
  }) {
    return _then(
      _ProjectEvent(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        projectId: null == projectId
            ? _self.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as int,
        actionName: null == actionName
            ? _self.actionName
            : actionName // ignore: cast_nullable_to_non_nullable
                  as String,
        targetId: freezed == targetId
            ? _self.targetId
            : targetId // ignore: cast_nullable_to_non_nullable
                  as int?,
        targetIid: freezed == targetIid
            ? _self.targetIid
            : targetIid // ignore: cast_nullable_to_non_nullable
                  as int?,
        targetType: freezed == targetType
            ? _self.targetType
            : targetType // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetTitle: freezed == targetTitle
            ? _self.targetTitle
            : targetTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        author: freezed == author
            ? _self.author
            : author // ignore: cast_nullable_to_non_nullable
                  as EventActor?,
        authorUsername: freezed == authorUsername
            ? _self.authorUsername
            : authorUsername // ignore: cast_nullable_to_non_nullable
                  as String?,
        pushData: freezed == pushData
            ? _self.pushData
            : pushData // ignore: cast_nullable_to_non_nullable
                  as EventPushData?,
      ),
    );
  }

  /// Create a copy of ProjectEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EventActorCopyWith<$Res>? get author {
    if (_self.author == null) {
      return null;
    }

    return $EventActorCopyWith<$Res>(_self.author!, (value) {
      return _then(_self.copyWith(author: value));
    });
  }

  /// Create a copy of ProjectEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EventPushDataCopyWith<$Res>? get pushData {
    if (_self.pushData == null) {
      return null;
    }

    return $EventPushDataCopyWith<$Res>(_self.pushData!, (value) {
      return _then(_self.copyWith(pushData: value));
    });
  }
}

/// @nodoc
mixin _$EventActor {
  int get id;
  String get name;
  String get username;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;

  /// Create a copy of EventActor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EventActorCopyWith<EventActor> get copyWith =>
      _$EventActorCopyWithImpl<EventActor>(this as EventActor, _$identity);

  /// Serializes this EventActor to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EventActor &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, username, avatarUrl);

  @override
  String toString() {
    return 'EventActor(id: $id, name: $name, username: $username, avatarUrl: $avatarUrl)';
  }
}

/// @nodoc
abstract mixin class $EventActorCopyWith<$Res> {
  factory $EventActorCopyWith(
    EventActor value,
    $Res Function(EventActor) _then,
  ) = _$EventActorCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String name,
    String username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  });
}

/// @nodoc
class _$EventActorCopyWithImpl<$Res> implements $EventActorCopyWith<$Res> {
  _$EventActorCopyWithImpl(this._self, this._then);

  final EventActor _self;
  final $Res Function(EventActor) _then;

  /// Create a copy of EventActor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = null,
    Object? avatarUrl = freezed,
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
        username: null == username
            ? _self.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _self.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [EventActor].
extension EventActorPatterns on EventActor {
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
    TResult Function(_EventActor value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EventActor() when $default != null:
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
    TResult Function(_EventActor value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EventActor():
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
    TResult? Function(_EventActor value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EventActor() when $default != null:
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
      String username,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EventActor() when $default != null:
        return $default(_that.id, _that.name, _that.username, _that.avatarUrl);
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
      String username,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EventActor():
        return $default(_that.id, _that.name, _that.username, _that.avatarUrl);
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
      String username,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EventActor() when $default != null:
        return $default(_that.id, _that.name, _that.username, _that.avatarUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _EventActor implements EventActor {
  const _EventActor({
    required this.id,
    required this.name,
    required this.username,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
  });
  factory _EventActor.fromJson(Map<String, dynamic> json) =>
      _$EventActorFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String username;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// Create a copy of EventActor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EventActorCopyWith<_EventActor> get copyWith =>
      __$EventActorCopyWithImpl<_EventActor>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EventActorToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EventActor &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, username, avatarUrl);

  @override
  String toString() {
    return 'EventActor(id: $id, name: $name, username: $username, avatarUrl: $avatarUrl)';
  }
}

/// @nodoc
abstract mixin class _$EventActorCopyWith<$Res>
    implements $EventActorCopyWith<$Res> {
  factory _$EventActorCopyWith(
    _EventActor value,
    $Res Function(_EventActor) _then,
  ) = __$EventActorCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  });
}

/// @nodoc
class __$EventActorCopyWithImpl<$Res> implements _$EventActorCopyWith<$Res> {
  __$EventActorCopyWithImpl(this._self, this._then);

  final _EventActor _self;
  final $Res Function(_EventActor) _then;

  /// Create a copy of EventActor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _EventActor(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _self.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _self.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
mixin _$EventPushData {
  @JsonKey(name: 'commit_count')
  int? get commitCount;
  @JsonKey(name: 'ref_count')
  int? get refCount;
  @JsonKey(name: 'ref_type')
  String? get refType;
  String? get ref;
  @JsonKey(name: 'commit_to')
  String? get commitTo;
  @JsonKey(name: 'commit_title')
  String? get commitTitle;

  /// Create a copy of EventPushData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EventPushDataCopyWith<EventPushData> get copyWith =>
      _$EventPushDataCopyWithImpl<EventPushData>(
        this as EventPushData,
        _$identity,
      );

  /// Serializes this EventPushData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EventPushData &&
            (identical(other.commitCount, commitCount) ||
                other.commitCount == commitCount) &&
            (identical(other.refCount, refCount) ||
                other.refCount == refCount) &&
            (identical(other.refType, refType) || other.refType == refType) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.commitTo, commitTo) ||
                other.commitTo == commitTo) &&
            (identical(other.commitTitle, commitTitle) ||
                other.commitTitle == commitTitle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    commitCount,
    refCount,
    refType,
    ref,
    commitTo,
    commitTitle,
  );

  @override
  String toString() {
    return 'EventPushData(commitCount: $commitCount, refCount: $refCount, refType: $refType, ref: $ref, commitTo: $commitTo, commitTitle: $commitTitle)';
  }
}

/// @nodoc
abstract mixin class $EventPushDataCopyWith<$Res> {
  factory $EventPushDataCopyWith(
    EventPushData value,
    $Res Function(EventPushData) _then,
  ) = _$EventPushDataCopyWithImpl;
  @useResult
  $Res call({
    @JsonKey(name: 'commit_count') int? commitCount,
    @JsonKey(name: 'ref_count') int? refCount,
    @JsonKey(name: 'ref_type') String? refType,
    String? ref,
    @JsonKey(name: 'commit_to') String? commitTo,
    @JsonKey(name: 'commit_title') String? commitTitle,
  });
}

/// @nodoc
class _$EventPushDataCopyWithImpl<$Res>
    implements $EventPushDataCopyWith<$Res> {
  _$EventPushDataCopyWithImpl(this._self, this._then);

  final EventPushData _self;
  final $Res Function(EventPushData) _then;

  /// Create a copy of EventPushData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commitCount = freezed,
    Object? refCount = freezed,
    Object? refType = freezed,
    Object? ref = freezed,
    Object? commitTo = freezed,
    Object? commitTitle = freezed,
  }) {
    return _then(
      _self.copyWith(
        commitCount: freezed == commitCount
            ? _self.commitCount
            : commitCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        refCount: freezed == refCount
            ? _self.refCount
            : refCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        refType: freezed == refType
            ? _self.refType
            : refType // ignore: cast_nullable_to_non_nullable
                  as String?,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        commitTo: freezed == commitTo
            ? _self.commitTo
            : commitTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        commitTitle: freezed == commitTitle
            ? _self.commitTitle
            : commitTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [EventPushData].
extension EventPushDataPatterns on EventPushData {
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
    TResult Function(_EventPushData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EventPushData() when $default != null:
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
    TResult Function(_EventPushData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EventPushData():
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
    TResult? Function(_EventPushData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EventPushData() when $default != null:
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
      @JsonKey(name: 'commit_count') int? commitCount,
      @JsonKey(name: 'ref_count') int? refCount,
      @JsonKey(name: 'ref_type') String? refType,
      String? ref,
      @JsonKey(name: 'commit_to') String? commitTo,
      @JsonKey(name: 'commit_title') String? commitTitle,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EventPushData() when $default != null:
        return $default(
          _that.commitCount,
          _that.refCount,
          _that.refType,
          _that.ref,
          _that.commitTo,
          _that.commitTitle,
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
      @JsonKey(name: 'commit_count') int? commitCount,
      @JsonKey(name: 'ref_count') int? refCount,
      @JsonKey(name: 'ref_type') String? refType,
      String? ref,
      @JsonKey(name: 'commit_to') String? commitTo,
      @JsonKey(name: 'commit_title') String? commitTitle,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EventPushData():
        return $default(
          _that.commitCount,
          _that.refCount,
          _that.refType,
          _that.ref,
          _that.commitTo,
          _that.commitTitle,
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
      @JsonKey(name: 'commit_count') int? commitCount,
      @JsonKey(name: 'ref_count') int? refCount,
      @JsonKey(name: 'ref_type') String? refType,
      String? ref,
      @JsonKey(name: 'commit_to') String? commitTo,
      @JsonKey(name: 'commit_title') String? commitTitle,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EventPushData() when $default != null:
        return $default(
          _that.commitCount,
          _that.refCount,
          _that.refType,
          _that.ref,
          _that.commitTo,
          _that.commitTitle,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _EventPushData implements EventPushData {
  const _EventPushData({
    @JsonKey(name: 'commit_count') this.commitCount,
    @JsonKey(name: 'ref_count') this.refCount,
    @JsonKey(name: 'ref_type') this.refType,
    this.ref,
    @JsonKey(name: 'commit_to') this.commitTo,
    @JsonKey(name: 'commit_title') this.commitTitle,
  });
  factory _EventPushData.fromJson(Map<String, dynamic> json) =>
      _$EventPushDataFromJson(json);

  @override
  @JsonKey(name: 'commit_count')
  final int? commitCount;
  @override
  @JsonKey(name: 'ref_count')
  final int? refCount;
  @override
  @JsonKey(name: 'ref_type')
  final String? refType;
  @override
  final String? ref;
  @override
  @JsonKey(name: 'commit_to')
  final String? commitTo;
  @override
  @JsonKey(name: 'commit_title')
  final String? commitTitle;

  /// Create a copy of EventPushData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EventPushDataCopyWith<_EventPushData> get copyWith =>
      __$EventPushDataCopyWithImpl<_EventPushData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EventPushDataToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EventPushData &&
            (identical(other.commitCount, commitCount) ||
                other.commitCount == commitCount) &&
            (identical(other.refCount, refCount) ||
                other.refCount == refCount) &&
            (identical(other.refType, refType) || other.refType == refType) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.commitTo, commitTo) ||
                other.commitTo == commitTo) &&
            (identical(other.commitTitle, commitTitle) ||
                other.commitTitle == commitTitle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    commitCount,
    refCount,
    refType,
    ref,
    commitTo,
    commitTitle,
  );

  @override
  String toString() {
    return 'EventPushData(commitCount: $commitCount, refCount: $refCount, refType: $refType, ref: $ref, commitTo: $commitTo, commitTitle: $commitTitle)';
  }
}

/// @nodoc
abstract mixin class _$EventPushDataCopyWith<$Res>
    implements $EventPushDataCopyWith<$Res> {
  factory _$EventPushDataCopyWith(
    _EventPushData value,
    $Res Function(_EventPushData) _then,
  ) = __$EventPushDataCopyWithImpl;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'commit_count') int? commitCount,
    @JsonKey(name: 'ref_count') int? refCount,
    @JsonKey(name: 'ref_type') String? refType,
    String? ref,
    @JsonKey(name: 'commit_to') String? commitTo,
    @JsonKey(name: 'commit_title') String? commitTitle,
  });
}

/// @nodoc
class __$EventPushDataCopyWithImpl<$Res>
    implements _$EventPushDataCopyWith<$Res> {
  __$EventPushDataCopyWithImpl(this._self, this._then);

  final _EventPushData _self;
  final $Res Function(_EventPushData) _then;

  /// Create a copy of EventPushData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? commitCount = freezed,
    Object? refCount = freezed,
    Object? refType = freezed,
    Object? ref = freezed,
    Object? commitTo = freezed,
    Object? commitTitle = freezed,
  }) {
    return _then(
      _EventPushData(
        commitCount: freezed == commitCount
            ? _self.commitCount
            : commitCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        refCount: freezed == refCount
            ? _self.refCount
            : refCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        refType: freezed == refType
            ? _self.refType
            : refType // ignore: cast_nullable_to_non_nullable
                  as String?,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        commitTo: freezed == commitTo
            ? _self.commitTo
            : commitTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        commitTitle: freezed == commitTitle
            ? _self.commitTitle
            : commitTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}
