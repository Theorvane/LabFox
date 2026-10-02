// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_tag_protection_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContainerTagProtectionRule {

 int get id;@JsonKey(name: 'project_id') int get projectId;@JsonKey(name: 'tag_name_pattern') String get tagNamePattern;@JsonKey(name: 'minimum_access_level_for_push') String? get minimumAccessLevelForPush;@JsonKey(name: 'minimum_access_level_for_delete') String? get minimumAccessLevelForDelete;
/// Create a copy of ContainerTagProtectionRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerTagProtectionRuleCopyWith<ContainerTagProtectionRule> get copyWith => _$ContainerTagProtectionRuleCopyWithImpl<ContainerTagProtectionRule>(this as ContainerTagProtectionRule, _$identity);

  /// Serializes this ContainerTagProtectionRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerTagProtectionRule&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.tagNamePattern, tagNamePattern) || other.tagNamePattern == tagNamePattern)&&(identical(other.minimumAccessLevelForPush, minimumAccessLevelForPush) || other.minimumAccessLevelForPush == minimumAccessLevelForPush)&&(identical(other.minimumAccessLevelForDelete, minimumAccessLevelForDelete) || other.minimumAccessLevelForDelete == minimumAccessLevelForDelete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,tagNamePattern,minimumAccessLevelForPush,minimumAccessLevelForDelete);

@override
String toString() {
  return 'ContainerTagProtectionRule(id: $id, projectId: $projectId, tagNamePattern: $tagNamePattern, minimumAccessLevelForPush: $minimumAccessLevelForPush, minimumAccessLevelForDelete: $minimumAccessLevelForDelete)';
}


}

/// @nodoc
abstract mixin class $ContainerTagProtectionRuleCopyWith<$Res>  {
  factory $ContainerTagProtectionRuleCopyWith(ContainerTagProtectionRule value, $Res Function(ContainerTagProtectionRule) _then) = _$ContainerTagProtectionRuleCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'project_id') int projectId,@JsonKey(name: 'tag_name_pattern') String tagNamePattern,@JsonKey(name: 'minimum_access_level_for_push') String? minimumAccessLevelForPush,@JsonKey(name: 'minimum_access_level_for_delete') String? minimumAccessLevelForDelete
});




}
/// @nodoc
class _$ContainerTagProtectionRuleCopyWithImpl<$Res>
    implements $ContainerTagProtectionRuleCopyWith<$Res> {
  _$ContainerTagProtectionRuleCopyWithImpl(this._self, this._then);

  final ContainerTagProtectionRule _self;
  final $Res Function(ContainerTagProtectionRule) _then;

/// Create a copy of ContainerTagProtectionRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? tagNamePattern = null,Object? minimumAccessLevelForPush = freezed,Object? minimumAccessLevelForDelete = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,tagNamePattern: null == tagNamePattern ? _self.tagNamePattern : tagNamePattern // ignore: cast_nullable_to_non_nullable
as String,minimumAccessLevelForPush: freezed == minimumAccessLevelForPush ? _self.minimumAccessLevelForPush : minimumAccessLevelForPush // ignore: cast_nullable_to_non_nullable
as String?,minimumAccessLevelForDelete: freezed == minimumAccessLevelForDelete ? _self.minimumAccessLevelForDelete : minimumAccessLevelForDelete // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContainerTagProtectionRule].
extension ContainerTagProtectionRulePatterns on ContainerTagProtectionRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContainerTagProtectionRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContainerTagProtectionRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContainerTagProtectionRule value)  $default,){
final _that = this;
switch (_that) {
case _ContainerTagProtectionRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContainerTagProtectionRule value)?  $default,){
final _that = this;
switch (_that) {
case _ContainerTagProtectionRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'project_id')  int projectId, @JsonKey(name: 'tag_name_pattern')  String tagNamePattern, @JsonKey(name: 'minimum_access_level_for_push')  String? minimumAccessLevelForPush, @JsonKey(name: 'minimum_access_level_for_delete')  String? minimumAccessLevelForDelete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContainerTagProtectionRule() when $default != null:
return $default(_that.id,_that.projectId,_that.tagNamePattern,_that.minimumAccessLevelForPush,_that.minimumAccessLevelForDelete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'project_id')  int projectId, @JsonKey(name: 'tag_name_pattern')  String tagNamePattern, @JsonKey(name: 'minimum_access_level_for_push')  String? minimumAccessLevelForPush, @JsonKey(name: 'minimum_access_level_for_delete')  String? minimumAccessLevelForDelete)  $default,) {final _that = this;
switch (_that) {
case _ContainerTagProtectionRule():
return $default(_that.id,_that.projectId,_that.tagNamePattern,_that.minimumAccessLevelForPush,_that.minimumAccessLevelForDelete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'project_id')  int projectId, @JsonKey(name: 'tag_name_pattern')  String tagNamePattern, @JsonKey(name: 'minimum_access_level_for_push')  String? minimumAccessLevelForPush, @JsonKey(name: 'minimum_access_level_for_delete')  String? minimumAccessLevelForDelete)?  $default,) {final _that = this;
switch (_that) {
case _ContainerTagProtectionRule() when $default != null:
return $default(_that.id,_that.projectId,_that.tagNamePattern,_that.minimumAccessLevelForPush,_that.minimumAccessLevelForDelete);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContainerTagProtectionRule implements ContainerTagProtectionRule {
  const _ContainerTagProtectionRule({required this.id, @JsonKey(name: 'project_id') required this.projectId, @JsonKey(name: 'tag_name_pattern') required this.tagNamePattern, @JsonKey(name: 'minimum_access_level_for_push') this.minimumAccessLevelForPush, @JsonKey(name: 'minimum_access_level_for_delete') this.minimumAccessLevelForDelete});
  factory _ContainerTagProtectionRule.fromJson(Map<String, dynamic> json) => _$ContainerTagProtectionRuleFromJson(json);

@override final  int id;
@override@JsonKey(name: 'project_id') final  int projectId;
@override@JsonKey(name: 'tag_name_pattern') final  String tagNamePattern;
@override@JsonKey(name: 'minimum_access_level_for_push') final  String? minimumAccessLevelForPush;
@override@JsonKey(name: 'minimum_access_level_for_delete') final  String? minimumAccessLevelForDelete;

/// Create a copy of ContainerTagProtectionRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerTagProtectionRuleCopyWith<_ContainerTagProtectionRule> get copyWith => __$ContainerTagProtectionRuleCopyWithImpl<_ContainerTagProtectionRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerTagProtectionRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerTagProtectionRule&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.tagNamePattern, tagNamePattern) || other.tagNamePattern == tagNamePattern)&&(identical(other.minimumAccessLevelForPush, minimumAccessLevelForPush) || other.minimumAccessLevelForPush == minimumAccessLevelForPush)&&(identical(other.minimumAccessLevelForDelete, minimumAccessLevelForDelete) || other.minimumAccessLevelForDelete == minimumAccessLevelForDelete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,tagNamePattern,minimumAccessLevelForPush,minimumAccessLevelForDelete);

@override
String toString() {
  return 'ContainerTagProtectionRule(id: $id, projectId: $projectId, tagNamePattern: $tagNamePattern, minimumAccessLevelForPush: $minimumAccessLevelForPush, minimumAccessLevelForDelete: $minimumAccessLevelForDelete)';
}


}

/// @nodoc
abstract mixin class _$ContainerTagProtectionRuleCopyWith<$Res> implements $ContainerTagProtectionRuleCopyWith<$Res> {
  factory _$ContainerTagProtectionRuleCopyWith(_ContainerTagProtectionRule value, $Res Function(_ContainerTagProtectionRule) _then) = __$ContainerTagProtectionRuleCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'project_id') int projectId,@JsonKey(name: 'tag_name_pattern') String tagNamePattern,@JsonKey(name: 'minimum_access_level_for_push') String? minimumAccessLevelForPush,@JsonKey(name: 'minimum_access_level_for_delete') String? minimumAccessLevelForDelete
});




}
/// @nodoc
class __$ContainerTagProtectionRuleCopyWithImpl<$Res>
    implements _$ContainerTagProtectionRuleCopyWith<$Res> {
  __$ContainerTagProtectionRuleCopyWithImpl(this._self, this._then);

  final _ContainerTagProtectionRule _self;
  final $Res Function(_ContainerTagProtectionRule) _then;

/// Create a copy of ContainerTagProtectionRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? tagNamePattern = null,Object? minimumAccessLevelForPush = freezed,Object? minimumAccessLevelForDelete = freezed,}) {
  return _then(_ContainerTagProtectionRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,tagNamePattern: null == tagNamePattern ? _self.tagNamePattern : tagNamePattern // ignore: cast_nullable_to_non_nullable
as String,minimumAccessLevelForPush: freezed == minimumAccessLevelForPush ? _self.minimumAccessLevelForPush : minimumAccessLevelForPush // ignore: cast_nullable_to_non_nullable
as String?,minimumAccessLevelForDelete: freezed == minimumAccessLevelForDelete ? _self.minimumAccessLevelForDelete : minimumAccessLevelForDelete // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
