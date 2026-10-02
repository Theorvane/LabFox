// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snippet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnippetFile {
  String get path;
  @JsonKey(name: 'raw_url')
  String? get rawUrl;

  /// Create a copy of SnippetFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnippetFileCopyWith<SnippetFile> get copyWith =>
      _$SnippetFileCopyWithImpl<SnippetFile>(this as SnippetFile, _$identity);

  /// Serializes this SnippetFile to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnippetFile &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.rawUrl, rawUrl) || other.rawUrl == rawUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, path, rawUrl);

  @override
  String toString() {
    return 'SnippetFile(path: $path, rawUrl: $rawUrl)';
  }
}

/// @nodoc
abstract mixin class $SnippetFileCopyWith<$Res> {
  factory $SnippetFileCopyWith(
    SnippetFile value,
    $Res Function(SnippetFile) _then,
  ) = _$SnippetFileCopyWithImpl;
  @useResult
  $Res call({String path, @JsonKey(name: 'raw_url') String? rawUrl});
}

/// @nodoc
class _$SnippetFileCopyWithImpl<$Res> implements $SnippetFileCopyWith<$Res> {
  _$SnippetFileCopyWithImpl(this._self, this._then);

  final SnippetFile _self;
  final $Res Function(SnippetFile) _then;

  /// Create a copy of SnippetFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? path = null, Object? rawUrl = freezed}) {
    return _then(
      _self.copyWith(
        path: null == path
            ? _self.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        rawUrl: freezed == rawUrl
            ? _self.rawUrl
            : rawUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [SnippetFile].
extension SnippetFilePatterns on SnippetFile {
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
    TResult Function(_SnippetFile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SnippetFile() when $default != null:
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
    TResult Function(_SnippetFile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SnippetFile():
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
    TResult? Function(_SnippetFile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SnippetFile() when $default != null:
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
    TResult Function(String path, @JsonKey(name: 'raw_url') String? rawUrl)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SnippetFile() when $default != null:
        return $default(_that.path, _that.rawUrl);
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
    TResult Function(String path, @JsonKey(name: 'raw_url') String? rawUrl)
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SnippetFile():
        return $default(_that.path, _that.rawUrl);
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
    TResult? Function(String path, @JsonKey(name: 'raw_url') String? rawUrl)?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SnippetFile() when $default != null:
        return $default(_that.path, _that.rawUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SnippetFile implements SnippetFile {
  const _SnippetFile({
    required this.path,
    @JsonKey(name: 'raw_url') this.rawUrl,
  });
  factory _SnippetFile.fromJson(Map<String, dynamic> json) =>
      _$SnippetFileFromJson(json);

  @override
  final String path;
  @override
  @JsonKey(name: 'raw_url')
  final String? rawUrl;

  /// Create a copy of SnippetFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnippetFileCopyWith<_SnippetFile> get copyWith =>
      __$SnippetFileCopyWithImpl<_SnippetFile>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnippetFileToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnippetFile &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.rawUrl, rawUrl) || other.rawUrl == rawUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, path, rawUrl);

  @override
  String toString() {
    return 'SnippetFile(path: $path, rawUrl: $rawUrl)';
  }
}

/// @nodoc
abstract mixin class _$SnippetFileCopyWith<$Res>
    implements $SnippetFileCopyWith<$Res> {
  factory _$SnippetFileCopyWith(
    _SnippetFile value,
    $Res Function(_SnippetFile) _then,
  ) = __$SnippetFileCopyWithImpl;
  @override
  @useResult
  $Res call({String path, @JsonKey(name: 'raw_url') String? rawUrl});
}

/// @nodoc
class __$SnippetFileCopyWithImpl<$Res> implements _$SnippetFileCopyWith<$Res> {
  __$SnippetFileCopyWithImpl(this._self, this._then);

  final _SnippetFile _self;
  final $Res Function(_SnippetFile) _then;

  /// Create a copy of SnippetFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? path = null, Object? rawUrl = freezed}) {
    return _then(
      _SnippetFile(
        path: null == path
            ? _self.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        rawUrl: freezed == rawUrl
            ? _self.rawUrl
            : rawUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
mixin _$Snippet {
  int get id;
  String get title;
  String? get description;
  String? get visibility;
  @JsonKey(name: 'file_name')
  String? get fileName;
  List<SnippetFile> get files;
  @JsonKey(name: 'web_url')
  String? get webUrl;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Snippet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnippetCopyWith<Snippet> get copyWith =>
      _$SnippetCopyWithImpl<Snippet>(this as Snippet, _$identity);

  /// Serializes this Snippet to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Snippet &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            const DeepCollectionEquality().equals(other.files, files) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    visibility,
    fileName,
    const DeepCollectionEquality().hash(files),
    webUrl,
    createdAt,
    updatedAt,
  );

  @override
  String toString() {
    return 'Snippet(id: $id, title: $title, description: $description, visibility: $visibility, fileName: $fileName, files: $files, webUrl: $webUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $SnippetCopyWith<$Res> {
  factory $SnippetCopyWith(Snippet value, $Res Function(Snippet) _then) =
      _$SnippetCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String title,
    String? description,
    String? visibility,
    @JsonKey(name: 'file_name') String? fileName,
    List<SnippetFile> files,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$SnippetCopyWithImpl<$Res> implements $SnippetCopyWith<$Res> {
  _$SnippetCopyWithImpl(this._self, this._then);

  final Snippet _self;
  final $Res Function(Snippet) _then;

  /// Create a copy of Snippet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? visibility = freezed,
    Object? fileName = freezed,
    Object? files = null,
    Object? webUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        visibility: freezed == visibility
            ? _self.visibility
            : visibility // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileName: freezed == fileName
            ? _self.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        files: null == files
            ? _self.files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<SnippetFile>,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Snippet].
extension SnippetPatterns on Snippet {
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
    TResult Function(_Snippet value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Snippet() when $default != null:
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
    TResult Function(_Snippet value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Snippet():
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
    TResult? Function(_Snippet value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Snippet() when $default != null:
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
      String title,
      String? description,
      String? visibility,
      @JsonKey(name: 'file_name') String? fileName,
      List<SnippetFile> files,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Snippet() when $default != null:
        return $default(
          _that.id,
          _that.title,
          _that.description,
          _that.visibility,
          _that.fileName,
          _that.files,
          _that.webUrl,
          _that.createdAt,
          _that.updatedAt,
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
      String title,
      String? description,
      String? visibility,
      @JsonKey(name: 'file_name') String? fileName,
      List<SnippetFile> files,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Snippet():
        return $default(
          _that.id,
          _that.title,
          _that.description,
          _that.visibility,
          _that.fileName,
          _that.files,
          _that.webUrl,
          _that.createdAt,
          _that.updatedAt,
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
      String title,
      String? description,
      String? visibility,
      @JsonKey(name: 'file_name') String? fileName,
      List<SnippetFile> files,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Snippet() when $default != null:
        return $default(
          _that.id,
          _that.title,
          _that.description,
          _that.visibility,
          _that.fileName,
          _that.files,
          _that.webUrl,
          _that.createdAt,
          _that.updatedAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Snippet implements Snippet {
  const _Snippet({
    required this.id,
    required this.title,
    this.description,
    this.visibility,
    @JsonKey(name: 'file_name') this.fileName,
    final List<SnippetFile> files = const [],
    @JsonKey(name: 'web_url') this.webUrl,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _files = files;
  factory _Snippet.fromJson(Map<String, dynamic> json) =>
      _$SnippetFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? visibility;
  @override
  @JsonKey(name: 'file_name')
  final String? fileName;
  final List<SnippetFile> _files;
  @override
  @JsonKey()
  List<SnippetFile> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  @override
  @JsonKey(name: 'web_url')
  final String? webUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of Snippet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnippetCopyWith<_Snippet> get copyWith =>
      __$SnippetCopyWithImpl<_Snippet>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnippetToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Snippet &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    visibility,
    fileName,
    const DeepCollectionEquality().hash(_files),
    webUrl,
    createdAt,
    updatedAt,
  );

  @override
  String toString() {
    return 'Snippet(id: $id, title: $title, description: $description, visibility: $visibility, fileName: $fileName, files: $files, webUrl: $webUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$SnippetCopyWith<$Res> implements $SnippetCopyWith<$Res> {
  factory _$SnippetCopyWith(_Snippet value, $Res Function(_Snippet) _then) =
      __$SnippetCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String? description,
    String? visibility,
    @JsonKey(name: 'file_name') String? fileName,
    List<SnippetFile> files,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$SnippetCopyWithImpl<$Res> implements _$SnippetCopyWith<$Res> {
  __$SnippetCopyWithImpl(this._self, this._then);

  final _Snippet _self;
  final $Res Function(_Snippet) _then;

  /// Create a copy of Snippet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? visibility = freezed,
    Object? fileName = freezed,
    Object? files = null,
    Object? webUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _Snippet(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        visibility: freezed == visibility
            ? _self.visibility
            : visibility // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileName: freezed == fileName
            ? _self.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        files: null == files
            ? _self._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<SnippetFile>,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}
