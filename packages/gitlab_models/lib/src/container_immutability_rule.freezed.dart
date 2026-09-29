// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_immutability_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContainerTagImmutabilityRule {

 String get id; String get tagNamePattern; bool get immutable;
/// Create a copy of ContainerTagImmutabilityRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerTagImmutabilityRuleCopyWith<ContainerTagImmutabilityRule> get copyWith => _$ContainerTagImmutabilityRuleCopyWithImpl<ContainerTagImmutabilityRule>(this as ContainerTagImmutabilityRule, _$identity);

  /// Serializes this ContainerTagImmutabilityRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerTagImmutabilityRule&&(identical(other.id, id) || other.id == id)&&(identical(other.tagNamePattern, tagNamePattern) || other.tagNamePattern == tagNamePattern)&&(identical(other.immutable, immutable) || other.immutable == immutable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tagNamePattern,immutable);

@override
String toString() {
  return 'ContainerTagImmutabilityRule(id: $id, tagNamePattern: $tagNamePattern, immutable: $immutable)';
}


}

/// @nodoc
abstract mixin class $ContainerTagImmutabilityRuleCopyWith<$Res>  {
  factory $ContainerTagImmutabilityRuleCopyWith(ContainerTagImmutabilityRule value, $Res Function(ContainerTagImmutabilityRule) _then) = _$ContainerTagImmutabilityRuleCopyWithImpl;
@useResult
$Res call({
 String id, String tagNamePattern, bool immutable
});




}
/// @nodoc
class _$ContainerTagImmutabilityRuleCopyWithImpl<$Res>
    implements $ContainerTagImmutabilityRuleCopyWith<$Res> {
  _$ContainerTagImmutabilityRuleCopyWithImpl(this._self, this._then);

  final ContainerTagImmutabilityRule _self;
  final $Res Function(ContainerTagImmutabilityRule) _then;

/// Create a copy of ContainerTagImmutabilityRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tagNamePattern = null,Object? immutable = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tagNamePattern: null == tagNamePattern ? _self.tagNamePattern : tagNamePattern // ignore: cast_nullable_to_non_nullable
as String,immutable: null == immutable ? _self.immutable : immutable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ContainerTagImmutabilityRule].
extension ContainerTagImmutabilityRulePatterns on ContainerTagImmutabilityRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContainerTagImmutabilityRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContainerTagImmutabilityRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContainerTagImmutabilityRule value)  $default,){
final _that = this;
switch (_that) {
case _ContainerTagImmutabilityRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContainerTagImmutabilityRule value)?  $default,){
final _that = this;
switch (_that) {
case _ContainerTagImmutabilityRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tagNamePattern,  bool immutable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContainerTagImmutabilityRule() when $default != null:
return $default(_that.id,_that.tagNamePattern,_that.immutable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tagNamePattern,  bool immutable)  $default,) {final _that = this;
switch (_that) {
case _ContainerTagImmutabilityRule():
return $default(_that.id,_that.tagNamePattern,_that.immutable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tagNamePattern,  bool immutable)?  $default,) {final _that = this;
switch (_that) {
case _ContainerTagImmutabilityRule() when $default != null:
return $default(_that.id,_that.tagNamePattern,_that.immutable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContainerTagImmutabilityRule implements ContainerTagImmutabilityRule {
  const _ContainerTagImmutabilityRule({required this.id, required this.tagNamePattern, required this.immutable});
  factory _ContainerTagImmutabilityRule.fromJson(Map<String, dynamic> json) => _$ContainerTagImmutabilityRuleFromJson(json);

@override final  String id;
@override final  String tagNamePattern;
@override final  bool immutable;

/// Create a copy of ContainerTagImmutabilityRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerTagImmutabilityRuleCopyWith<_ContainerTagImmutabilityRule> get copyWith => __$ContainerTagImmutabilityRuleCopyWithImpl<_ContainerTagImmutabilityRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerTagImmutabilityRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerTagImmutabilityRule&&(identical(other.id, id) || other.id == id)&&(identical(other.tagNamePattern, tagNamePattern) || other.tagNamePattern == tagNamePattern)&&(identical(other.immutable, immutable) || other.immutable == immutable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tagNamePattern,immutable);

@override
String toString() {
  return 'ContainerTagImmutabilityRule(id: $id, tagNamePattern: $tagNamePattern, immutable: $immutable)';
}


}

/// @nodoc
abstract mixin class _$ContainerTagImmutabilityRuleCopyWith<$Res> implements $ContainerTagImmutabilityRuleCopyWith<$Res> {
  factory _$ContainerTagImmutabilityRuleCopyWith(_ContainerTagImmutabilityRule value, $Res Function(_ContainerTagImmutabilityRule) _then) = __$ContainerTagImmutabilityRuleCopyWithImpl;
@override @useResult
$Res call({
 String id, String tagNamePattern, bool immutable
});




}
/// @nodoc
class __$ContainerTagImmutabilityRuleCopyWithImpl<$Res>
    implements _$ContainerTagImmutabilityRuleCopyWith<$Res> {
  __$ContainerTagImmutabilityRuleCopyWithImpl(this._self, this._then);

  final _ContainerTagImmutabilityRule _self;
  final $Res Function(_ContainerTagImmutabilityRule) _then;

/// Create a copy of ContainerTagImmutabilityRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tagNamePattern = null,Object? immutable = null,}) {
  return _then(_ContainerTagImmutabilityRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tagNamePattern: null == tagNamePattern ? _self.tagNamePattern : tagNamePattern // ignore: cast_nullable_to_non_nullable
as String,immutable: null == immutable ? _self.immutable : immutable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ContainerTagRulePageInfo {

 bool get hasNextPage; String? get endCursor;
/// Create a copy of ContainerTagRulePageInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerTagRulePageInfoCopyWith<ContainerTagRulePageInfo> get copyWith => _$ContainerTagRulePageInfoCopyWithImpl<ContainerTagRulePageInfo>(this as ContainerTagRulePageInfo, _$identity);

  /// Serializes this ContainerTagRulePageInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerTagRulePageInfo&&(identical(other.hasNextPage, hasNextPage) || other.hasNextPage == hasNextPage)&&(identical(other.endCursor, endCursor) || other.endCursor == endCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hasNextPage,endCursor);

@override
String toString() {
  return 'ContainerTagRulePageInfo(hasNextPage: $hasNextPage, endCursor: $endCursor)';
}


}

/// @nodoc
abstract mixin class $ContainerTagRulePageInfoCopyWith<$Res>  {
  factory $ContainerTagRulePageInfoCopyWith(ContainerTagRulePageInfo value, $Res Function(ContainerTagRulePageInfo) _then) = _$ContainerTagRulePageInfoCopyWithImpl;
@useResult
$Res call({
 bool hasNextPage, String? endCursor
});




}
/// @nodoc
class _$ContainerTagRulePageInfoCopyWithImpl<$Res>
    implements $ContainerTagRulePageInfoCopyWith<$Res> {
  _$ContainerTagRulePageInfoCopyWithImpl(this._self, this._then);

  final ContainerTagRulePageInfo _self;
  final $Res Function(ContainerTagRulePageInfo) _then;

/// Create a copy of ContainerTagRulePageInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasNextPage = null,Object? endCursor = freezed,}) {
  return _then(_self.copyWith(
hasNextPage: null == hasNextPage ? _self.hasNextPage : hasNextPage // ignore: cast_nullable_to_non_nullable
as bool,endCursor: freezed == endCursor ? _self.endCursor : endCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContainerTagRulePageInfo].
extension ContainerTagRulePageInfoPatterns on ContainerTagRulePageInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContainerTagRulePageInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContainerTagRulePageInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContainerTagRulePageInfo value)  $default,){
final _that = this;
switch (_that) {
case _ContainerTagRulePageInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContainerTagRulePageInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ContainerTagRulePageInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasNextPage,  String? endCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContainerTagRulePageInfo() when $default != null:
return $default(_that.hasNextPage,_that.endCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasNextPage,  String? endCursor)  $default,) {final _that = this;
switch (_that) {
case _ContainerTagRulePageInfo():
return $default(_that.hasNextPage,_that.endCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasNextPage,  String? endCursor)?  $default,) {final _that = this;
switch (_that) {
case _ContainerTagRulePageInfo() when $default != null:
return $default(_that.hasNextPage,_that.endCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContainerTagRulePageInfo implements ContainerTagRulePageInfo {
  const _ContainerTagRulePageInfo({required this.hasNextPage, this.endCursor});
  factory _ContainerTagRulePageInfo.fromJson(Map<String, dynamic> json) => _$ContainerTagRulePageInfoFromJson(json);

@override final  bool hasNextPage;
@override final  String? endCursor;

/// Create a copy of ContainerTagRulePageInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerTagRulePageInfoCopyWith<_ContainerTagRulePageInfo> get copyWith => __$ContainerTagRulePageInfoCopyWithImpl<_ContainerTagRulePageInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerTagRulePageInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerTagRulePageInfo&&(identical(other.hasNextPage, hasNextPage) || other.hasNextPage == hasNextPage)&&(identical(other.endCursor, endCursor) || other.endCursor == endCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hasNextPage,endCursor);

@override
String toString() {
  return 'ContainerTagRulePageInfo(hasNextPage: $hasNextPage, endCursor: $endCursor)';
}


}

/// @nodoc
abstract mixin class _$ContainerTagRulePageInfoCopyWith<$Res> implements $ContainerTagRulePageInfoCopyWith<$Res> {
  factory _$ContainerTagRulePageInfoCopyWith(_ContainerTagRulePageInfo value, $Res Function(_ContainerTagRulePageInfo) _then) = __$ContainerTagRulePageInfoCopyWithImpl;
@override @useResult
$Res call({
 bool hasNextPage, String? endCursor
});




}
/// @nodoc
class __$ContainerTagRulePageInfoCopyWithImpl<$Res>
    implements _$ContainerTagRulePageInfoCopyWith<$Res> {
  __$ContainerTagRulePageInfoCopyWithImpl(this._self, this._then);

  final _ContainerTagRulePageInfo _self;
  final $Res Function(_ContainerTagRulePageInfo) _then;

/// Create a copy of ContainerTagRulePageInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasNextPage = null,Object? endCursor = freezed,}) {
  return _then(_ContainerTagRulePageInfo(
hasNextPage: null == hasNextPage ? _self.hasNextPage : hasNextPage // ignore: cast_nullable_to_non_nullable
as bool,endCursor: freezed == endCursor ? _self.endCursor : endCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ContainerTagRuleConnection {

 List<ContainerTagImmutabilityRule> get nodes; ContainerTagRulePageInfo get pageInfo;
/// Create a copy of ContainerTagRuleConnection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerTagRuleConnectionCopyWith<ContainerTagRuleConnection> get copyWith => _$ContainerTagRuleConnectionCopyWithImpl<ContainerTagRuleConnection>(this as ContainerTagRuleConnection, _$identity);

  /// Serializes this ContainerTagRuleConnection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerTagRuleConnection&&const DeepCollectionEquality().equals(other.nodes, nodes)&&(identical(other.pageInfo, pageInfo) || other.pageInfo == pageInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(nodes),pageInfo);

@override
String toString() {
  return 'ContainerTagRuleConnection(nodes: $nodes, pageInfo: $pageInfo)';
}


}

/// @nodoc
abstract mixin class $ContainerTagRuleConnectionCopyWith<$Res>  {
  factory $ContainerTagRuleConnectionCopyWith(ContainerTagRuleConnection value, $Res Function(ContainerTagRuleConnection) _then) = _$ContainerTagRuleConnectionCopyWithImpl;
@useResult
$Res call({
 List<ContainerTagImmutabilityRule> nodes, ContainerTagRulePageInfo pageInfo
});


$ContainerTagRulePageInfoCopyWith<$Res> get pageInfo;

}
/// @nodoc
class _$ContainerTagRuleConnectionCopyWithImpl<$Res>
    implements $ContainerTagRuleConnectionCopyWith<$Res> {
  _$ContainerTagRuleConnectionCopyWithImpl(this._self, this._then);

  final ContainerTagRuleConnection _self;
  final $Res Function(ContainerTagRuleConnection) _then;

/// Create a copy of ContainerTagRuleConnection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nodes = null,Object? pageInfo = null,}) {
  return _then(_self.copyWith(
nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<ContainerTagImmutabilityRule>,pageInfo: null == pageInfo ? _self.pageInfo : pageInfo // ignore: cast_nullable_to_non_nullable
as ContainerTagRulePageInfo,
  ));
}
/// Create a copy of ContainerTagRuleConnection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerTagRulePageInfoCopyWith<$Res> get pageInfo {
  
  return $ContainerTagRulePageInfoCopyWith<$Res>(_self.pageInfo, (value) {
    return _then(_self.copyWith(pageInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContainerTagRuleConnection].
extension ContainerTagRuleConnectionPatterns on ContainerTagRuleConnection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContainerTagRuleConnection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContainerTagRuleConnection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContainerTagRuleConnection value)  $default,){
final _that = this;
switch (_that) {
case _ContainerTagRuleConnection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContainerTagRuleConnection value)?  $default,){
final _that = this;
switch (_that) {
case _ContainerTagRuleConnection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ContainerTagImmutabilityRule> nodes,  ContainerTagRulePageInfo pageInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContainerTagRuleConnection() when $default != null:
return $default(_that.nodes,_that.pageInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ContainerTagImmutabilityRule> nodes,  ContainerTagRulePageInfo pageInfo)  $default,) {final _that = this;
switch (_that) {
case _ContainerTagRuleConnection():
return $default(_that.nodes,_that.pageInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ContainerTagImmutabilityRule> nodes,  ContainerTagRulePageInfo pageInfo)?  $default,) {final _that = this;
switch (_that) {
case _ContainerTagRuleConnection() when $default != null:
return $default(_that.nodes,_that.pageInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContainerTagRuleConnection implements ContainerTagRuleConnection {
  const _ContainerTagRuleConnection({required final  List<ContainerTagImmutabilityRule> nodes, required this.pageInfo}): _nodes = nodes;
  factory _ContainerTagRuleConnection.fromJson(Map<String, dynamic> json) => _$ContainerTagRuleConnectionFromJson(json);

 final  List<ContainerTagImmutabilityRule> _nodes;
@override List<ContainerTagImmutabilityRule> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}

@override final  ContainerTagRulePageInfo pageInfo;

/// Create a copy of ContainerTagRuleConnection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerTagRuleConnectionCopyWith<_ContainerTagRuleConnection> get copyWith => __$ContainerTagRuleConnectionCopyWithImpl<_ContainerTagRuleConnection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerTagRuleConnectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerTagRuleConnection&&const DeepCollectionEquality().equals(other._nodes, _nodes)&&(identical(other.pageInfo, pageInfo) || other.pageInfo == pageInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_nodes),pageInfo);

@override
String toString() {
  return 'ContainerTagRuleConnection(nodes: $nodes, pageInfo: $pageInfo)';
}


}

/// @nodoc
abstract mixin class _$ContainerTagRuleConnectionCopyWith<$Res> implements $ContainerTagRuleConnectionCopyWith<$Res> {
  factory _$ContainerTagRuleConnectionCopyWith(_ContainerTagRuleConnection value, $Res Function(_ContainerTagRuleConnection) _then) = __$ContainerTagRuleConnectionCopyWithImpl;
@override @useResult
$Res call({
 List<ContainerTagImmutabilityRule> nodes, ContainerTagRulePageInfo pageInfo
});


@override $ContainerTagRulePageInfoCopyWith<$Res> get pageInfo;

}
/// @nodoc
class __$ContainerTagRuleConnectionCopyWithImpl<$Res>
    implements _$ContainerTagRuleConnectionCopyWith<$Res> {
  __$ContainerTagRuleConnectionCopyWithImpl(this._self, this._then);

  final _ContainerTagRuleConnection _self;
  final $Res Function(_ContainerTagRuleConnection) _then;

/// Create a copy of ContainerTagRuleConnection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nodes = null,Object? pageInfo = null,}) {
  return _then(_ContainerTagRuleConnection(
nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<ContainerTagImmutabilityRule>,pageInfo: null == pageInfo ? _self.pageInfo : pageInfo // ignore: cast_nullable_to_non_nullable
as ContainerTagRulePageInfo,
  ));
}

/// Create a copy of ContainerTagRuleConnection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerTagRulePageInfoCopyWith<$Res> get pageInfo {
  
  return $ContainerTagRulePageInfoCopyWith<$Res>(_self.pageInfo, (value) {
    return _then(_self.copyWith(pageInfo: value));
  });
}
}

// dart format on
