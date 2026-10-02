// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Project {

 int get id; String get name;@JsonKey(name: 'path_with_namespace') String get pathWithNamespace; String? get description;// Always shown as a number in the UI, so absent means zero, not unknown.
@JsonKey(name: 'star_count') int get starCount; String? get visibility;@JsonKey(name: 'default_branch') String? get defaultBranch;@JsonKey(name: 'container_registry_access_level') String? get containerRegistryAccessLevel;@JsonKey(name: 'container_expiration_policy') ContainerCleanupPolicy? get containerExpirationPolicy;@JsonKey(name: 'package_registry_access_level') String? get packageRegistryAccessLevel;// Null when GitLab omits the count on a reduced payload — unknown, not
// zero, so the UI hides it instead of showing a false 0.
@JsonKey(name: 'open_issues_count') int? get openIssuesCount;@JsonKey(name: 'forks_count') int? get forksCount;@JsonKey(name: 'wiki_access_level') String? get wikiAccessLevel;@JsonKey(name: 'wiki_enabled') bool? get wikiEnabled;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'web_url') String? get webUrl;@JsonKey(name: 'last_activity_at') DateTime? get lastActivityAt;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.pathWithNamespace, pathWithNamespace) || other.pathWithNamespace == pathWithNamespace)&&(identical(other.description, description) || other.description == description)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.containerRegistryAccessLevel, containerRegistryAccessLevel) || other.containerRegistryAccessLevel == containerRegistryAccessLevel)&&(identical(other.containerExpirationPolicy, containerExpirationPolicy) || other.containerExpirationPolicy == containerExpirationPolicy)&&(identical(other.packageRegistryAccessLevel, packageRegistryAccessLevel) || other.packageRegistryAccessLevel == packageRegistryAccessLevel)&&(identical(other.openIssuesCount, openIssuesCount) || other.openIssuesCount == openIssuesCount)&&(identical(other.forksCount, forksCount) || other.forksCount == forksCount)&&(identical(other.wikiAccessLevel, wikiAccessLevel) || other.wikiAccessLevel == wikiAccessLevel)&&(identical(other.wikiEnabled, wikiEnabled) || other.wikiEnabled == wikiEnabled)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,pathWithNamespace,description,starCount,visibility,defaultBranch,containerRegistryAccessLevel,containerExpirationPolicy,packageRegistryAccessLevel,openIssuesCount,forksCount,wikiAccessLevel,wikiEnabled,avatarUrl,webUrl,lastActivityAt);

@override
String toString() {
  return 'Project(id: $id, name: $name, pathWithNamespace: $pathWithNamespace, description: $description, starCount: $starCount, visibility: $visibility, defaultBranch: $defaultBranch, containerRegistryAccessLevel: $containerRegistryAccessLevel, containerExpirationPolicy: $containerExpirationPolicy, packageRegistryAccessLevel: $packageRegistryAccessLevel, openIssuesCount: $openIssuesCount, forksCount: $forksCount, wikiAccessLevel: $wikiAccessLevel, wikiEnabled: $wikiEnabled, avatarUrl: $avatarUrl, webUrl: $webUrl, lastActivityAt: $lastActivityAt)';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'path_with_namespace') String pathWithNamespace, String? description,@JsonKey(name: 'star_count') int starCount, String? visibility,@JsonKey(name: 'default_branch') String? defaultBranch,@JsonKey(name: 'container_registry_access_level') String? containerRegistryAccessLevel,@JsonKey(name: 'container_expiration_policy') ContainerCleanupPolicy? containerExpirationPolicy,@JsonKey(name: 'package_registry_access_level') String? packageRegistryAccessLevel,@JsonKey(name: 'open_issues_count') int? openIssuesCount,@JsonKey(name: 'forks_count') int? forksCount,@JsonKey(name: 'wiki_access_level') String? wikiAccessLevel,@JsonKey(name: 'wiki_enabled') bool? wikiEnabled,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'web_url') String? webUrl,@JsonKey(name: 'last_activity_at') DateTime? lastActivityAt
});


$ContainerCleanupPolicyCopyWith<$Res>? get containerExpirationPolicy;

}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? pathWithNamespace = null,Object? description = freezed,Object? starCount = null,Object? visibility = freezed,Object? defaultBranch = freezed,Object? containerRegistryAccessLevel = freezed,Object? containerExpirationPolicy = freezed,Object? packageRegistryAccessLevel = freezed,Object? openIssuesCount = freezed,Object? forksCount = freezed,Object? wikiAccessLevel = freezed,Object? wikiEnabled = freezed,Object? avatarUrl = freezed,Object? webUrl = freezed,Object? lastActivityAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pathWithNamespace: null == pathWithNamespace ? _self.pathWithNamespace : pathWithNamespace // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,defaultBranch: freezed == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String?,containerRegistryAccessLevel: freezed == containerRegistryAccessLevel ? _self.containerRegistryAccessLevel : containerRegistryAccessLevel // ignore: cast_nullable_to_non_nullable
as String?,containerExpirationPolicy: freezed == containerExpirationPolicy ? _self.containerExpirationPolicy : containerExpirationPolicy // ignore: cast_nullable_to_non_nullable
as ContainerCleanupPolicy?,packageRegistryAccessLevel: freezed == packageRegistryAccessLevel ? _self.packageRegistryAccessLevel : packageRegistryAccessLevel // ignore: cast_nullable_to_non_nullable
as String?,openIssuesCount: freezed == openIssuesCount ? _self.openIssuesCount : openIssuesCount // ignore: cast_nullable_to_non_nullable
as int?,forksCount: freezed == forksCount ? _self.forksCount : forksCount // ignore: cast_nullable_to_non_nullable
as int?,wikiAccessLevel: freezed == wikiAccessLevel ? _self.wikiAccessLevel : wikiAccessLevel // ignore: cast_nullable_to_non_nullable
as String?,wikiEnabled: freezed == wikiEnabled ? _self.wikiEnabled : wikiEnabled // ignore: cast_nullable_to_non_nullable
as bool?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerCleanupPolicyCopyWith<$Res>? get containerExpirationPolicy {
    if (_self.containerExpirationPolicy == null) {
    return null;
  }

  return $ContainerCleanupPolicyCopyWith<$Res>(_self.containerExpirationPolicy!, (value) {
    return _then(_self.copyWith(containerExpirationPolicy: value));
  });
}
}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'path_with_namespace')  String pathWithNamespace,  String? description, @JsonKey(name: 'star_count')  int starCount,  String? visibility, @JsonKey(name: 'default_branch')  String? defaultBranch, @JsonKey(name: 'container_registry_access_level')  String? containerRegistryAccessLevel, @JsonKey(name: 'container_expiration_policy')  ContainerCleanupPolicy? containerExpirationPolicy, @JsonKey(name: 'package_registry_access_level')  String? packageRegistryAccessLevel, @JsonKey(name: 'open_issues_count')  int? openIssuesCount, @JsonKey(name: 'forks_count')  int? forksCount, @JsonKey(name: 'wiki_access_level')  String? wikiAccessLevel, @JsonKey(name: 'wiki_enabled')  bool? wikiEnabled, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'last_activity_at')  DateTime? lastActivityAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.pathWithNamespace,_that.description,_that.starCount,_that.visibility,_that.defaultBranch,_that.containerRegistryAccessLevel,_that.containerExpirationPolicy,_that.packageRegistryAccessLevel,_that.openIssuesCount,_that.forksCount,_that.wikiAccessLevel,_that.wikiEnabled,_that.avatarUrl,_that.webUrl,_that.lastActivityAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'path_with_namespace')  String pathWithNamespace,  String? description, @JsonKey(name: 'star_count')  int starCount,  String? visibility, @JsonKey(name: 'default_branch')  String? defaultBranch, @JsonKey(name: 'container_registry_access_level')  String? containerRegistryAccessLevel, @JsonKey(name: 'container_expiration_policy')  ContainerCleanupPolicy? containerExpirationPolicy, @JsonKey(name: 'package_registry_access_level')  String? packageRegistryAccessLevel, @JsonKey(name: 'open_issues_count')  int? openIssuesCount, @JsonKey(name: 'forks_count')  int? forksCount, @JsonKey(name: 'wiki_access_level')  String? wikiAccessLevel, @JsonKey(name: 'wiki_enabled')  bool? wikiEnabled, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'last_activity_at')  DateTime? lastActivityAt)  $default,) {final _that = this;
switch (_that) {
case _Project():
return $default(_that.id,_that.name,_that.pathWithNamespace,_that.description,_that.starCount,_that.visibility,_that.defaultBranch,_that.containerRegistryAccessLevel,_that.containerExpirationPolicy,_that.packageRegistryAccessLevel,_that.openIssuesCount,_that.forksCount,_that.wikiAccessLevel,_that.wikiEnabled,_that.avatarUrl,_that.webUrl,_that.lastActivityAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'path_with_namespace')  String pathWithNamespace,  String? description, @JsonKey(name: 'star_count')  int starCount,  String? visibility, @JsonKey(name: 'default_branch')  String? defaultBranch, @JsonKey(name: 'container_registry_access_level')  String? containerRegistryAccessLevel, @JsonKey(name: 'container_expiration_policy')  ContainerCleanupPolicy? containerExpirationPolicy, @JsonKey(name: 'package_registry_access_level')  String? packageRegistryAccessLevel, @JsonKey(name: 'open_issues_count')  int? openIssuesCount, @JsonKey(name: 'forks_count')  int? forksCount, @JsonKey(name: 'wiki_access_level')  String? wikiAccessLevel, @JsonKey(name: 'wiki_enabled')  bool? wikiEnabled, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'last_activity_at')  DateTime? lastActivityAt)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.pathWithNamespace,_that.description,_that.starCount,_that.visibility,_that.defaultBranch,_that.containerRegistryAccessLevel,_that.containerExpirationPolicy,_that.packageRegistryAccessLevel,_that.openIssuesCount,_that.forksCount,_that.wikiAccessLevel,_that.wikiEnabled,_that.avatarUrl,_that.webUrl,_that.lastActivityAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Project extends Project {
  const _Project({required this.id, required this.name, @JsonKey(name: 'path_with_namespace') required this.pathWithNamespace, this.description, @JsonKey(name: 'star_count') this.starCount = 0, this.visibility, @JsonKey(name: 'default_branch') this.defaultBranch, @JsonKey(name: 'container_registry_access_level') this.containerRegistryAccessLevel, @JsonKey(name: 'container_expiration_policy') this.containerExpirationPolicy, @JsonKey(name: 'package_registry_access_level') this.packageRegistryAccessLevel, @JsonKey(name: 'open_issues_count') this.openIssuesCount, @JsonKey(name: 'forks_count') this.forksCount, @JsonKey(name: 'wiki_access_level') this.wikiAccessLevel, @JsonKey(name: 'wiki_enabled') this.wikiEnabled, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'web_url') this.webUrl, @JsonKey(name: 'last_activity_at') this.lastActivityAt}): super._();
  factory _Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'path_with_namespace') final  String pathWithNamespace;
@override final  String? description;
// Always shown as a number in the UI, so absent means zero, not unknown.
@override@JsonKey(name: 'star_count') final  int starCount;
@override final  String? visibility;
@override@JsonKey(name: 'default_branch') final  String? defaultBranch;
@override@JsonKey(name: 'container_registry_access_level') final  String? containerRegistryAccessLevel;
@override@JsonKey(name: 'container_expiration_policy') final  ContainerCleanupPolicy? containerExpirationPolicy;
@override@JsonKey(name: 'package_registry_access_level') final  String? packageRegistryAccessLevel;
// Null when GitLab omits the count on a reduced payload — unknown, not
// zero, so the UI hides it instead of showing a false 0.
@override@JsonKey(name: 'open_issues_count') final  int? openIssuesCount;
@override@JsonKey(name: 'forks_count') final  int? forksCount;
@override@JsonKey(name: 'wiki_access_level') final  String? wikiAccessLevel;
@override@JsonKey(name: 'wiki_enabled') final  bool? wikiEnabled;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'web_url') final  String? webUrl;
@override@JsonKey(name: 'last_activity_at') final  DateTime? lastActivityAt;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.pathWithNamespace, pathWithNamespace) || other.pathWithNamespace == pathWithNamespace)&&(identical(other.description, description) || other.description == description)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.containerRegistryAccessLevel, containerRegistryAccessLevel) || other.containerRegistryAccessLevel == containerRegistryAccessLevel)&&(identical(other.containerExpirationPolicy, containerExpirationPolicy) || other.containerExpirationPolicy == containerExpirationPolicy)&&(identical(other.packageRegistryAccessLevel, packageRegistryAccessLevel) || other.packageRegistryAccessLevel == packageRegistryAccessLevel)&&(identical(other.openIssuesCount, openIssuesCount) || other.openIssuesCount == openIssuesCount)&&(identical(other.forksCount, forksCount) || other.forksCount == forksCount)&&(identical(other.wikiAccessLevel, wikiAccessLevel) || other.wikiAccessLevel == wikiAccessLevel)&&(identical(other.wikiEnabled, wikiEnabled) || other.wikiEnabled == wikiEnabled)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,pathWithNamespace,description,starCount,visibility,defaultBranch,containerRegistryAccessLevel,containerExpirationPolicy,packageRegistryAccessLevel,openIssuesCount,forksCount,wikiAccessLevel,wikiEnabled,avatarUrl,webUrl,lastActivityAt);

@override
String toString() {
  return 'Project(id: $id, name: $name, pathWithNamespace: $pathWithNamespace, description: $description, starCount: $starCount, visibility: $visibility, defaultBranch: $defaultBranch, containerRegistryAccessLevel: $containerRegistryAccessLevel, containerExpirationPolicy: $containerExpirationPolicy, packageRegistryAccessLevel: $packageRegistryAccessLevel, openIssuesCount: $openIssuesCount, forksCount: $forksCount, wikiAccessLevel: $wikiAccessLevel, wikiEnabled: $wikiEnabled, avatarUrl: $avatarUrl, webUrl: $webUrl, lastActivityAt: $lastActivityAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'path_with_namespace') String pathWithNamespace, String? description,@JsonKey(name: 'star_count') int starCount, String? visibility,@JsonKey(name: 'default_branch') String? defaultBranch,@JsonKey(name: 'container_registry_access_level') String? containerRegistryAccessLevel,@JsonKey(name: 'container_expiration_policy') ContainerCleanupPolicy? containerExpirationPolicy,@JsonKey(name: 'package_registry_access_level') String? packageRegistryAccessLevel,@JsonKey(name: 'open_issues_count') int? openIssuesCount,@JsonKey(name: 'forks_count') int? forksCount,@JsonKey(name: 'wiki_access_level') String? wikiAccessLevel,@JsonKey(name: 'wiki_enabled') bool? wikiEnabled,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'web_url') String? webUrl,@JsonKey(name: 'last_activity_at') DateTime? lastActivityAt
});


@override $ContainerCleanupPolicyCopyWith<$Res>? get containerExpirationPolicy;

}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? pathWithNamespace = null,Object? description = freezed,Object? starCount = null,Object? visibility = freezed,Object? defaultBranch = freezed,Object? containerRegistryAccessLevel = freezed,Object? containerExpirationPolicy = freezed,Object? packageRegistryAccessLevel = freezed,Object? openIssuesCount = freezed,Object? forksCount = freezed,Object? wikiAccessLevel = freezed,Object? wikiEnabled = freezed,Object? avatarUrl = freezed,Object? webUrl = freezed,Object? lastActivityAt = freezed,}) {
  return _then(_Project(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pathWithNamespace: null == pathWithNamespace ? _self.pathWithNamespace : pathWithNamespace // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,defaultBranch: freezed == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String?,containerRegistryAccessLevel: freezed == containerRegistryAccessLevel ? _self.containerRegistryAccessLevel : containerRegistryAccessLevel // ignore: cast_nullable_to_non_nullable
as String?,containerExpirationPolicy: freezed == containerExpirationPolicy ? _self.containerExpirationPolicy : containerExpirationPolicy // ignore: cast_nullable_to_non_nullable
as ContainerCleanupPolicy?,packageRegistryAccessLevel: freezed == packageRegistryAccessLevel ? _self.packageRegistryAccessLevel : packageRegistryAccessLevel // ignore: cast_nullable_to_non_nullable
as String?,openIssuesCount: freezed == openIssuesCount ? _self.openIssuesCount : openIssuesCount // ignore: cast_nullable_to_non_nullable
as int?,forksCount: freezed == forksCount ? _self.forksCount : forksCount // ignore: cast_nullable_to_non_nullable
as int?,wikiAccessLevel: freezed == wikiAccessLevel ? _self.wikiAccessLevel : wikiAccessLevel // ignore: cast_nullable_to_non_nullable
as String?,wikiEnabled: freezed == wikiEnabled ? _self.wikiEnabled : wikiEnabled // ignore: cast_nullable_to_non_nullable
as bool?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContainerCleanupPolicyCopyWith<$Res>? get containerExpirationPolicy {
    if (_self.containerExpirationPolicy == null) {
    return null;
  }

  return $ContainerCleanupPolicyCopyWith<$Res>(_self.containerExpirationPolicy!, (value) {
    return _then(_self.copyWith(containerExpirationPolicy: value));
  });
}
}

// dart format on
