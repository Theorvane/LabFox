// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gitlab_release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitLabRelease {

 String get name;@JsonKey(name: 'tag_name') String get tagName; String? get description;@JsonKey(name: 'released_at') DateTime? get releasedAt;@JsonKey(name: 'upcoming_release') bool? get upcomingRelease;@JsonKey(name: 'historical_release') bool? get historicalRelease; ReleaseAssets? get assets; List<GitLabMilestone> get milestones;
/// Create a copy of GitLabRelease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitLabReleaseCopyWith<GitLabRelease> get copyWith => _$GitLabReleaseCopyWithImpl<GitLabRelease>(this as GitLabRelease, _$identity);

  /// Serializes this GitLabRelease to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitLabRelease&&(identical(other.name, name) || other.name == name)&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.description, description) || other.description == description)&&(identical(other.releasedAt, releasedAt) || other.releasedAt == releasedAt)&&(identical(other.upcomingRelease, upcomingRelease) || other.upcomingRelease == upcomingRelease)&&(identical(other.historicalRelease, historicalRelease) || other.historicalRelease == historicalRelease)&&(identical(other.assets, assets) || other.assets == assets)&&const DeepCollectionEquality().equals(other.milestones, milestones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,tagName,description,releasedAt,upcomingRelease,historicalRelease,assets,const DeepCollectionEquality().hash(milestones));

@override
String toString() {
  return 'GitLabRelease(name: $name, tagName: $tagName, description: $description, releasedAt: $releasedAt, upcomingRelease: $upcomingRelease, historicalRelease: $historicalRelease, assets: $assets, milestones: $milestones)';
}


}

/// @nodoc
abstract mixin class $GitLabReleaseCopyWith<$Res>  {
  factory $GitLabReleaseCopyWith(GitLabRelease value, $Res Function(GitLabRelease) _then) = _$GitLabReleaseCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(name: 'tag_name') String tagName, String? description,@JsonKey(name: 'released_at') DateTime? releasedAt,@JsonKey(name: 'upcoming_release') bool? upcomingRelease,@JsonKey(name: 'historical_release') bool? historicalRelease, ReleaseAssets? assets, List<GitLabMilestone> milestones
});


$ReleaseAssetsCopyWith<$Res>? get assets;

}
/// @nodoc
class _$GitLabReleaseCopyWithImpl<$Res>
    implements $GitLabReleaseCopyWith<$Res> {
  _$GitLabReleaseCopyWithImpl(this._self, this._then);

  final GitLabRelease _self;
  final $Res Function(GitLabRelease) _then;

/// Create a copy of GitLabRelease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? tagName = null,Object? description = freezed,Object? releasedAt = freezed,Object? upcomingRelease = freezed,Object? historicalRelease = freezed,Object? assets = freezed,Object? milestones = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,releasedAt: freezed == releasedAt ? _self.releasedAt : releasedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,upcomingRelease: freezed == upcomingRelease ? _self.upcomingRelease : upcomingRelease // ignore: cast_nullable_to_non_nullable
as bool?,historicalRelease: freezed == historicalRelease ? _self.historicalRelease : historicalRelease // ignore: cast_nullable_to_non_nullable
as bool?,assets: freezed == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as ReleaseAssets?,milestones: null == milestones ? _self.milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<GitLabMilestone>,
  ));
}
/// Create a copy of GitLabRelease
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseAssetsCopyWith<$Res>? get assets {
    if (_self.assets == null) {
    return null;
  }

  return $ReleaseAssetsCopyWith<$Res>(_self.assets!, (value) {
    return _then(_self.copyWith(assets: value));
  });
}
}


/// Adds pattern-matching-related methods to [GitLabRelease].
extension GitLabReleasePatterns on GitLabRelease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitLabRelease value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitLabRelease() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitLabRelease value)  $default,){
final _that = this;
switch (_that) {
case _GitLabRelease():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitLabRelease value)?  $default,){
final _that = this;
switch (_that) {
case _GitLabRelease() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'tag_name')  String tagName,  String? description, @JsonKey(name: 'released_at')  DateTime? releasedAt, @JsonKey(name: 'upcoming_release')  bool? upcomingRelease, @JsonKey(name: 'historical_release')  bool? historicalRelease,  ReleaseAssets? assets,  List<GitLabMilestone> milestones)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitLabRelease() when $default != null:
return $default(_that.name,_that.tagName,_that.description,_that.releasedAt,_that.upcomingRelease,_that.historicalRelease,_that.assets,_that.milestones);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'tag_name')  String tagName,  String? description, @JsonKey(name: 'released_at')  DateTime? releasedAt, @JsonKey(name: 'upcoming_release')  bool? upcomingRelease, @JsonKey(name: 'historical_release')  bool? historicalRelease,  ReleaseAssets? assets,  List<GitLabMilestone> milestones)  $default,) {final _that = this;
switch (_that) {
case _GitLabRelease():
return $default(_that.name,_that.tagName,_that.description,_that.releasedAt,_that.upcomingRelease,_that.historicalRelease,_that.assets,_that.milestones);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(name: 'tag_name')  String tagName,  String? description, @JsonKey(name: 'released_at')  DateTime? releasedAt, @JsonKey(name: 'upcoming_release')  bool? upcomingRelease, @JsonKey(name: 'historical_release')  bool? historicalRelease,  ReleaseAssets? assets,  List<GitLabMilestone> milestones)?  $default,) {final _that = this;
switch (_that) {
case _GitLabRelease() when $default != null:
return $default(_that.name,_that.tagName,_that.description,_that.releasedAt,_that.upcomingRelease,_that.historicalRelease,_that.assets,_that.milestones);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GitLabRelease implements GitLabRelease {
  const _GitLabRelease({required this.name, @JsonKey(name: 'tag_name') required this.tagName, this.description, @JsonKey(name: 'released_at') this.releasedAt, @JsonKey(name: 'upcoming_release') this.upcomingRelease, @JsonKey(name: 'historical_release') this.historicalRelease, this.assets, final  List<GitLabMilestone> milestones = const []}): _milestones = milestones;
  factory _GitLabRelease.fromJson(Map<String, dynamic> json) => _$GitLabReleaseFromJson(json);

@override final  String name;
@override@JsonKey(name: 'tag_name') final  String tagName;
@override final  String? description;
@override@JsonKey(name: 'released_at') final  DateTime? releasedAt;
@override@JsonKey(name: 'upcoming_release') final  bool? upcomingRelease;
@override@JsonKey(name: 'historical_release') final  bool? historicalRelease;
@override final  ReleaseAssets? assets;
 final  List<GitLabMilestone> _milestones;
@override@JsonKey() List<GitLabMilestone> get milestones {
  if (_milestones is EqualUnmodifiableListView) return _milestones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_milestones);
}


/// Create a copy of GitLabRelease
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitLabReleaseCopyWith<_GitLabRelease> get copyWith => __$GitLabReleaseCopyWithImpl<_GitLabRelease>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GitLabReleaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitLabRelease&&(identical(other.name, name) || other.name == name)&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.description, description) || other.description == description)&&(identical(other.releasedAt, releasedAt) || other.releasedAt == releasedAt)&&(identical(other.upcomingRelease, upcomingRelease) || other.upcomingRelease == upcomingRelease)&&(identical(other.historicalRelease, historicalRelease) || other.historicalRelease == historicalRelease)&&(identical(other.assets, assets) || other.assets == assets)&&const DeepCollectionEquality().equals(other._milestones, _milestones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,tagName,description,releasedAt,upcomingRelease,historicalRelease,assets,const DeepCollectionEquality().hash(_milestones));

@override
String toString() {
  return 'GitLabRelease(name: $name, tagName: $tagName, description: $description, releasedAt: $releasedAt, upcomingRelease: $upcomingRelease, historicalRelease: $historicalRelease, assets: $assets, milestones: $milestones)';
}


}

/// @nodoc
abstract mixin class _$GitLabReleaseCopyWith<$Res> implements $GitLabReleaseCopyWith<$Res> {
  factory _$GitLabReleaseCopyWith(_GitLabRelease value, $Res Function(_GitLabRelease) _then) = __$GitLabReleaseCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(name: 'tag_name') String tagName, String? description,@JsonKey(name: 'released_at') DateTime? releasedAt,@JsonKey(name: 'upcoming_release') bool? upcomingRelease,@JsonKey(name: 'historical_release') bool? historicalRelease, ReleaseAssets? assets, List<GitLabMilestone> milestones
});


@override $ReleaseAssetsCopyWith<$Res>? get assets;

}
/// @nodoc
class __$GitLabReleaseCopyWithImpl<$Res>
    implements _$GitLabReleaseCopyWith<$Res> {
  __$GitLabReleaseCopyWithImpl(this._self, this._then);

  final _GitLabRelease _self;
  final $Res Function(_GitLabRelease) _then;

/// Create a copy of GitLabRelease
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? tagName = null,Object? description = freezed,Object? releasedAt = freezed,Object? upcomingRelease = freezed,Object? historicalRelease = freezed,Object? assets = freezed,Object? milestones = null,}) {
  return _then(_GitLabRelease(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,releasedAt: freezed == releasedAt ? _self.releasedAt : releasedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,upcomingRelease: freezed == upcomingRelease ? _self.upcomingRelease : upcomingRelease // ignore: cast_nullable_to_non_nullable
as bool?,historicalRelease: freezed == historicalRelease ? _self.historicalRelease : historicalRelease // ignore: cast_nullable_to_non_nullable
as bool?,assets: freezed == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as ReleaseAssets?,milestones: null == milestones ? _self._milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<GitLabMilestone>,
  ));
}

/// Create a copy of GitLabRelease
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseAssetsCopyWith<$Res>? get assets {
    if (_self.assets == null) {
    return null;
  }

  return $ReleaseAssetsCopyWith<$Res>(_self.assets!, (value) {
    return _then(_self.copyWith(assets: value));
  });
}
}


/// @nodoc
mixin _$ReleaseAssets {

 List<ReleaseAssetLink> get links; List<ReleaseSource> get sources;
/// Create a copy of ReleaseAssets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseAssetsCopyWith<ReleaseAssets> get copyWith => _$ReleaseAssetsCopyWithImpl<ReleaseAssets>(this as ReleaseAssets, _$identity);

  /// Serializes this ReleaseAssets to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseAssets&&const DeepCollectionEquality().equals(other.links, links)&&const DeepCollectionEquality().equals(other.sources, sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(links),const DeepCollectionEquality().hash(sources));

@override
String toString() {
  return 'ReleaseAssets(links: $links, sources: $sources)';
}


}

/// @nodoc
abstract mixin class $ReleaseAssetsCopyWith<$Res>  {
  factory $ReleaseAssetsCopyWith(ReleaseAssets value, $Res Function(ReleaseAssets) _then) = _$ReleaseAssetsCopyWithImpl;
@useResult
$Res call({
 List<ReleaseAssetLink> links, List<ReleaseSource> sources
});




}
/// @nodoc
class _$ReleaseAssetsCopyWithImpl<$Res>
    implements $ReleaseAssetsCopyWith<$Res> {
  _$ReleaseAssetsCopyWithImpl(this._self, this._then);

  final ReleaseAssets _self;
  final $Res Function(ReleaseAssets) _then;

/// Create a copy of ReleaseAssets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? links = null,Object? sources = null,}) {
  return _then(_self.copyWith(
links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<ReleaseAssetLink>,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<ReleaseSource>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseAssets].
extension ReleaseAssetsPatterns on ReleaseAssets {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseAssets value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseAssets() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseAssets value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseAssets():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseAssets value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseAssets() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ReleaseAssetLink> links,  List<ReleaseSource> sources)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseAssets() when $default != null:
return $default(_that.links,_that.sources);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ReleaseAssetLink> links,  List<ReleaseSource> sources)  $default,) {final _that = this;
switch (_that) {
case _ReleaseAssets():
return $default(_that.links,_that.sources);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ReleaseAssetLink> links,  List<ReleaseSource> sources)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseAssets() when $default != null:
return $default(_that.links,_that.sources);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseAssets implements ReleaseAssets {
  const _ReleaseAssets({final  List<ReleaseAssetLink> links = const [], final  List<ReleaseSource> sources = const []}): _links = links,_sources = sources;
  factory _ReleaseAssets.fromJson(Map<String, dynamic> json) => _$ReleaseAssetsFromJson(json);

 final  List<ReleaseAssetLink> _links;
@override@JsonKey() List<ReleaseAssetLink> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}

 final  List<ReleaseSource> _sources;
@override@JsonKey() List<ReleaseSource> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}


/// Create a copy of ReleaseAssets
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseAssetsCopyWith<_ReleaseAssets> get copyWith => __$ReleaseAssetsCopyWithImpl<_ReleaseAssets>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseAssetsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseAssets&&const DeepCollectionEquality().equals(other._links, _links)&&const DeepCollectionEquality().equals(other._sources, _sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_links),const DeepCollectionEquality().hash(_sources));

@override
String toString() {
  return 'ReleaseAssets(links: $links, sources: $sources)';
}


}

/// @nodoc
abstract mixin class _$ReleaseAssetsCopyWith<$Res> implements $ReleaseAssetsCopyWith<$Res> {
  factory _$ReleaseAssetsCopyWith(_ReleaseAssets value, $Res Function(_ReleaseAssets) _then) = __$ReleaseAssetsCopyWithImpl;
@override @useResult
$Res call({
 List<ReleaseAssetLink> links, List<ReleaseSource> sources
});




}
/// @nodoc
class __$ReleaseAssetsCopyWithImpl<$Res>
    implements _$ReleaseAssetsCopyWith<$Res> {
  __$ReleaseAssetsCopyWithImpl(this._self, this._then);

  final _ReleaseAssets _self;
  final $Res Function(_ReleaseAssets) _then;

/// Create a copy of ReleaseAssets
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? links = null,Object? sources = null,}) {
  return _then(_ReleaseAssets(
links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<ReleaseAssetLink>,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<ReleaseSource>,
  ));
}


}


/// @nodoc
mixin _$ReleaseAssetLink {

 int get id; String get name; String get url;@JsonKey(name: 'direct_asset_url') String? get directAssetUrl;@JsonKey(name: 'link_type') String? get linkType;
/// Create a copy of ReleaseAssetLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseAssetLinkCopyWith<ReleaseAssetLink> get copyWith => _$ReleaseAssetLinkCopyWithImpl<ReleaseAssetLink>(this as ReleaseAssetLink, _$identity);

  /// Serializes this ReleaseAssetLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseAssetLink&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.directAssetUrl, directAssetUrl) || other.directAssetUrl == directAssetUrl)&&(identical(other.linkType, linkType) || other.linkType == linkType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,url,directAssetUrl,linkType);

@override
String toString() {
  return 'ReleaseAssetLink(id: $id, name: $name, url: $url, directAssetUrl: $directAssetUrl, linkType: $linkType)';
}


}

/// @nodoc
abstract mixin class $ReleaseAssetLinkCopyWith<$Res>  {
  factory $ReleaseAssetLinkCopyWith(ReleaseAssetLink value, $Res Function(ReleaseAssetLink) _then) = _$ReleaseAssetLinkCopyWithImpl;
@useResult
$Res call({
 int id, String name, String url,@JsonKey(name: 'direct_asset_url') String? directAssetUrl,@JsonKey(name: 'link_type') String? linkType
});




}
/// @nodoc
class _$ReleaseAssetLinkCopyWithImpl<$Res>
    implements $ReleaseAssetLinkCopyWith<$Res> {
  _$ReleaseAssetLinkCopyWithImpl(this._self, this._then);

  final ReleaseAssetLink _self;
  final $Res Function(ReleaseAssetLink) _then;

/// Create a copy of ReleaseAssetLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? url = null,Object? directAssetUrl = freezed,Object? linkType = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,directAssetUrl: freezed == directAssetUrl ? _self.directAssetUrl : directAssetUrl // ignore: cast_nullable_to_non_nullable
as String?,linkType: freezed == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseAssetLink].
extension ReleaseAssetLinkPatterns on ReleaseAssetLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseAssetLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseAssetLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseAssetLink value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseAssetLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseAssetLink value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseAssetLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String url, @JsonKey(name: 'direct_asset_url')  String? directAssetUrl, @JsonKey(name: 'link_type')  String? linkType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseAssetLink() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.directAssetUrl,_that.linkType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String url, @JsonKey(name: 'direct_asset_url')  String? directAssetUrl, @JsonKey(name: 'link_type')  String? linkType)  $default,) {final _that = this;
switch (_that) {
case _ReleaseAssetLink():
return $default(_that.id,_that.name,_that.url,_that.directAssetUrl,_that.linkType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String url, @JsonKey(name: 'direct_asset_url')  String? directAssetUrl, @JsonKey(name: 'link_type')  String? linkType)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseAssetLink() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.directAssetUrl,_that.linkType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseAssetLink implements ReleaseAssetLink {
  const _ReleaseAssetLink({required this.id, required this.name, required this.url, @JsonKey(name: 'direct_asset_url') this.directAssetUrl, @JsonKey(name: 'link_type') this.linkType});
  factory _ReleaseAssetLink.fromJson(Map<String, dynamic> json) => _$ReleaseAssetLinkFromJson(json);

@override final  int id;
@override final  String name;
@override final  String url;
@override@JsonKey(name: 'direct_asset_url') final  String? directAssetUrl;
@override@JsonKey(name: 'link_type') final  String? linkType;

/// Create a copy of ReleaseAssetLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseAssetLinkCopyWith<_ReleaseAssetLink> get copyWith => __$ReleaseAssetLinkCopyWithImpl<_ReleaseAssetLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseAssetLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseAssetLink&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.directAssetUrl, directAssetUrl) || other.directAssetUrl == directAssetUrl)&&(identical(other.linkType, linkType) || other.linkType == linkType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,url,directAssetUrl,linkType);

@override
String toString() {
  return 'ReleaseAssetLink(id: $id, name: $name, url: $url, directAssetUrl: $directAssetUrl, linkType: $linkType)';
}


}

/// @nodoc
abstract mixin class _$ReleaseAssetLinkCopyWith<$Res> implements $ReleaseAssetLinkCopyWith<$Res> {
  factory _$ReleaseAssetLinkCopyWith(_ReleaseAssetLink value, $Res Function(_ReleaseAssetLink) _then) = __$ReleaseAssetLinkCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String url,@JsonKey(name: 'direct_asset_url') String? directAssetUrl,@JsonKey(name: 'link_type') String? linkType
});




}
/// @nodoc
class __$ReleaseAssetLinkCopyWithImpl<$Res>
    implements _$ReleaseAssetLinkCopyWith<$Res> {
  __$ReleaseAssetLinkCopyWithImpl(this._self, this._then);

  final _ReleaseAssetLink _self;
  final $Res Function(_ReleaseAssetLink) _then;

/// Create a copy of ReleaseAssetLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? url = null,Object? directAssetUrl = freezed,Object? linkType = freezed,}) {
  return _then(_ReleaseAssetLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,directAssetUrl: freezed == directAssetUrl ? _self.directAssetUrl : directAssetUrl // ignore: cast_nullable_to_non_nullable
as String?,linkType: freezed == linkType ? _self.linkType : linkType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReleaseSource {

 String get format; String get url;
/// Create a copy of ReleaseSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseSourceCopyWith<ReleaseSource> get copyWith => _$ReleaseSourceCopyWithImpl<ReleaseSource>(this as ReleaseSource, _$identity);

  /// Serializes this ReleaseSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseSource&&(identical(other.format, format) || other.format == format)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,url);

@override
String toString() {
  return 'ReleaseSource(format: $format, url: $url)';
}


}

/// @nodoc
abstract mixin class $ReleaseSourceCopyWith<$Res>  {
  factory $ReleaseSourceCopyWith(ReleaseSource value, $Res Function(ReleaseSource) _then) = _$ReleaseSourceCopyWithImpl;
@useResult
$Res call({
 String format, String url
});




}
/// @nodoc
class _$ReleaseSourceCopyWithImpl<$Res>
    implements $ReleaseSourceCopyWith<$Res> {
  _$ReleaseSourceCopyWithImpl(this._self, this._then);

  final ReleaseSource _self;
  final $Res Function(ReleaseSource) _then;

/// Create a copy of ReleaseSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = null,Object? url = null,}) {
  return _then(_self.copyWith(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseSource].
extension ReleaseSourcePatterns on ReleaseSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseSource value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseSource value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String format,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseSource() when $default != null:
return $default(_that.format,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String format,  String url)  $default,) {final _that = this;
switch (_that) {
case _ReleaseSource():
return $default(_that.format,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String format,  String url)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseSource() when $default != null:
return $default(_that.format,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseSource implements ReleaseSource {
  const _ReleaseSource({required this.format, required this.url});
  factory _ReleaseSource.fromJson(Map<String, dynamic> json) => _$ReleaseSourceFromJson(json);

@override final  String format;
@override final  String url;

/// Create a copy of ReleaseSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseSourceCopyWith<_ReleaseSource> get copyWith => __$ReleaseSourceCopyWithImpl<_ReleaseSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseSource&&(identical(other.format, format) || other.format == format)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,url);

@override
String toString() {
  return 'ReleaseSource(format: $format, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ReleaseSourceCopyWith<$Res> implements $ReleaseSourceCopyWith<$Res> {
  factory _$ReleaseSourceCopyWith(_ReleaseSource value, $Res Function(_ReleaseSource) _then) = __$ReleaseSourceCopyWithImpl;
@override @useResult
$Res call({
 String format, String url
});




}
/// @nodoc
class __$ReleaseSourceCopyWithImpl<$Res>
    implements _$ReleaseSourceCopyWith<$Res> {
  __$ReleaseSourceCopyWithImpl(this._self, this._then);

  final _ReleaseSource _self;
  final $Res Function(_ReleaseSource) _then;

/// Create a copy of ReleaseSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? url = null,}) {
  return _then(_ReleaseSource(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
