// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Suggestion {
  int get id;
  @JsonKey(name: 'from_line')
  int? get fromLine;
  @JsonKey(name: 'to_line')
  int? get toLine;
  @JsonKey(name: 'from_content')
  String? get fromContent;
  @JsonKey(name: 'to_content')
  String? get toContent;
  bool? get appliable;
  bool? get applicable;
  bool? get applied;

  /// Create a copy of Suggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SuggestionCopyWith<Suggestion> get copyWith =>
      _$SuggestionCopyWithImpl<Suggestion>(this as Suggestion, _$identity);

  /// Serializes this Suggestion to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Suggestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fromLine, fromLine) ||
                other.fromLine == fromLine) &&
            (identical(other.toLine, toLine) || other.toLine == toLine) &&
            (identical(other.fromContent, fromContent) ||
                other.fromContent == fromContent) &&
            (identical(other.toContent, toContent) ||
                other.toContent == toContent) &&
            (identical(other.appliable, appliable) ||
                other.appliable == appliable) &&
            (identical(other.applicable, applicable) ||
                other.applicable == applicable) &&
            (identical(other.applied, applied) || other.applied == applied));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fromLine,
    toLine,
    fromContent,
    toContent,
    appliable,
    applicable,
    applied,
  );

  @override
  String toString() {
    return 'Suggestion(id: $id, fromLine: $fromLine, toLine: $toLine, fromContent: $fromContent, toContent: $toContent, appliable: $appliable, applicable: $applicable, applied: $applied)';
  }
}

/// @nodoc
abstract mixin class $SuggestionCopyWith<$Res> {
  factory $SuggestionCopyWith(
    Suggestion value,
    $Res Function(Suggestion) _then,
  ) = _$SuggestionCopyWithImpl;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'from_line') int? fromLine,
    @JsonKey(name: 'to_line') int? toLine,
    @JsonKey(name: 'from_content') String? fromContent,
    @JsonKey(name: 'to_content') String? toContent,
    bool? appliable,
    bool? applicable,
    bool? applied,
  });
}

/// @nodoc
class _$SuggestionCopyWithImpl<$Res> implements $SuggestionCopyWith<$Res> {
  _$SuggestionCopyWithImpl(this._self, this._then);

  final Suggestion _self;
  final $Res Function(Suggestion) _then;

  /// Create a copy of Suggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromLine = freezed,
    Object? toLine = freezed,
    Object? fromContent = freezed,
    Object? toContent = freezed,
    Object? appliable = freezed,
    Object? applicable = freezed,
    Object? applied = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        fromLine: freezed == fromLine
            ? _self.fromLine
            : fromLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        toLine: freezed == toLine
            ? _self.toLine
            : toLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        fromContent: freezed == fromContent
            ? _self.fromContent
            : fromContent // ignore: cast_nullable_to_non_nullable
                  as String?,
        toContent: freezed == toContent
            ? _self.toContent
            : toContent // ignore: cast_nullable_to_non_nullable
                  as String?,
        appliable: freezed == appliable
            ? _self.appliable
            : appliable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        applicable: freezed == applicable
            ? _self.applicable
            : applicable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        applied: freezed == applied
            ? _self.applied
            : applied // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Suggestion].
extension SuggestionPatterns on Suggestion {
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
    TResult Function(_Suggestion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Suggestion() when $default != null:
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
    TResult Function(_Suggestion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Suggestion():
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
    TResult? Function(_Suggestion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Suggestion() when $default != null:
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
      @JsonKey(name: 'from_line') int? fromLine,
      @JsonKey(name: 'to_line') int? toLine,
      @JsonKey(name: 'from_content') String? fromContent,
      @JsonKey(name: 'to_content') String? toContent,
      bool? appliable,
      bool? applicable,
      bool? applied,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Suggestion() when $default != null:
        return $default(
          _that.id,
          _that.fromLine,
          _that.toLine,
          _that.fromContent,
          _that.toContent,
          _that.appliable,
          _that.applicable,
          _that.applied,
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
      @JsonKey(name: 'from_line') int? fromLine,
      @JsonKey(name: 'to_line') int? toLine,
      @JsonKey(name: 'from_content') String? fromContent,
      @JsonKey(name: 'to_content') String? toContent,
      bool? appliable,
      bool? applicable,
      bool? applied,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Suggestion():
        return $default(
          _that.id,
          _that.fromLine,
          _that.toLine,
          _that.fromContent,
          _that.toContent,
          _that.appliable,
          _that.applicable,
          _that.applied,
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
      @JsonKey(name: 'from_line') int? fromLine,
      @JsonKey(name: 'to_line') int? toLine,
      @JsonKey(name: 'from_content') String? fromContent,
      @JsonKey(name: 'to_content') String? toContent,
      bool? appliable,
      bool? applicable,
      bool? applied,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Suggestion() when $default != null:
        return $default(
          _that.id,
          _that.fromLine,
          _that.toLine,
          _that.fromContent,
          _that.toContent,
          _that.appliable,
          _that.applicable,
          _that.applied,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Suggestion extends Suggestion {
  const _Suggestion({
    required this.id,
    @JsonKey(name: 'from_line') this.fromLine,
    @JsonKey(name: 'to_line') this.toLine,
    @JsonKey(name: 'from_content') this.fromContent,
    @JsonKey(name: 'to_content') this.toContent,
    this.appliable,
    this.applicable,
    this.applied,
  }) : super._();
  factory _Suggestion.fromJson(Map<String, dynamic> json) =>
      _$SuggestionFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'from_line')
  final int? fromLine;
  @override
  @JsonKey(name: 'to_line')
  final int? toLine;
  @override
  @JsonKey(name: 'from_content')
  final String? fromContent;
  @override
  @JsonKey(name: 'to_content')
  final String? toContent;
  @override
  final bool? appliable;
  @override
  final bool? applicable;
  @override
  final bool? applied;

  /// Create a copy of Suggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SuggestionCopyWith<_Suggestion> get copyWith =>
      __$SuggestionCopyWithImpl<_Suggestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SuggestionToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Suggestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fromLine, fromLine) ||
                other.fromLine == fromLine) &&
            (identical(other.toLine, toLine) || other.toLine == toLine) &&
            (identical(other.fromContent, fromContent) ||
                other.fromContent == fromContent) &&
            (identical(other.toContent, toContent) ||
                other.toContent == toContent) &&
            (identical(other.appliable, appliable) ||
                other.appliable == appliable) &&
            (identical(other.applicable, applicable) ||
                other.applicable == applicable) &&
            (identical(other.applied, applied) || other.applied == applied));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fromLine,
    toLine,
    fromContent,
    toContent,
    appliable,
    applicable,
    applied,
  );

  @override
  String toString() {
    return 'Suggestion(id: $id, fromLine: $fromLine, toLine: $toLine, fromContent: $fromContent, toContent: $toContent, appliable: $appliable, applicable: $applicable, applied: $applied)';
  }
}

/// @nodoc
abstract mixin class _$SuggestionCopyWith<$Res>
    implements $SuggestionCopyWith<$Res> {
  factory _$SuggestionCopyWith(
    _Suggestion value,
    $Res Function(_Suggestion) _then,
  ) = __$SuggestionCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'from_line') int? fromLine,
    @JsonKey(name: 'to_line') int? toLine,
    @JsonKey(name: 'from_content') String? fromContent,
    @JsonKey(name: 'to_content') String? toContent,
    bool? appliable,
    bool? applicable,
    bool? applied,
  });
}

/// @nodoc
class __$SuggestionCopyWithImpl<$Res> implements _$SuggestionCopyWith<$Res> {
  __$SuggestionCopyWithImpl(this._self, this._then);

  final _Suggestion _self;
  final $Res Function(_Suggestion) _then;

  /// Create a copy of Suggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? fromLine = freezed,
    Object? toLine = freezed,
    Object? fromContent = freezed,
    Object? toContent = freezed,
    Object? appliable = freezed,
    Object? applicable = freezed,
    Object? applied = freezed,
  }) {
    return _then(
      _Suggestion(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        fromLine: freezed == fromLine
            ? _self.fromLine
            : fromLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        toLine: freezed == toLine
            ? _self.toLine
            : toLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        fromContent: freezed == fromContent
            ? _self.fromContent
            : fromContent // ignore: cast_nullable_to_non_nullable
                  as String?,
        toContent: freezed == toContent
            ? _self.toContent
            : toContent // ignore: cast_nullable_to_non_nullable
                  as String?,
        appliable: freezed == appliable
            ? _self.appliable
            : appliable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        applicable: freezed == applicable
            ? _self.applicable
            : applicable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        applied: freezed == applied
            ? _self.applied
            : applied // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}
