// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wiki_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WikiPage {
  String get title;
  String get slug;
  String? get content;
  String? get format;

  /// Create a copy of WikiPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WikiPageCopyWith<WikiPage> get copyWith =>
      _$WikiPageCopyWithImpl<WikiPage>(this as WikiPage, _$identity);

  /// Serializes this WikiPage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WikiPage &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.format, format) || other.format == format));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, slug, content, format);

  @override
  String toString() {
    return 'WikiPage(title: $title, slug: $slug, content: $content, format: $format)';
  }
}

/// @nodoc
abstract mixin class $WikiPageCopyWith<$Res> {
  factory $WikiPageCopyWith(WikiPage value, $Res Function(WikiPage) _then) =
      _$WikiPageCopyWithImpl;
  @useResult
  $Res call({String title, String slug, String? content, String? format});
}

/// @nodoc
class _$WikiPageCopyWithImpl<$Res> implements $WikiPageCopyWith<$Res> {
  _$WikiPageCopyWithImpl(this._self, this._then);

  final WikiPage _self;
  final $Res Function(WikiPage) _then;

  /// Create a copy of WikiPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? slug = null,
    Object? content = freezed,
    Object? format = freezed,
  }) {
    return _then(
      _self.copyWith(
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _self.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        content: freezed == content
            ? _self.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        format: freezed == format
            ? _self.format
            : format // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [WikiPage].
extension WikiPagePatterns on WikiPage {
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
    TResult Function(_WikiPage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WikiPage() when $default != null:
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
    TResult Function(_WikiPage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WikiPage():
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
    TResult? Function(_WikiPage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WikiPage() when $default != null:
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
      String title,
      String slug,
      String? content,
      String? format,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WikiPage() when $default != null:
        return $default(_that.title, _that.slug, _that.content, _that.format);
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
    TResult Function(String title, String slug, String? content, String? format)
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WikiPage():
        return $default(_that.title, _that.slug, _that.content, _that.format);
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
      String title,
      String slug,
      String? content,
      String? format,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WikiPage() when $default != null:
        return $default(_that.title, _that.slug, _that.content, _that.format);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WikiPage implements WikiPage {
  const _WikiPage({
    required this.title,
    required this.slug,
    this.content,
    this.format,
  });
  factory _WikiPage.fromJson(Map<String, dynamic> json) =>
      _$WikiPageFromJson(json);

  @override
  final String title;
  @override
  final String slug;
  @override
  final String? content;
  @override
  final String? format;

  /// Create a copy of WikiPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WikiPageCopyWith<_WikiPage> get copyWith =>
      __$WikiPageCopyWithImpl<_WikiPage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WikiPageToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WikiPage &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.format, format) || other.format == format));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, slug, content, format);

  @override
  String toString() {
    return 'WikiPage(title: $title, slug: $slug, content: $content, format: $format)';
  }
}

/// @nodoc
abstract mixin class _$WikiPageCopyWith<$Res>
    implements $WikiPageCopyWith<$Res> {
  factory _$WikiPageCopyWith(_WikiPage value, $Res Function(_WikiPage) _then) =
      __$WikiPageCopyWithImpl;
  @override
  @useResult
  $Res call({String title, String slug, String? content, String? format});
}

/// @nodoc
class __$WikiPageCopyWithImpl<$Res> implements _$WikiPageCopyWith<$Res> {
  __$WikiPageCopyWithImpl(this._self, this._then);

  final _WikiPage _self;
  final $Res Function(_WikiPage) _then;

  /// Create a copy of WikiPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? title = null,
    Object? slug = null,
    Object? content = freezed,
    Object? format = freezed,
  }) {
    return _then(
      _WikiPage(
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _self.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        content: freezed == content
            ? _self.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        format: freezed == format
            ? _self.format
            : format // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}
