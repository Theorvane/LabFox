// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_cleanup_policy_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContainerCleanupPolicySnapshot {

 bool get reported; ContainerCleanupPolicy? get policy;
/// Create a copy of ContainerCleanupPolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerCleanupPolicySnapshotCopyWith<ContainerCleanupPolicySnapshot> get copyWith => _$ContainerCleanupPolicySnapshotCopyWithImpl<ContainerCleanupPolicySnapshot>(this as ContainerCleanupPolicySnapshot, _$identity);

  /// Serializes this ContainerCleanupPolicySnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerCleanupPolicySnapshot&&(identical(other.reported, reported) || other.reported == reported)&&(identical(other.policy, policy) || other.policy == policy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reported,policy);

@override
String toString() {
  return 'ContainerCleanupPolicySnapshot(reported: $reported, policy: $policy)';
}


}

/// @nodoc
abstract mixin class $ContainerCleanupPolicySnapshotCopyWith<$Res>  {
  factory $ContainerCleanupPolicySnapshotCopyWith(ContainerCleanupPolicySnapshot value, $Res Function(ContainerCleanupPolicySnapshot) _then) = _$ContainerCleanupPolicySnapshotCopyWithImpl;
@useResult
$Res call({
 bool reported, ContainerCleanupPolicy? policy
});


$ContainerCleanupPolicyCopyWith<$Res>? get policy;

}
/// @nodoc
class _$ContainerCleanupPolicySnapshotCopyWithImpl<$Res>
    implements $ContainerCleanupPolicySnapshotCopyWith<$Res> {
  _$ContainerCleanupPolicySnapshotCopyWithImpl(this._self, this._then);

  final ContainerCleanupPolicySnapshot _self;
  final $Res Function(ContainerCleanupPolicySnapshot) _then;

/// Create a copy of ContainerCleanupPolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reported = null,Object? policy = freezed,}) {
  return _then(_self.copyWith(
reported: null == reported ? _self.reported : reported // ignore: cast_nullable_to_non_nullable
as bool,policy: freezed == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as ContainerCleanupPolicy?,
  ));
}
/// Create a copy of ContainerCleanupPolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerCleanupPolicyCopyWith<$Res>? get policy {
    if (_self.policy == null) {
    return null;
  }

  return $ContainerCleanupPolicyCopyWith<$Res>(_self.policy!, (value) {
    return _then(_self.copyWith(policy: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContainerCleanupPolicySnapshot].
extension ContainerCleanupPolicySnapshotPatterns on ContainerCleanupPolicySnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContainerCleanupPolicySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContainerCleanupPolicySnapshot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContainerCleanupPolicySnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ContainerCleanupPolicySnapshot():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContainerCleanupPolicySnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ContainerCleanupPolicySnapshot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool reported,  ContainerCleanupPolicy? policy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContainerCleanupPolicySnapshot() when $default != null:
return $default(_that.reported,_that.policy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool reported,  ContainerCleanupPolicy? policy)  $default,) {final _that = this;
switch (_that) {
case _ContainerCleanupPolicySnapshot():
return $default(_that.reported,_that.policy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool reported,  ContainerCleanupPolicy? policy)?  $default,) {final _that = this;
switch (_that) {
case _ContainerCleanupPolicySnapshot() when $default != null:
return $default(_that.reported,_that.policy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContainerCleanupPolicySnapshot implements ContainerCleanupPolicySnapshot {
  const _ContainerCleanupPolicySnapshot({required this.reported, this.policy});
  factory _ContainerCleanupPolicySnapshot.fromJson(Map<String, dynamic> json) => _$ContainerCleanupPolicySnapshotFromJson(json);

@override final  bool reported;
@override final  ContainerCleanupPolicy? policy;

/// Create a copy of ContainerCleanupPolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerCleanupPolicySnapshotCopyWith<_ContainerCleanupPolicySnapshot> get copyWith => __$ContainerCleanupPolicySnapshotCopyWithImpl<_ContainerCleanupPolicySnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerCleanupPolicySnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerCleanupPolicySnapshot&&(identical(other.reported, reported) || other.reported == reported)&&(identical(other.policy, policy) || other.policy == policy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reported,policy);

@override
String toString() {
  return 'ContainerCleanupPolicySnapshot(reported: $reported, policy: $policy)';
}


}

/// @nodoc
abstract mixin class _$ContainerCleanupPolicySnapshotCopyWith<$Res> implements $ContainerCleanupPolicySnapshotCopyWith<$Res> {
  factory _$ContainerCleanupPolicySnapshotCopyWith(_ContainerCleanupPolicySnapshot value, $Res Function(_ContainerCleanupPolicySnapshot) _then) = __$ContainerCleanupPolicySnapshotCopyWithImpl;
@override @useResult
$Res call({
 bool reported, ContainerCleanupPolicy? policy
});


@override $ContainerCleanupPolicyCopyWith<$Res>? get policy;

}
/// @nodoc
class __$ContainerCleanupPolicySnapshotCopyWithImpl<$Res>
    implements _$ContainerCleanupPolicySnapshotCopyWith<$Res> {
  __$ContainerCleanupPolicySnapshotCopyWithImpl(this._self, this._then);

  final _ContainerCleanupPolicySnapshot _self;
  final $Res Function(_ContainerCleanupPolicySnapshot) _then;

/// Create a copy of ContainerCleanupPolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reported = null,Object? policy = freezed,}) {
  return _then(_ContainerCleanupPolicySnapshot(
reported: null == reported ? _self.reported : reported // ignore: cast_nullable_to_non_nullable
as bool,policy: freezed == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as ContainerCleanupPolicy?,
  ));
}

/// Create a copy of ContainerCleanupPolicySnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerCleanupPolicyCopyWith<$Res>? get policy {
    if (_self.policy == null) {
    return null;
  }

  return $ContainerCleanupPolicyCopyWith<$Res>(_self.policy!, (value) {
    return _then(_self.copyWith(policy: value));
  });
}
}

// dart format on
