// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipeline_upstream.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PipelineUpstream {
  String get id;
  String get status;
  String? get ref;
  PipelineUpstreamProject? get project;

  /// Create a copy of PipelineUpstream
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PipelineUpstreamCopyWith<PipelineUpstream> get copyWith =>
      _$PipelineUpstreamCopyWithImpl<PipelineUpstream>(
        this as PipelineUpstream,
        _$identity,
      );

  /// Serializes this PipelineUpstream to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PipelineUpstream &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.project, project) || other.project == project));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, ref, project);

  @override
  String toString() {
    return 'PipelineUpstream(id: $id, status: $status, ref: $ref, project: $project)';
  }
}

/// @nodoc
abstract mixin class $PipelineUpstreamCopyWith<$Res> {
  factory $PipelineUpstreamCopyWith(
    PipelineUpstream value,
    $Res Function(PipelineUpstream) _then,
  ) = _$PipelineUpstreamCopyWithImpl;
  @useResult
  $Res call({
    String id,
    String status,
    String? ref,
    PipelineUpstreamProject? project,
  });

  $PipelineUpstreamProjectCopyWith<$Res>? get project;
}

/// @nodoc
class _$PipelineUpstreamCopyWithImpl<$Res>
    implements $PipelineUpstreamCopyWith<$Res> {
  _$PipelineUpstreamCopyWithImpl(this._self, this._then);

  final PipelineUpstream _self;
  final $Res Function(PipelineUpstream) _then;

  /// Create a copy of PipelineUpstream
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? ref = freezed,
    Object? project = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        project: freezed == project
            ? _self.project
            : project // ignore: cast_nullable_to_non_nullable
                  as PipelineUpstreamProject?,
      ),
    );
  }

  /// Create a copy of PipelineUpstream
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PipelineUpstreamProjectCopyWith<$Res>? get project {
    if (_self.project == null) {
      return null;
    }

    return $PipelineUpstreamProjectCopyWith<$Res>(_self.project!, (value) {
      return _then(_self.copyWith(project: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PipelineUpstream].
extension PipelineUpstreamPatterns on PipelineUpstream {
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
    TResult Function(_PipelineUpstream value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstream() when $default != null:
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
    TResult Function(_PipelineUpstream value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstream():
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
    TResult? Function(_PipelineUpstream value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstream() when $default != null:
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
      String id,
      String status,
      String? ref,
      PipelineUpstreamProject? project,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstream() when $default != null:
        return $default(_that.id, _that.status, _that.ref, _that.project);
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
      String id,
      String status,
      String? ref,
      PipelineUpstreamProject? project,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstream():
        return $default(_that.id, _that.status, _that.ref, _that.project);
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
      String id,
      String status,
      String? ref,
      PipelineUpstreamProject? project,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstream() when $default != null:
        return $default(_that.id, _that.status, _that.ref, _that.project);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PipelineUpstream extends PipelineUpstream {
  const _PipelineUpstream({
    required this.id,
    required this.status,
    this.ref,
    this.project,
  }) : super._();
  factory _PipelineUpstream.fromJson(Map<String, dynamic> json) =>
      _$PipelineUpstreamFromJson(json);

  @override
  final String id;
  @override
  final String status;
  @override
  final String? ref;
  @override
  final PipelineUpstreamProject? project;

  /// Create a copy of PipelineUpstream
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PipelineUpstreamCopyWith<_PipelineUpstream> get copyWith =>
      __$PipelineUpstreamCopyWithImpl<_PipelineUpstream>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PipelineUpstreamToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PipelineUpstream &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.project, project) || other.project == project));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, ref, project);

  @override
  String toString() {
    return 'PipelineUpstream(id: $id, status: $status, ref: $ref, project: $project)';
  }
}

/// @nodoc
abstract mixin class _$PipelineUpstreamCopyWith<$Res>
    implements $PipelineUpstreamCopyWith<$Res> {
  factory _$PipelineUpstreamCopyWith(
    _PipelineUpstream value,
    $Res Function(_PipelineUpstream) _then,
  ) = __$PipelineUpstreamCopyWithImpl;
  @override
  @useResult
  $Res call({
    String id,
    String status,
    String? ref,
    PipelineUpstreamProject? project,
  });

  @override
  $PipelineUpstreamProjectCopyWith<$Res>? get project;
}

/// @nodoc
class __$PipelineUpstreamCopyWithImpl<$Res>
    implements _$PipelineUpstreamCopyWith<$Res> {
  __$PipelineUpstreamCopyWithImpl(this._self, this._then);

  final _PipelineUpstream _self;
  final $Res Function(_PipelineUpstream) _then;

  /// Create a copy of PipelineUpstream
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? ref = freezed,
    Object? project = freezed,
  }) {
    return _then(
      _PipelineUpstream(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        project: freezed == project
            ? _self.project
            : project // ignore: cast_nullable_to_non_nullable
                  as PipelineUpstreamProject?,
      ),
    );
  }

  /// Create a copy of PipelineUpstream
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PipelineUpstreamProjectCopyWith<$Res>? get project {
    if (_self.project == null) {
      return null;
    }

    return $PipelineUpstreamProjectCopyWith<$Res>(_self.project!, (value) {
      return _then(_self.copyWith(project: value));
    });
  }
}

/// @nodoc
mixin _$PipelineUpstreamProject {
  String get id;

  /// Create a copy of PipelineUpstreamProject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PipelineUpstreamProjectCopyWith<PipelineUpstreamProject> get copyWith =>
      _$PipelineUpstreamProjectCopyWithImpl<PipelineUpstreamProject>(
        this as PipelineUpstreamProject,
        _$identity,
      );

  /// Serializes this PipelineUpstreamProject to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PipelineUpstreamProject &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PipelineUpstreamProject(id: $id)';
  }
}

/// @nodoc
abstract mixin class $PipelineUpstreamProjectCopyWith<$Res> {
  factory $PipelineUpstreamProjectCopyWith(
    PipelineUpstreamProject value,
    $Res Function(PipelineUpstreamProject) _then,
  ) = _$PipelineUpstreamProjectCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$PipelineUpstreamProjectCopyWithImpl<$Res>
    implements $PipelineUpstreamProjectCopyWith<$Res> {
  _$PipelineUpstreamProjectCopyWithImpl(this._self, this._then);

  final PipelineUpstreamProject _self;
  final $Res Function(PipelineUpstreamProject) _then;

  /// Create a copy of PipelineUpstreamProject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [PipelineUpstreamProject].
extension PipelineUpstreamProjectPatterns on PipelineUpstreamProject {
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
    TResult Function(_PipelineUpstreamProject value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstreamProject() when $default != null:
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
    TResult Function(_PipelineUpstreamProject value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstreamProject():
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
    TResult? Function(_PipelineUpstreamProject value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstreamProject() when $default != null:
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
    TResult Function(String id)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstreamProject() when $default != null:
        return $default(_that.id);
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
  TResult when<TResult extends Object?>(TResult Function(String id) $default) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstreamProject():
        return $default(_that.id);
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
    TResult? Function(String id)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PipelineUpstreamProject() when $default != null:
        return $default(_that.id);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PipelineUpstreamProject implements PipelineUpstreamProject {
  const _PipelineUpstreamProject({required this.id});
  factory _PipelineUpstreamProject.fromJson(Map<String, dynamic> json) =>
      _$PipelineUpstreamProjectFromJson(json);

  @override
  final String id;

  /// Create a copy of PipelineUpstreamProject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PipelineUpstreamProjectCopyWith<_PipelineUpstreamProject> get copyWith =>
      __$PipelineUpstreamProjectCopyWithImpl<_PipelineUpstreamProject>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$PipelineUpstreamProjectToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PipelineUpstreamProject &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PipelineUpstreamProject(id: $id)';
  }
}

/// @nodoc
abstract mixin class _$PipelineUpstreamProjectCopyWith<$Res>
    implements $PipelineUpstreamProjectCopyWith<$Res> {
  factory _$PipelineUpstreamProjectCopyWith(
    _PipelineUpstreamProject value,
    $Res Function(_PipelineUpstreamProject) _then,
  ) = __$PipelineUpstreamProjectCopyWithImpl;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$PipelineUpstreamProjectCopyWithImpl<$Res>
    implements _$PipelineUpstreamProjectCopyWith<$Res> {
  __$PipelineUpstreamProjectCopyWithImpl(this._self, this._then);

  final _PipelineUpstreamProject _self;
  final $Res Function(_PipelineUpstreamProject) _then;

  /// Create a copy of PipelineUpstreamProject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? id = null}) {
    return _then(
      _PipelineUpstreamProject(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}
