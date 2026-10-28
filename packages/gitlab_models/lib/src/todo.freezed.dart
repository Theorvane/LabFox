// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Todo {
  int get id;
  String get state;
  @JsonKey(name: 'action_name')
  String get actionName;
  @JsonKey(name: 'target_type')
  String? get targetType;
  @JsonKey(name: 'target_url')
  String? get targetUrl;
  String? get body;
  User? get author;
  Project? get project;
  TodoTarget? get target;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TodoCopyWith<Todo> get copyWith =>
      _$TodoCopyWithImpl<Todo>(this as Todo, _$identity);

  /// Serializes this Todo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Todo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.actionName, actionName) ||
                other.actionName == actionName) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.targetUrl, targetUrl) ||
                other.targetUrl == targetUrl) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.project, project) || other.project == project) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    state,
    actionName,
    targetType,
    targetUrl,
    body,
    author,
    project,
    target,
    createdAt,
  );

  @override
  String toString() {
    return 'Todo(id: $id, state: $state, actionName: $actionName, targetType: $targetType, targetUrl: $targetUrl, body: $body, author: $author, project: $project, target: $target, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $TodoCopyWith<$Res> {
  factory $TodoCopyWith(Todo value, $Res Function(Todo) _then) =
      _$TodoCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String state,
    @JsonKey(name: 'action_name') String actionName,
    @JsonKey(name: 'target_type') String? targetType,
    @JsonKey(name: 'target_url') String? targetUrl,
    String? body,
    User? author,
    Project? project,
    TodoTarget? target,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });

  $UserCopyWith<$Res>? get author;
  $ProjectCopyWith<$Res>? get project;
  $TodoTargetCopyWith<$Res>? get target;
}

/// @nodoc
class _$TodoCopyWithImpl<$Res> implements $TodoCopyWith<$Res> {
  _$TodoCopyWithImpl(this._self, this._then);

  final Todo _self;
  final $Res Function(Todo) _then;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? state = null,
    Object? actionName = null,
    Object? targetType = freezed,
    Object? targetUrl = freezed,
    Object? body = freezed,
    Object? author = freezed,
    Object? project = freezed,
    Object? target = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        actionName: null == actionName
            ? _self.actionName
            : actionName // ignore: cast_nullable_to_non_nullable
                  as String,
        targetType: freezed == targetType
            ? _self.targetType
            : targetType // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetUrl: freezed == targetUrl
            ? _self.targetUrl
            : targetUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        body: freezed == body
            ? _self.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String?,
        author: freezed == author
            ? _self.author
            : author // ignore: cast_nullable_to_non_nullable
                  as User?,
        project: freezed == project
            ? _self.project
            : project // ignore: cast_nullable_to_non_nullable
                  as Project?,
        target: freezed == target
            ? _self.target
            : target // ignore: cast_nullable_to_non_nullable
                  as TodoTarget?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get author {
    if (_self.author == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_self.author!, (value) {
      return _then(_self.copyWith(author: value));
    });
  }

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProjectCopyWith<$Res>? get project {
    if (_self.project == null) {
      return null;
    }

    return $ProjectCopyWith<$Res>(_self.project!, (value) {
      return _then(_self.copyWith(project: value));
    });
  }

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoTargetCopyWith<$Res>? get target {
    if (_self.target == null) {
      return null;
    }

    return $TodoTargetCopyWith<$Res>(_self.target!, (value) {
      return _then(_self.copyWith(target: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Todo].
extension TodoPatterns on Todo {
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
    TResult Function(_Todo value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Todo() when $default != null:
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
  TResult map<TResult extends Object?>(TResult Function(_Todo value) $default) {
    final _that = this;
    switch (_that) {
      case _Todo():
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
    TResult? Function(_Todo value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Todo() when $default != null:
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
      String state,
      @JsonKey(name: 'action_name') String actionName,
      @JsonKey(name: 'target_type') String? targetType,
      @JsonKey(name: 'target_url') String? targetUrl,
      String? body,
      User? author,
      Project? project,
      TodoTarget? target,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Todo() when $default != null:
        return $default(
          _that.id,
          _that.state,
          _that.actionName,
          _that.targetType,
          _that.targetUrl,
          _that.body,
          _that.author,
          _that.project,
          _that.target,
          _that.createdAt,
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
      String state,
      @JsonKey(name: 'action_name') String actionName,
      @JsonKey(name: 'target_type') String? targetType,
      @JsonKey(name: 'target_url') String? targetUrl,
      String? body,
      User? author,
      Project? project,
      TodoTarget? target,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Todo():
        return $default(
          _that.id,
          _that.state,
          _that.actionName,
          _that.targetType,
          _that.targetUrl,
          _that.body,
          _that.author,
          _that.project,
          _that.target,
          _that.createdAt,
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
      String state,
      @JsonKey(name: 'action_name') String actionName,
      @JsonKey(name: 'target_type') String? targetType,
      @JsonKey(name: 'target_url') String? targetUrl,
      String? body,
      User? author,
      Project? project,
      TodoTarget? target,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Todo() when $default != null:
        return $default(
          _that.id,
          _that.state,
          _that.actionName,
          _that.targetType,
          _that.targetUrl,
          _that.body,
          _that.author,
          _that.project,
          _that.target,
          _that.createdAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Todo extends Todo {
  const _Todo({
    required this.id,
    required this.state,
    @JsonKey(name: 'action_name') this.actionName = '',
    @JsonKey(name: 'target_type') this.targetType,
    @JsonKey(name: 'target_url') this.targetUrl,
    this.body,
    this.author,
    this.project,
    this.target,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : super._();
  factory _Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  @override
  final int id;
  @override
  final String state;
  @override
  @JsonKey(name: 'action_name')
  final String actionName;
  @override
  @JsonKey(name: 'target_type')
  final String? targetType;
  @override
  @JsonKey(name: 'target_url')
  final String? targetUrl;
  @override
  final String? body;
  @override
  final User? author;
  @override
  final Project? project;
  @override
  final TodoTarget? target;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TodoCopyWith<_Todo> get copyWith =>
      __$TodoCopyWithImpl<_Todo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TodoToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Todo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.actionName, actionName) ||
                other.actionName == actionName) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.targetUrl, targetUrl) ||
                other.targetUrl == targetUrl) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.project, project) || other.project == project) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    state,
    actionName,
    targetType,
    targetUrl,
    body,
    author,
    project,
    target,
    createdAt,
  );

  @override
  String toString() {
    return 'Todo(id: $id, state: $state, actionName: $actionName, targetType: $targetType, targetUrl: $targetUrl, body: $body, author: $author, project: $project, target: $target, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$TodoCopyWith<$Res> implements $TodoCopyWith<$Res> {
  factory _$TodoCopyWith(_Todo value, $Res Function(_Todo) _then) =
      __$TodoCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String state,
    @JsonKey(name: 'action_name') String actionName,
    @JsonKey(name: 'target_type') String? targetType,
    @JsonKey(name: 'target_url') String? targetUrl,
    String? body,
    User? author,
    Project? project,
    TodoTarget? target,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });

  @override
  $UserCopyWith<$Res>? get author;
  @override
  $ProjectCopyWith<$Res>? get project;
  @override
  $TodoTargetCopyWith<$Res>? get target;
}

/// @nodoc
class __$TodoCopyWithImpl<$Res> implements _$TodoCopyWith<$Res> {
  __$TodoCopyWithImpl(this._self, this._then);

  final _Todo _self;
  final $Res Function(_Todo) _then;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? state = null,
    Object? actionName = null,
    Object? targetType = freezed,
    Object? targetUrl = freezed,
    Object? body = freezed,
    Object? author = freezed,
    Object? project = freezed,
    Object? target = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _Todo(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        actionName: null == actionName
            ? _self.actionName
            : actionName // ignore: cast_nullable_to_non_nullable
                  as String,
        targetType: freezed == targetType
            ? _self.targetType
            : targetType // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetUrl: freezed == targetUrl
            ? _self.targetUrl
            : targetUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        body: freezed == body
            ? _self.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String?,
        author: freezed == author
            ? _self.author
            : author // ignore: cast_nullable_to_non_nullable
                  as User?,
        project: freezed == project
            ? _self.project
            : project // ignore: cast_nullable_to_non_nullable
                  as Project?,
        target: freezed == target
            ? _self.target
            : target // ignore: cast_nullable_to_non_nullable
                  as TodoTarget?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get author {
    if (_self.author == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_self.author!, (value) {
      return _then(_self.copyWith(author: value));
    });
  }

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProjectCopyWith<$Res>? get project {
    if (_self.project == null) {
      return null;
    }

    return $ProjectCopyWith<$Res>(_self.project!, (value) {
      return _then(_self.copyWith(project: value));
    });
  }

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodoTargetCopyWith<$Res>? get target {
    if (_self.target == null) {
      return null;
    }

    return $TodoTargetCopyWith<$Res>(_self.target!, (value) {
      return _then(_self.copyWith(target: value));
    });
  }
}

/// @nodoc
mixin _$TodoTarget {
  int? get id;
  int? get iid;
  String? get title;
  String? get state;

  /// Create a copy of TodoTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TodoTargetCopyWith<TodoTarget> get copyWith =>
      _$TodoTargetCopyWithImpl<TodoTarget>(this as TodoTarget, _$identity);

  /// Serializes this TodoTarget to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TodoTarget &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.state, state) || other.state == state));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, iid, title, state);

  @override
  String toString() {
    return 'TodoTarget(id: $id, iid: $iid, title: $title, state: $state)';
  }
}

/// @nodoc
abstract mixin class $TodoTargetCopyWith<$Res> {
  factory $TodoTargetCopyWith(
    TodoTarget value,
    $Res Function(TodoTarget) _then,
  ) = _$TodoTargetCopyWithImpl;
  @useResult
  $Res call({int? id, int? iid, String? title, String? state});
}

/// @nodoc
class _$TodoTargetCopyWithImpl<$Res> implements $TodoTargetCopyWith<$Res> {
  _$TodoTargetCopyWithImpl(this._self, this._then);

  final TodoTarget _self;
  final $Res Function(TodoTarget) _then;

  /// Create a copy of TodoTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? iid = freezed,
    Object? title = freezed,
    Object? state = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        iid: freezed == iid
            ? _self.iid
            : iid // ignore: cast_nullable_to_non_nullable
                  as int?,
        title: freezed == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        state: freezed == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [TodoTarget].
extension TodoTargetPatterns on TodoTarget {
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
    TResult Function(_TodoTarget value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TodoTarget() when $default != null:
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
    TResult Function(_TodoTarget value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TodoTarget():
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
    TResult? Function(_TodoTarget value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TodoTarget() when $default != null:
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
    TResult Function(int? id, int? iid, String? title, String? state)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TodoTarget() when $default != null:
        return $default(_that.id, _that.iid, _that.title, _that.state);
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
    TResult Function(int? id, int? iid, String? title, String? state) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TodoTarget():
        return $default(_that.id, _that.iid, _that.title, _that.state);
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
    TResult? Function(int? id, int? iid, String? title, String? state)?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TodoTarget() when $default != null:
        return $default(_that.id, _that.iid, _that.title, _that.state);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TodoTarget implements TodoTarget {
  const _TodoTarget({this.id, this.iid, this.title, this.state});
  factory _TodoTarget.fromJson(Map<String, dynamic> json) =>
      _$TodoTargetFromJson(json);

  @override
  final int? id;
  @override
  final int? iid;
  @override
  final String? title;
  @override
  final String? state;

  /// Create a copy of TodoTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TodoTargetCopyWith<_TodoTarget> get copyWith =>
      __$TodoTargetCopyWithImpl<_TodoTarget>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TodoTargetToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TodoTarget &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.state, state) || other.state == state));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, iid, title, state);

  @override
  String toString() {
    return 'TodoTarget(id: $id, iid: $iid, title: $title, state: $state)';
  }
}

/// @nodoc
abstract mixin class _$TodoTargetCopyWith<$Res>
    implements $TodoTargetCopyWith<$Res> {
  factory _$TodoTargetCopyWith(
    _TodoTarget value,
    $Res Function(_TodoTarget) _then,
  ) = __$TodoTargetCopyWithImpl;
  @override
  @useResult
  $Res call({int? id, int? iid, String? title, String? state});
}

/// @nodoc
class __$TodoTargetCopyWithImpl<$Res> implements _$TodoTargetCopyWith<$Res> {
  __$TodoTargetCopyWithImpl(this._self, this._then);

  final _TodoTarget _self;
  final $Res Function(_TodoTarget) _then;

  /// Create a copy of TodoTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? iid = freezed,
    Object? title = freezed,
    Object? state = freezed,
  }) {
    return _then(
      _TodoTarget(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        iid: freezed == iid
            ? _self.iid
            : iid // ignore: cast_nullable_to_non_nullable
                  as int?,
        title: freezed == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        state: freezed == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}
