// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_label.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectLabel {
  int get id;
  String get name;
  String get color;
  @JsonKey(name: 'text_color')
  String? get textColor;
  String? get description;
  @JsonKey(name: 'open_issues_count')
  int get openIssuesCount;
  @JsonKey(name: 'closed_issues_count')
  int get closedIssuesCount;
  @JsonKey(name: 'open_merge_requests_count')
  int get openMergeRequestsCount;
  @JsonKey(name: 'is_project_label')
  bool get isProjectLabel;
  bool get archived;

  /// Create a copy of ProjectLabel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProjectLabelCopyWith<ProjectLabel> get copyWith =>
      _$ProjectLabelCopyWithImpl<ProjectLabel>(
        this as ProjectLabel,
        _$identity,
      );

  /// Serializes this ProjectLabel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProjectLabel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.openIssuesCount, openIssuesCount) ||
                other.openIssuesCount == openIssuesCount) &&
            (identical(other.closedIssuesCount, closedIssuesCount) ||
                other.closedIssuesCount == closedIssuesCount) &&
            (identical(other.openMergeRequestsCount, openMergeRequestsCount) ||
                other.openMergeRequestsCount == openMergeRequestsCount) &&
            (identical(other.isProjectLabel, isProjectLabel) ||
                other.isProjectLabel == isProjectLabel) &&
            (identical(other.archived, archived) ||
                other.archived == archived));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    color,
    textColor,
    description,
    openIssuesCount,
    closedIssuesCount,
    openMergeRequestsCount,
    isProjectLabel,
    archived,
  );

  @override
  String toString() {
    return 'ProjectLabel(id: $id, name: $name, color: $color, textColor: $textColor, description: $description, openIssuesCount: $openIssuesCount, closedIssuesCount: $closedIssuesCount, openMergeRequestsCount: $openMergeRequestsCount, isProjectLabel: $isProjectLabel, archived: $archived)';
  }
}

/// @nodoc
abstract mixin class $ProjectLabelCopyWith<$Res> {
  factory $ProjectLabelCopyWith(
    ProjectLabel value,
    $Res Function(ProjectLabel) _then,
  ) = _$ProjectLabelCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String name,
    String color,
    @JsonKey(name: 'text_color') String? textColor,
    String? description,
    @JsonKey(name: 'open_issues_count') int openIssuesCount,
    @JsonKey(name: 'closed_issues_count') int closedIssuesCount,
    @JsonKey(name: 'open_merge_requests_count') int openMergeRequestsCount,
    @JsonKey(name: 'is_project_label') bool isProjectLabel,
    bool archived,
  });
}

/// @nodoc
class _$ProjectLabelCopyWithImpl<$Res> implements $ProjectLabelCopyWith<$Res> {
  _$ProjectLabelCopyWithImpl(this._self, this._then);

  final ProjectLabel _self;
  final $Res Function(ProjectLabel) _then;

  /// Create a copy of ProjectLabel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? color = null,
    Object? textColor = freezed,
    Object? description = freezed,
    Object? openIssuesCount = null,
    Object? closedIssuesCount = null,
    Object? openMergeRequestsCount = null,
    Object? isProjectLabel = null,
    Object? archived = null,
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
        color: null == color
            ? _self.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        textColor: freezed == textColor
            ? _self.textColor
            : textColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        openIssuesCount: null == openIssuesCount
            ? _self.openIssuesCount
            : openIssuesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        closedIssuesCount: null == closedIssuesCount
            ? _self.closedIssuesCount
            : closedIssuesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        openMergeRequestsCount: null == openMergeRequestsCount
            ? _self.openMergeRequestsCount
            : openMergeRequestsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isProjectLabel: null == isProjectLabel
            ? _self.isProjectLabel
            : isProjectLabel // ignore: cast_nullable_to_non_nullable
                  as bool,
        archived: null == archived
            ? _self.archived
            : archived // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ProjectLabel].
extension ProjectLabelPatterns on ProjectLabel {
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
    TResult Function(_ProjectLabel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectLabel() when $default != null:
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
    TResult Function(_ProjectLabel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectLabel():
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
    TResult? Function(_ProjectLabel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectLabel() when $default != null:
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
      String color,
      @JsonKey(name: 'text_color') String? textColor,
      String? description,
      @JsonKey(name: 'open_issues_count') int openIssuesCount,
      @JsonKey(name: 'closed_issues_count') int closedIssuesCount,
      @JsonKey(name: 'open_merge_requests_count') int openMergeRequestsCount,
      @JsonKey(name: 'is_project_label') bool isProjectLabel,
      bool archived,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectLabel() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.color,
          _that.textColor,
          _that.description,
          _that.openIssuesCount,
          _that.closedIssuesCount,
          _that.openMergeRequestsCount,
          _that.isProjectLabel,
          _that.archived,
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
      String name,
      String color,
      @JsonKey(name: 'text_color') String? textColor,
      String? description,
      @JsonKey(name: 'open_issues_count') int openIssuesCount,
      @JsonKey(name: 'closed_issues_count') int closedIssuesCount,
      @JsonKey(name: 'open_merge_requests_count') int openMergeRequestsCount,
      @JsonKey(name: 'is_project_label') bool isProjectLabel,
      bool archived,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectLabel():
        return $default(
          _that.id,
          _that.name,
          _that.color,
          _that.textColor,
          _that.description,
          _that.openIssuesCount,
          _that.closedIssuesCount,
          _that.openMergeRequestsCount,
          _that.isProjectLabel,
          _that.archived,
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
      String name,
      String color,
      @JsonKey(name: 'text_color') String? textColor,
      String? description,
      @JsonKey(name: 'open_issues_count') int openIssuesCount,
      @JsonKey(name: 'closed_issues_count') int closedIssuesCount,
      @JsonKey(name: 'open_merge_requests_count') int openMergeRequestsCount,
      @JsonKey(name: 'is_project_label') bool isProjectLabel,
      bool archived,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectLabel() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.color,
          _that.textColor,
          _that.description,
          _that.openIssuesCount,
          _that.closedIssuesCount,
          _that.openMergeRequestsCount,
          _that.isProjectLabel,
          _that.archived,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProjectLabel implements ProjectLabel {
  const _ProjectLabel({
    required this.id,
    required this.name,
    required this.color,
    @JsonKey(name: 'text_color') this.textColor,
    this.description,
    @JsonKey(name: 'open_issues_count') this.openIssuesCount = 0,
    @JsonKey(name: 'closed_issues_count') this.closedIssuesCount = 0,
    @JsonKey(name: 'open_merge_requests_count') this.openMergeRequestsCount = 0,
    @JsonKey(name: 'is_project_label') this.isProjectLabel = true,
    this.archived = false,
  });
  factory _ProjectLabel.fromJson(Map<String, dynamic> json) =>
      _$ProjectLabelFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String color;
  @override
  @JsonKey(name: 'text_color')
  final String? textColor;
  @override
  final String? description;
  @override
  @JsonKey(name: 'open_issues_count')
  final int openIssuesCount;
  @override
  @JsonKey(name: 'closed_issues_count')
  final int closedIssuesCount;
  @override
  @JsonKey(name: 'open_merge_requests_count')
  final int openMergeRequestsCount;
  @override
  @JsonKey(name: 'is_project_label')
  final bool isProjectLabel;
  @override
  @JsonKey()
  final bool archived;

  /// Create a copy of ProjectLabel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProjectLabelCopyWith<_ProjectLabel> get copyWith =>
      __$ProjectLabelCopyWithImpl<_ProjectLabel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProjectLabelToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProjectLabel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.openIssuesCount, openIssuesCount) ||
                other.openIssuesCount == openIssuesCount) &&
            (identical(other.closedIssuesCount, closedIssuesCount) ||
                other.closedIssuesCount == closedIssuesCount) &&
            (identical(other.openMergeRequestsCount, openMergeRequestsCount) ||
                other.openMergeRequestsCount == openMergeRequestsCount) &&
            (identical(other.isProjectLabel, isProjectLabel) ||
                other.isProjectLabel == isProjectLabel) &&
            (identical(other.archived, archived) ||
                other.archived == archived));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    color,
    textColor,
    description,
    openIssuesCount,
    closedIssuesCount,
    openMergeRequestsCount,
    isProjectLabel,
    archived,
  );

  @override
  String toString() {
    return 'ProjectLabel(id: $id, name: $name, color: $color, textColor: $textColor, description: $description, openIssuesCount: $openIssuesCount, closedIssuesCount: $closedIssuesCount, openMergeRequestsCount: $openMergeRequestsCount, isProjectLabel: $isProjectLabel, archived: $archived)';
  }
}

/// @nodoc
abstract mixin class _$ProjectLabelCopyWith<$Res>
    implements $ProjectLabelCopyWith<$Res> {
  factory _$ProjectLabelCopyWith(
    _ProjectLabel value,
    $Res Function(_ProjectLabel) _then,
  ) = __$ProjectLabelCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String color,
    @JsonKey(name: 'text_color') String? textColor,
    String? description,
    @JsonKey(name: 'open_issues_count') int openIssuesCount,
    @JsonKey(name: 'closed_issues_count') int closedIssuesCount,
    @JsonKey(name: 'open_merge_requests_count') int openMergeRequestsCount,
    @JsonKey(name: 'is_project_label') bool isProjectLabel,
    bool archived,
  });
}

/// @nodoc
class __$ProjectLabelCopyWithImpl<$Res>
    implements _$ProjectLabelCopyWith<$Res> {
  __$ProjectLabelCopyWithImpl(this._self, this._then);

  final _ProjectLabel _self;
  final $Res Function(_ProjectLabel) _then;

  /// Create a copy of ProjectLabel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? color = null,
    Object? textColor = freezed,
    Object? description = freezed,
    Object? openIssuesCount = null,
    Object? closedIssuesCount = null,
    Object? openMergeRequestsCount = null,
    Object? isProjectLabel = null,
    Object? archived = null,
  }) {
    return _then(
      _ProjectLabel(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _self.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        textColor: freezed == textColor
            ? _self.textColor
            : textColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        openIssuesCount: null == openIssuesCount
            ? _self.openIssuesCount
            : openIssuesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        closedIssuesCount: null == closedIssuesCount
            ? _self.closedIssuesCount
            : closedIssuesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        openMergeRequestsCount: null == openMergeRequestsCount
            ? _self.openMergeRequestsCount
            : openMergeRequestsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isProjectLabel: null == isProjectLabel
            ? _self.isProjectLabel
            : isProjectLabel // ignore: cast_nullable_to_non_nullable
                  as bool,
        archived: null == archived
            ? _self.archived
            : archived // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}
