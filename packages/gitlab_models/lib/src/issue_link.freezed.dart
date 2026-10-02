// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IssueLink {
  int get id;
  int get iid;
  @JsonKey(name: 'project_id')
  int get projectId;
  String get title;
  String get state;
  @JsonKey(name: 'link_type')
  String get linkType;
  @JsonKey(name: 'issue_link_id')
  int? get issueLinkId;

  /// Create a copy of IssueLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IssueLinkCopyWith<IssueLink> get copyWith =>
      _$IssueLinkCopyWithImpl<IssueLink>(this as IssueLink, _$identity);

  /// Serializes this IssueLink to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IssueLink &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.linkType, linkType) ||
                other.linkType == linkType) &&
            (identical(other.issueLinkId, issueLinkId) ||
                other.issueLinkId == issueLinkId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    iid,
    projectId,
    title,
    state,
    linkType,
    issueLinkId,
  );

  @override
  String toString() {
    return 'IssueLink(id: $id, iid: $iid, projectId: $projectId, title: $title, state: $state, linkType: $linkType, issueLinkId: $issueLinkId)';
  }
}

/// @nodoc
abstract mixin class $IssueLinkCopyWith<$Res> {
  factory $IssueLinkCopyWith(IssueLink value, $Res Function(IssueLink) _then) =
      _$IssueLinkCopyWithImpl;
  @useResult
  $Res call({
    int id,
    int iid,
    @JsonKey(name: 'project_id') int projectId,
    String title,
    String state,
    @JsonKey(name: 'link_type') String linkType,
    @JsonKey(name: 'issue_link_id') int? issueLinkId,
  });
}

/// @nodoc
class _$IssueLinkCopyWithImpl<$Res> implements $IssueLinkCopyWith<$Res> {
  _$IssueLinkCopyWithImpl(this._self, this._then);

  final IssueLink _self;
  final $Res Function(IssueLink) _then;

  /// Create a copy of IssueLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? iid = null,
    Object? projectId = null,
    Object? title = null,
    Object? state = null,
    Object? linkType = null,
    Object? issueLinkId = freezed,
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
        projectId: null == projectId
            ? _self.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        linkType: null == linkType
            ? _self.linkType
            : linkType // ignore: cast_nullable_to_non_nullable
                  as String,
        issueLinkId: freezed == issueLinkId
            ? _self.issueLinkId
            : issueLinkId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [IssueLink].
extension IssueLinkPatterns on IssueLink {
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
    TResult Function(_IssueLink value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _IssueLink() when $default != null:
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
    TResult Function(_IssueLink value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IssueLink():
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
    TResult? Function(_IssueLink value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IssueLink() when $default != null:
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
      @JsonKey(name: 'project_id') int projectId,
      String title,
      String state,
      @JsonKey(name: 'link_type') String linkType,
      @JsonKey(name: 'issue_link_id') int? issueLinkId,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _IssueLink() when $default != null:
        return $default(
          _that.id,
          _that.iid,
          _that.projectId,
          _that.title,
          _that.state,
          _that.linkType,
          _that.issueLinkId,
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
      @JsonKey(name: 'project_id') int projectId,
      String title,
      String state,
      @JsonKey(name: 'link_type') String linkType,
      @JsonKey(name: 'issue_link_id') int? issueLinkId,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IssueLink():
        return $default(
          _that.id,
          _that.iid,
          _that.projectId,
          _that.title,
          _that.state,
          _that.linkType,
          _that.issueLinkId,
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
      @JsonKey(name: 'project_id') int projectId,
      String title,
      String state,
      @JsonKey(name: 'link_type') String linkType,
      @JsonKey(name: 'issue_link_id') int? issueLinkId,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _IssueLink() when $default != null:
        return $default(
          _that.id,
          _that.iid,
          _that.projectId,
          _that.title,
          _that.state,
          _that.linkType,
          _that.issueLinkId,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _IssueLink implements IssueLink {
  const _IssueLink({
    required this.id,
    required this.iid,
    @JsonKey(name: 'project_id') required this.projectId,
    required this.title,
    required this.state,
    @JsonKey(name: 'link_type') required this.linkType,
    @JsonKey(name: 'issue_link_id') this.issueLinkId,
  });
  factory _IssueLink.fromJson(Map<String, dynamic> json) =>
      _$IssueLinkFromJson(json);

  @override
  final int id;
  @override
  final int iid;
  @override
  @JsonKey(name: 'project_id')
  final int projectId;
  @override
  final String title;
  @override
  final String state;
  @override
  @JsonKey(name: 'link_type')
  final String linkType;
  @override
  @JsonKey(name: 'issue_link_id')
  final int? issueLinkId;

  /// Create a copy of IssueLink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IssueLinkCopyWith<_IssueLink> get copyWith =>
      __$IssueLinkCopyWithImpl<_IssueLink>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$IssueLinkToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _IssueLink &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.linkType, linkType) ||
                other.linkType == linkType) &&
            (identical(other.issueLinkId, issueLinkId) ||
                other.issueLinkId == issueLinkId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    iid,
    projectId,
    title,
    state,
    linkType,
    issueLinkId,
  );

  @override
  String toString() {
    return 'IssueLink(id: $id, iid: $iid, projectId: $projectId, title: $title, state: $state, linkType: $linkType, issueLinkId: $issueLinkId)';
  }
}

/// @nodoc
abstract mixin class _$IssueLinkCopyWith<$Res>
    implements $IssueLinkCopyWith<$Res> {
  factory _$IssueLinkCopyWith(
    _IssueLink value,
    $Res Function(_IssueLink) _then,
  ) = __$IssueLinkCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    int iid,
    @JsonKey(name: 'project_id') int projectId,
    String title,
    String state,
    @JsonKey(name: 'link_type') String linkType,
    @JsonKey(name: 'issue_link_id') int? issueLinkId,
  });
}

/// @nodoc
class __$IssueLinkCopyWithImpl<$Res> implements _$IssueLinkCopyWith<$Res> {
  __$IssueLinkCopyWithImpl(this._self, this._then);

  final _IssueLink _self;
  final $Res Function(_IssueLink) _then;

  /// Create a copy of IssueLink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? iid = null,
    Object? projectId = null,
    Object? title = null,
    Object? state = null,
    Object? linkType = null,
    Object? issueLinkId = freezed,
  }) {
    return _then(
      _IssueLink(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        iid: null == iid
            ? _self.iid
            : iid // ignore: cast_nullable_to_non_nullable
                  as int,
        projectId: null == projectId
            ? _self.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        linkType: null == linkType
            ? _self.linkType
            : linkType // ignore: cast_nullable_to_non_nullable
                  as String,
        issueLinkId: freezed == issueLinkId
            ? _self.issueLinkId
            : issueLinkId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}
