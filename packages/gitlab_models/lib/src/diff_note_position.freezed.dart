// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diff_note_position.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiffNotePosition {
  @JsonKey(name: 'base_sha')
  String? get baseSha;
  @JsonKey(name: 'start_sha')
  String? get startSha;
  @JsonKey(name: 'head_sha')
  String? get headSha;
  @JsonKey(name: 'old_path')
  String? get oldPath;
  @JsonKey(name: 'new_path')
  String? get newPath;
  @JsonKey(name: 'position_type')
  String? get positionType;
  @JsonKey(name: 'old_line')
  int? get oldLine;
  @JsonKey(name: 'new_line')
  int? get newLine;
  @JsonKey(name: 'line_range')
  DiffNoteLineRange? get lineRange;
  int? get width;
  int? get height;
  double? get x;
  double? get y;

  /// Create a copy of DiffNotePosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DiffNotePositionCopyWith<DiffNotePosition> get copyWith =>
      _$DiffNotePositionCopyWithImpl<DiffNotePosition>(
        this as DiffNotePosition,
        _$identity,
      );

  /// Serializes this DiffNotePosition to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DiffNotePosition &&
            (identical(other.baseSha, baseSha) || other.baseSha == baseSha) &&
            (identical(other.startSha, startSha) ||
                other.startSha == startSha) &&
            (identical(other.headSha, headSha) || other.headSha == headSha) &&
            (identical(other.oldPath, oldPath) || other.oldPath == oldPath) &&
            (identical(other.newPath, newPath) || other.newPath == newPath) &&
            (identical(other.positionType, positionType) ||
                other.positionType == positionType) &&
            (identical(other.oldLine, oldLine) || other.oldLine == oldLine) &&
            (identical(other.newLine, newLine) || other.newLine == newLine) &&
            (identical(other.lineRange, lineRange) ||
                other.lineRange == lineRange) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    baseSha,
    startSha,
    headSha,
    oldPath,
    newPath,
    positionType,
    oldLine,
    newLine,
    lineRange,
    width,
    height,
    x,
    y,
  );

  @override
  String toString() {
    return 'DiffNotePosition(baseSha: $baseSha, startSha: $startSha, headSha: $headSha, oldPath: $oldPath, newPath: $newPath, positionType: $positionType, oldLine: $oldLine, newLine: $newLine, lineRange: $lineRange, width: $width, height: $height, x: $x, y: $y)';
  }
}

/// @nodoc
abstract mixin class $DiffNotePositionCopyWith<$Res> {
  factory $DiffNotePositionCopyWith(
    DiffNotePosition value,
    $Res Function(DiffNotePosition) _then,
  ) = _$DiffNotePositionCopyWithImpl;
  @useResult
  $Res call({
    @JsonKey(name: 'base_sha') String? baseSha,
    @JsonKey(name: 'start_sha') String? startSha,
    @JsonKey(name: 'head_sha') String? headSha,
    @JsonKey(name: 'old_path') String? oldPath,
    @JsonKey(name: 'new_path') String? newPath,
    @JsonKey(name: 'position_type') String? positionType,
    @JsonKey(name: 'old_line') int? oldLine,
    @JsonKey(name: 'new_line') int? newLine,
    @JsonKey(name: 'line_range') DiffNoteLineRange? lineRange,
    int? width,
    int? height,
    double? x,
    double? y,
  });

  $DiffNoteLineRangeCopyWith<$Res>? get lineRange;
}

/// @nodoc
class _$DiffNotePositionCopyWithImpl<$Res>
    implements $DiffNotePositionCopyWith<$Res> {
  _$DiffNotePositionCopyWithImpl(this._self, this._then);

  final DiffNotePosition _self;
  final $Res Function(DiffNotePosition) _then;

  /// Create a copy of DiffNotePosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseSha = freezed,
    Object? startSha = freezed,
    Object? headSha = freezed,
    Object? oldPath = freezed,
    Object? newPath = freezed,
    Object? positionType = freezed,
    Object? oldLine = freezed,
    Object? newLine = freezed,
    Object? lineRange = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? x = freezed,
    Object? y = freezed,
  }) {
    return _then(
      _self.copyWith(
        baseSha: freezed == baseSha
            ? _self.baseSha
            : baseSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        startSha: freezed == startSha
            ? _self.startSha
            : startSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        headSha: freezed == headSha
            ? _self.headSha
            : headSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldPath: freezed == oldPath
            ? _self.oldPath
            : oldPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        newPath: freezed == newPath
            ? _self.newPath
            : newPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        positionType: freezed == positionType
            ? _self.positionType
            : positionType // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldLine: freezed == oldLine
            ? _self.oldLine
            : oldLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        newLine: freezed == newLine
            ? _self.newLine
            : newLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        lineRange: freezed == lineRange
            ? _self.lineRange
            : lineRange // ignore: cast_nullable_to_non_nullable
                  as DiffNoteLineRange?,
        width: freezed == width
            ? _self.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _self.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        x: freezed == x
            ? _self.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double?,
        y: freezed == y
            ? _self.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }

  /// Create a copy of DiffNotePosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiffNoteLineRangeCopyWith<$Res>? get lineRange {
    if (_self.lineRange == null) {
      return null;
    }

    return $DiffNoteLineRangeCopyWith<$Res>(_self.lineRange!, (value) {
      return _then(_self.copyWith(lineRange: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DiffNotePosition].
extension DiffNotePositionPatterns on DiffNotePosition {
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
    TResult Function(_DiffNotePosition value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DiffNotePosition() when $default != null:
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
    TResult Function(_DiffNotePosition value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNotePosition():
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
    TResult? Function(_DiffNotePosition value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNotePosition() when $default != null:
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
      @JsonKey(name: 'base_sha') String? baseSha,
      @JsonKey(name: 'start_sha') String? startSha,
      @JsonKey(name: 'head_sha') String? headSha,
      @JsonKey(name: 'old_path') String? oldPath,
      @JsonKey(name: 'new_path') String? newPath,
      @JsonKey(name: 'position_type') String? positionType,
      @JsonKey(name: 'old_line') int? oldLine,
      @JsonKey(name: 'new_line') int? newLine,
      @JsonKey(name: 'line_range') DiffNoteLineRange? lineRange,
      int? width,
      int? height,
      double? x,
      double? y,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DiffNotePosition() when $default != null:
        return $default(
          _that.baseSha,
          _that.startSha,
          _that.headSha,
          _that.oldPath,
          _that.newPath,
          _that.positionType,
          _that.oldLine,
          _that.newLine,
          _that.lineRange,
          _that.width,
          _that.height,
          _that.x,
          _that.y,
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
      @JsonKey(name: 'base_sha') String? baseSha,
      @JsonKey(name: 'start_sha') String? startSha,
      @JsonKey(name: 'head_sha') String? headSha,
      @JsonKey(name: 'old_path') String? oldPath,
      @JsonKey(name: 'new_path') String? newPath,
      @JsonKey(name: 'position_type') String? positionType,
      @JsonKey(name: 'old_line') int? oldLine,
      @JsonKey(name: 'new_line') int? newLine,
      @JsonKey(name: 'line_range') DiffNoteLineRange? lineRange,
      int? width,
      int? height,
      double? x,
      double? y,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNotePosition():
        return $default(
          _that.baseSha,
          _that.startSha,
          _that.headSha,
          _that.oldPath,
          _that.newPath,
          _that.positionType,
          _that.oldLine,
          _that.newLine,
          _that.lineRange,
          _that.width,
          _that.height,
          _that.x,
          _that.y,
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
      @JsonKey(name: 'base_sha') String? baseSha,
      @JsonKey(name: 'start_sha') String? startSha,
      @JsonKey(name: 'head_sha') String? headSha,
      @JsonKey(name: 'old_path') String? oldPath,
      @JsonKey(name: 'new_path') String? newPath,
      @JsonKey(name: 'position_type') String? positionType,
      @JsonKey(name: 'old_line') int? oldLine,
      @JsonKey(name: 'new_line') int? newLine,
      @JsonKey(name: 'line_range') DiffNoteLineRange? lineRange,
      int? width,
      int? height,
      double? x,
      double? y,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNotePosition() when $default != null:
        return $default(
          _that.baseSha,
          _that.startSha,
          _that.headSha,
          _that.oldPath,
          _that.newPath,
          _that.positionType,
          _that.oldLine,
          _that.newLine,
          _that.lineRange,
          _that.width,
          _that.height,
          _that.x,
          _that.y,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DiffNotePosition implements DiffNotePosition {
  const _DiffNotePosition({
    @JsonKey(name: 'base_sha') this.baseSha,
    @JsonKey(name: 'start_sha') this.startSha,
    @JsonKey(name: 'head_sha') this.headSha,
    @JsonKey(name: 'old_path') this.oldPath,
    @JsonKey(name: 'new_path') this.newPath,
    @JsonKey(name: 'position_type') this.positionType,
    @JsonKey(name: 'old_line') this.oldLine,
    @JsonKey(name: 'new_line') this.newLine,
    @JsonKey(name: 'line_range') this.lineRange,
    this.width,
    this.height,
    this.x,
    this.y,
  });
  factory _DiffNotePosition.fromJson(Map<String, dynamic> json) =>
      _$DiffNotePositionFromJson(json);

  @override
  @JsonKey(name: 'base_sha')
  final String? baseSha;
  @override
  @JsonKey(name: 'start_sha')
  final String? startSha;
  @override
  @JsonKey(name: 'head_sha')
  final String? headSha;
  @override
  @JsonKey(name: 'old_path')
  final String? oldPath;
  @override
  @JsonKey(name: 'new_path')
  final String? newPath;
  @override
  @JsonKey(name: 'position_type')
  final String? positionType;
  @override
  @JsonKey(name: 'old_line')
  final int? oldLine;
  @override
  @JsonKey(name: 'new_line')
  final int? newLine;
  @override
  @JsonKey(name: 'line_range')
  final DiffNoteLineRange? lineRange;
  @override
  final int? width;
  @override
  final int? height;
  @override
  final double? x;
  @override
  final double? y;

  /// Create a copy of DiffNotePosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DiffNotePositionCopyWith<_DiffNotePosition> get copyWith =>
      __$DiffNotePositionCopyWithImpl<_DiffNotePosition>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DiffNotePositionToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DiffNotePosition &&
            (identical(other.baseSha, baseSha) || other.baseSha == baseSha) &&
            (identical(other.startSha, startSha) ||
                other.startSha == startSha) &&
            (identical(other.headSha, headSha) || other.headSha == headSha) &&
            (identical(other.oldPath, oldPath) || other.oldPath == oldPath) &&
            (identical(other.newPath, newPath) || other.newPath == newPath) &&
            (identical(other.positionType, positionType) ||
                other.positionType == positionType) &&
            (identical(other.oldLine, oldLine) || other.oldLine == oldLine) &&
            (identical(other.newLine, newLine) || other.newLine == newLine) &&
            (identical(other.lineRange, lineRange) ||
                other.lineRange == lineRange) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    baseSha,
    startSha,
    headSha,
    oldPath,
    newPath,
    positionType,
    oldLine,
    newLine,
    lineRange,
    width,
    height,
    x,
    y,
  );

  @override
  String toString() {
    return 'DiffNotePosition(baseSha: $baseSha, startSha: $startSha, headSha: $headSha, oldPath: $oldPath, newPath: $newPath, positionType: $positionType, oldLine: $oldLine, newLine: $newLine, lineRange: $lineRange, width: $width, height: $height, x: $x, y: $y)';
  }
}

/// @nodoc
abstract mixin class _$DiffNotePositionCopyWith<$Res>
    implements $DiffNotePositionCopyWith<$Res> {
  factory _$DiffNotePositionCopyWith(
    _DiffNotePosition value,
    $Res Function(_DiffNotePosition) _then,
  ) = __$DiffNotePositionCopyWithImpl;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'base_sha') String? baseSha,
    @JsonKey(name: 'start_sha') String? startSha,
    @JsonKey(name: 'head_sha') String? headSha,
    @JsonKey(name: 'old_path') String? oldPath,
    @JsonKey(name: 'new_path') String? newPath,
    @JsonKey(name: 'position_type') String? positionType,
    @JsonKey(name: 'old_line') int? oldLine,
    @JsonKey(name: 'new_line') int? newLine,
    @JsonKey(name: 'line_range') DiffNoteLineRange? lineRange,
    int? width,
    int? height,
    double? x,
    double? y,
  });

  @override
  $DiffNoteLineRangeCopyWith<$Res>? get lineRange;
}

/// @nodoc
class __$DiffNotePositionCopyWithImpl<$Res>
    implements _$DiffNotePositionCopyWith<$Res> {
  __$DiffNotePositionCopyWithImpl(this._self, this._then);

  final _DiffNotePosition _self;
  final $Res Function(_DiffNotePosition) _then;

  /// Create a copy of DiffNotePosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? baseSha = freezed,
    Object? startSha = freezed,
    Object? headSha = freezed,
    Object? oldPath = freezed,
    Object? newPath = freezed,
    Object? positionType = freezed,
    Object? oldLine = freezed,
    Object? newLine = freezed,
    Object? lineRange = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? x = freezed,
    Object? y = freezed,
  }) {
    return _then(
      _DiffNotePosition(
        baseSha: freezed == baseSha
            ? _self.baseSha
            : baseSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        startSha: freezed == startSha
            ? _self.startSha
            : startSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        headSha: freezed == headSha
            ? _self.headSha
            : headSha // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldPath: freezed == oldPath
            ? _self.oldPath
            : oldPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        newPath: freezed == newPath
            ? _self.newPath
            : newPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        positionType: freezed == positionType
            ? _self.positionType
            : positionType // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldLine: freezed == oldLine
            ? _self.oldLine
            : oldLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        newLine: freezed == newLine
            ? _self.newLine
            : newLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        lineRange: freezed == lineRange
            ? _self.lineRange
            : lineRange // ignore: cast_nullable_to_non_nullable
                  as DiffNoteLineRange?,
        width: freezed == width
            ? _self.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _self.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        x: freezed == x
            ? _self.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double?,
        y: freezed == y
            ? _self.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }

  /// Create a copy of DiffNotePosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiffNoteLineRangeCopyWith<$Res>? get lineRange {
    if (_self.lineRange == null) {
      return null;
    }

    return $DiffNoteLineRangeCopyWith<$Res>(_self.lineRange!, (value) {
      return _then(_self.copyWith(lineRange: value));
    });
  }
}

/// @nodoc
mixin _$DiffNoteLineRange {
  DiffNoteRangeEndpoint? get start;
  DiffNoteRangeEndpoint? get end;

  /// Create a copy of DiffNoteLineRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DiffNoteLineRangeCopyWith<DiffNoteLineRange> get copyWith =>
      _$DiffNoteLineRangeCopyWithImpl<DiffNoteLineRange>(
        this as DiffNoteLineRange,
        _$identity,
      );

  /// Serializes this DiffNoteLineRange to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DiffNoteLineRange &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, start, end);

  @override
  String toString() {
    return 'DiffNoteLineRange(start: $start, end: $end)';
  }
}

/// @nodoc
abstract mixin class $DiffNoteLineRangeCopyWith<$Res> {
  factory $DiffNoteLineRangeCopyWith(
    DiffNoteLineRange value,
    $Res Function(DiffNoteLineRange) _then,
  ) = _$DiffNoteLineRangeCopyWithImpl;
  @useResult
  $Res call({DiffNoteRangeEndpoint? start, DiffNoteRangeEndpoint? end});

  $DiffNoteRangeEndpointCopyWith<$Res>? get start;
  $DiffNoteRangeEndpointCopyWith<$Res>? get end;
}

/// @nodoc
class _$DiffNoteLineRangeCopyWithImpl<$Res>
    implements $DiffNoteLineRangeCopyWith<$Res> {
  _$DiffNoteLineRangeCopyWithImpl(this._self, this._then);

  final DiffNoteLineRange _self;
  final $Res Function(DiffNoteLineRange) _then;

  /// Create a copy of DiffNoteLineRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? start = freezed, Object? end = freezed}) {
    return _then(
      _self.copyWith(
        start: freezed == start
            ? _self.start
            : start // ignore: cast_nullable_to_non_nullable
                  as DiffNoteRangeEndpoint?,
        end: freezed == end
            ? _self.end
            : end // ignore: cast_nullable_to_non_nullable
                  as DiffNoteRangeEndpoint?,
      ),
    );
  }

  /// Create a copy of DiffNoteLineRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiffNoteRangeEndpointCopyWith<$Res>? get start {
    if (_self.start == null) {
      return null;
    }

    return $DiffNoteRangeEndpointCopyWith<$Res>(_self.start!, (value) {
      return _then(_self.copyWith(start: value));
    });
  }

  /// Create a copy of DiffNoteLineRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiffNoteRangeEndpointCopyWith<$Res>? get end {
    if (_self.end == null) {
      return null;
    }

    return $DiffNoteRangeEndpointCopyWith<$Res>(_self.end!, (value) {
      return _then(_self.copyWith(end: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DiffNoteLineRange].
extension DiffNoteLineRangePatterns on DiffNoteLineRange {
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
    TResult Function(_DiffNoteLineRange value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DiffNoteLineRange() when $default != null:
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
    TResult Function(_DiffNoteLineRange value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNoteLineRange():
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
    TResult? Function(_DiffNoteLineRange value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNoteLineRange() when $default != null:
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
    TResult Function(DiffNoteRangeEndpoint? start, DiffNoteRangeEndpoint? end)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DiffNoteLineRange() when $default != null:
        return $default(_that.start, _that.end);
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
    TResult Function(DiffNoteRangeEndpoint? start, DiffNoteRangeEndpoint? end)
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNoteLineRange():
        return $default(_that.start, _that.end);
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
    TResult? Function(DiffNoteRangeEndpoint? start, DiffNoteRangeEndpoint? end)?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNoteLineRange() when $default != null:
        return $default(_that.start, _that.end);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DiffNoteLineRange implements DiffNoteLineRange {
  const _DiffNoteLineRange({this.start, this.end});
  factory _DiffNoteLineRange.fromJson(Map<String, dynamic> json) =>
      _$DiffNoteLineRangeFromJson(json);

  @override
  final DiffNoteRangeEndpoint? start;
  @override
  final DiffNoteRangeEndpoint? end;

  /// Create a copy of DiffNoteLineRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DiffNoteLineRangeCopyWith<_DiffNoteLineRange> get copyWith =>
      __$DiffNoteLineRangeCopyWithImpl<_DiffNoteLineRange>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DiffNoteLineRangeToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DiffNoteLineRange &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, start, end);

  @override
  String toString() {
    return 'DiffNoteLineRange(start: $start, end: $end)';
  }
}

/// @nodoc
abstract mixin class _$DiffNoteLineRangeCopyWith<$Res>
    implements $DiffNoteLineRangeCopyWith<$Res> {
  factory _$DiffNoteLineRangeCopyWith(
    _DiffNoteLineRange value,
    $Res Function(_DiffNoteLineRange) _then,
  ) = __$DiffNoteLineRangeCopyWithImpl;
  @override
  @useResult
  $Res call({DiffNoteRangeEndpoint? start, DiffNoteRangeEndpoint? end});

  @override
  $DiffNoteRangeEndpointCopyWith<$Res>? get start;
  @override
  $DiffNoteRangeEndpointCopyWith<$Res>? get end;
}

/// @nodoc
class __$DiffNoteLineRangeCopyWithImpl<$Res>
    implements _$DiffNoteLineRangeCopyWith<$Res> {
  __$DiffNoteLineRangeCopyWithImpl(this._self, this._then);

  final _DiffNoteLineRange _self;
  final $Res Function(_DiffNoteLineRange) _then;

  /// Create a copy of DiffNoteLineRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? start = freezed, Object? end = freezed}) {
    return _then(
      _DiffNoteLineRange(
        start: freezed == start
            ? _self.start
            : start // ignore: cast_nullable_to_non_nullable
                  as DiffNoteRangeEndpoint?,
        end: freezed == end
            ? _self.end
            : end // ignore: cast_nullable_to_non_nullable
                  as DiffNoteRangeEndpoint?,
      ),
    );
  }

  /// Create a copy of DiffNoteLineRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiffNoteRangeEndpointCopyWith<$Res>? get start {
    if (_self.start == null) {
      return null;
    }

    return $DiffNoteRangeEndpointCopyWith<$Res>(_self.start!, (value) {
      return _then(_self.copyWith(start: value));
    });
  }

  /// Create a copy of DiffNoteLineRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiffNoteRangeEndpointCopyWith<$Res>? get end {
    if (_self.end == null) {
      return null;
    }

    return $DiffNoteRangeEndpointCopyWith<$Res>(_self.end!, (value) {
      return _then(_self.copyWith(end: value));
    });
  }
}

/// @nodoc
mixin _$DiffNoteRangeEndpoint {
  @JsonKey(name: 'line_code')
  String? get lineCode;
  String? get type;
  @JsonKey(name: 'old_line')
  int? get oldLine;
  @JsonKey(name: 'new_line')
  int? get newLine;

  /// Create a copy of DiffNoteRangeEndpoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DiffNoteRangeEndpointCopyWith<DiffNoteRangeEndpoint> get copyWith =>
      _$DiffNoteRangeEndpointCopyWithImpl<DiffNoteRangeEndpoint>(
        this as DiffNoteRangeEndpoint,
        _$identity,
      );

  /// Serializes this DiffNoteRangeEndpoint to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DiffNoteRangeEndpoint &&
            (identical(other.lineCode, lineCode) ||
                other.lineCode == lineCode) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.oldLine, oldLine) || other.oldLine == oldLine) &&
            (identical(other.newLine, newLine) || other.newLine == newLine));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, lineCode, type, oldLine, newLine);

  @override
  String toString() {
    return 'DiffNoteRangeEndpoint(lineCode: $lineCode, type: $type, oldLine: $oldLine, newLine: $newLine)';
  }
}

/// @nodoc
abstract mixin class $DiffNoteRangeEndpointCopyWith<$Res> {
  factory $DiffNoteRangeEndpointCopyWith(
    DiffNoteRangeEndpoint value,
    $Res Function(DiffNoteRangeEndpoint) _then,
  ) = _$DiffNoteRangeEndpointCopyWithImpl;
  @useResult
  $Res call({
    @JsonKey(name: 'line_code') String? lineCode,
    String? type,
    @JsonKey(name: 'old_line') int? oldLine,
    @JsonKey(name: 'new_line') int? newLine,
  });
}

/// @nodoc
class _$DiffNoteRangeEndpointCopyWithImpl<$Res>
    implements $DiffNoteRangeEndpointCopyWith<$Res> {
  _$DiffNoteRangeEndpointCopyWithImpl(this._self, this._then);

  final DiffNoteRangeEndpoint _self;
  final $Res Function(DiffNoteRangeEndpoint) _then;

  /// Create a copy of DiffNoteRangeEndpoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lineCode = freezed,
    Object? type = freezed,
    Object? oldLine = freezed,
    Object? newLine = freezed,
  }) {
    return _then(
      _self.copyWith(
        lineCode: freezed == lineCode
            ? _self.lineCode
            : lineCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _self.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldLine: freezed == oldLine
            ? _self.oldLine
            : oldLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        newLine: freezed == newLine
            ? _self.newLine
            : newLine // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [DiffNoteRangeEndpoint].
extension DiffNoteRangeEndpointPatterns on DiffNoteRangeEndpoint {
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
    TResult Function(_DiffNoteRangeEndpoint value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DiffNoteRangeEndpoint() when $default != null:
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
    TResult Function(_DiffNoteRangeEndpoint value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNoteRangeEndpoint():
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
    TResult? Function(_DiffNoteRangeEndpoint value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNoteRangeEndpoint() when $default != null:
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
      @JsonKey(name: 'line_code') String? lineCode,
      String? type,
      @JsonKey(name: 'old_line') int? oldLine,
      @JsonKey(name: 'new_line') int? newLine,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DiffNoteRangeEndpoint() when $default != null:
        return $default(
          _that.lineCode,
          _that.type,
          _that.oldLine,
          _that.newLine,
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
      @JsonKey(name: 'line_code') String? lineCode,
      String? type,
      @JsonKey(name: 'old_line') int? oldLine,
      @JsonKey(name: 'new_line') int? newLine,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNoteRangeEndpoint():
        return $default(
          _that.lineCode,
          _that.type,
          _that.oldLine,
          _that.newLine,
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
      @JsonKey(name: 'line_code') String? lineCode,
      String? type,
      @JsonKey(name: 'old_line') int? oldLine,
      @JsonKey(name: 'new_line') int? newLine,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DiffNoteRangeEndpoint() when $default != null:
        return $default(
          _that.lineCode,
          _that.type,
          _that.oldLine,
          _that.newLine,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DiffNoteRangeEndpoint implements DiffNoteRangeEndpoint {
  const _DiffNoteRangeEndpoint({
    @JsonKey(name: 'line_code') this.lineCode,
    this.type,
    @JsonKey(name: 'old_line') this.oldLine,
    @JsonKey(name: 'new_line') this.newLine,
  });
  factory _DiffNoteRangeEndpoint.fromJson(Map<String, dynamic> json) =>
      _$DiffNoteRangeEndpointFromJson(json);

  @override
  @JsonKey(name: 'line_code')
  final String? lineCode;
  @override
  final String? type;
  @override
  @JsonKey(name: 'old_line')
  final int? oldLine;
  @override
  @JsonKey(name: 'new_line')
  final int? newLine;

  /// Create a copy of DiffNoteRangeEndpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DiffNoteRangeEndpointCopyWith<_DiffNoteRangeEndpoint> get copyWith =>
      __$DiffNoteRangeEndpointCopyWithImpl<_DiffNoteRangeEndpoint>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$DiffNoteRangeEndpointToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DiffNoteRangeEndpoint &&
            (identical(other.lineCode, lineCode) ||
                other.lineCode == lineCode) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.oldLine, oldLine) || other.oldLine == oldLine) &&
            (identical(other.newLine, newLine) || other.newLine == newLine));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, lineCode, type, oldLine, newLine);

  @override
  String toString() {
    return 'DiffNoteRangeEndpoint(lineCode: $lineCode, type: $type, oldLine: $oldLine, newLine: $newLine)';
  }
}

/// @nodoc
abstract mixin class _$DiffNoteRangeEndpointCopyWith<$Res>
    implements $DiffNoteRangeEndpointCopyWith<$Res> {
  factory _$DiffNoteRangeEndpointCopyWith(
    _DiffNoteRangeEndpoint value,
    $Res Function(_DiffNoteRangeEndpoint) _then,
  ) = __$DiffNoteRangeEndpointCopyWithImpl;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'line_code') String? lineCode,
    String? type,
    @JsonKey(name: 'old_line') int? oldLine,
    @JsonKey(name: 'new_line') int? newLine,
  });
}

/// @nodoc
class __$DiffNoteRangeEndpointCopyWithImpl<$Res>
    implements _$DiffNoteRangeEndpointCopyWith<$Res> {
  __$DiffNoteRangeEndpointCopyWithImpl(this._self, this._then);

  final _DiffNoteRangeEndpoint _self;
  final $Res Function(_DiffNoteRangeEndpoint) _then;

  /// Create a copy of DiffNoteRangeEndpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lineCode = freezed,
    Object? type = freezed,
    Object? oldLine = freezed,
    Object? newLine = freezed,
  }) {
    return _then(
      _DiffNoteRangeEndpoint(
        lineCode: freezed == lineCode
            ? _self.lineCode
            : lineCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _self.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldLine: freezed == oldLine
            ? _self.oldLine
            : oldLine // ignore: cast_nullable_to_non_nullable
                  as int?,
        newLine: freezed == newLine
            ? _self.newLine
            : newLine // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}
