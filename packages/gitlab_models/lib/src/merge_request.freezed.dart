// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MergeRequest {

 int get id; int get iid; String get title; String get state;@JsonKey(name: 'source_branch') String get sourceBranch;@JsonKey(name: 'target_branch') String get targetBranch;// Present in list and search responses; lets a search hit route to its
// project. Absent when a single MR is fetched under a known project.
@JsonKey(name: 'project_id') int? get projectId; String? get description; User? get author; List<User> get assignees;@JsonKey(fromJson: Label.listFromJson) List<Label> get labels; bool get draft;@JsonKey(name: 'merge_status') String? get mergeStatus;@JsonKey(name: 'detailed_merge_status') String? get detailedMergeStatus;@JsonKey(name: 'user_notes_count') int get commentCount; bool? get subscribed;@JsonKey(name: 'web_url') String? get webUrl;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of MergeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MergeRequestCopyWith<MergeRequest> get copyWith => _$MergeRequestCopyWithImpl<MergeRequest>(this as MergeRequest, _$identity);

  /// Serializes this MergeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MergeRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.iid, iid) || other.iid == iid)&&(identical(other.title, title) || other.title == title)&&(identical(other.state, state) || other.state == state)&&(identical(other.sourceBranch, sourceBranch) || other.sourceBranch == sourceBranch)&&(identical(other.targetBranch, targetBranch) || other.targetBranch == targetBranch)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other.assignees, assignees)&&const DeepCollectionEquality().equals(other.labels, labels)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.mergeStatus, mergeStatus) || other.mergeStatus == mergeStatus)&&(identical(other.detailedMergeStatus, detailedMergeStatus) || other.detailedMergeStatus == detailedMergeStatus)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,iid,title,state,sourceBranch,targetBranch,projectId,description,author,const DeepCollectionEquality().hash(assignees),const DeepCollectionEquality().hash(labels),draft,mergeStatus,detailedMergeStatus,commentCount,subscribed,webUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'MergeRequest(id: $id, iid: $iid, title: $title, state: $state, sourceBranch: $sourceBranch, targetBranch: $targetBranch, projectId: $projectId, description: $description, author: $author, assignees: $assignees, labels: $labels, draft: $draft, mergeStatus: $mergeStatus, detailedMergeStatus: $detailedMergeStatus, commentCount: $commentCount, subscribed: $subscribed, webUrl: $webUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MergeRequestCopyWith<$Res>  {
  factory $MergeRequestCopyWith(MergeRequest value, $Res Function(MergeRequest) _then) = _$MergeRequestCopyWithImpl;
@useResult
$Res call({
 int id, int iid, String title, String state,@JsonKey(name: 'source_branch') String sourceBranch,@JsonKey(name: 'target_branch') String targetBranch,@JsonKey(name: 'project_id') int? projectId, String? description, User? author, List<User> assignees,@JsonKey(fromJson: Label.listFromJson) List<Label> labels, bool draft,@JsonKey(name: 'merge_status') String? mergeStatus,@JsonKey(name: 'detailed_merge_status') String? detailedMergeStatus,@JsonKey(name: 'user_notes_count') int commentCount, bool? subscribed,@JsonKey(name: 'web_url') String? webUrl,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});


$UserCopyWith<$Res>? get author;

}
/// @nodoc
class _$MergeRequestCopyWithImpl<$Res>
    implements $MergeRequestCopyWith<$Res> {
  _$MergeRequestCopyWithImpl(this._self, this._then);

  final MergeRequest _self;
  final $Res Function(MergeRequest) _then;

/// Create a copy of MergeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? iid = null,Object? title = null,Object? state = null,Object? sourceBranch = null,Object? targetBranch = null,Object? projectId = freezed,Object? description = freezed,Object? author = freezed,Object? assignees = null,Object? labels = null,Object? draft = null,Object? mergeStatus = freezed,Object? detailedMergeStatus = freezed,Object? commentCount = null,Object? subscribed = freezed,Object? webUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,iid: null == iid ? _self.iid : iid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,sourceBranch: null == sourceBranch ? _self.sourceBranch : sourceBranch // ignore: cast_nullable_to_non_nullable
as String,targetBranch: null == targetBranch ? _self.targetBranch : targetBranch // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as User?,assignees: null == assignees ? _self.assignees : assignees // ignore: cast_nullable_to_non_nullable
as List<User>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<Label>,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as bool,mergeStatus: freezed == mergeStatus ? _self.mergeStatus : mergeStatus // ignore: cast_nullable_to_non_nullable
as String?,detailedMergeStatus: freezed == detailedMergeStatus ? _self.detailedMergeStatus : detailedMergeStatus // ignore: cast_nullable_to_non_nullable
as String?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,subscribed: freezed == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as bool?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of MergeRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [MergeRequest].
extension MergeRequestPatterns on MergeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MergeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MergeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MergeRequest value)  $default,){
final _that = this;
switch (_that) {
case _MergeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MergeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MergeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int iid,  String title,  String state, @JsonKey(name: 'source_branch')  String sourceBranch, @JsonKey(name: 'target_branch')  String targetBranch, @JsonKey(name: 'project_id')  int? projectId,  String? description,  User? author,  List<User> assignees, @JsonKey(fromJson: Label.listFromJson)  List<Label> labels,  bool draft, @JsonKey(name: 'merge_status')  String? mergeStatus, @JsonKey(name: 'detailed_merge_status')  String? detailedMergeStatus, @JsonKey(name: 'user_notes_count')  int commentCount,  bool? subscribed, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MergeRequest() when $default != null:
return $default(_that.id,_that.iid,_that.title,_that.state,_that.sourceBranch,_that.targetBranch,_that.projectId,_that.description,_that.author,_that.assignees,_that.labels,_that.draft,_that.mergeStatus,_that.detailedMergeStatus,_that.commentCount,_that.subscribed,_that.webUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int iid,  String title,  String state, @JsonKey(name: 'source_branch')  String sourceBranch, @JsonKey(name: 'target_branch')  String targetBranch, @JsonKey(name: 'project_id')  int? projectId,  String? description,  User? author,  List<User> assignees, @JsonKey(fromJson: Label.listFromJson)  List<Label> labels,  bool draft, @JsonKey(name: 'merge_status')  String? mergeStatus, @JsonKey(name: 'detailed_merge_status')  String? detailedMergeStatus, @JsonKey(name: 'user_notes_count')  int commentCount,  bool? subscribed, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MergeRequest():
return $default(_that.id,_that.iid,_that.title,_that.state,_that.sourceBranch,_that.targetBranch,_that.projectId,_that.description,_that.author,_that.assignees,_that.labels,_that.draft,_that.mergeStatus,_that.detailedMergeStatus,_that.commentCount,_that.subscribed,_that.webUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int iid,  String title,  String state, @JsonKey(name: 'source_branch')  String sourceBranch, @JsonKey(name: 'target_branch')  String targetBranch, @JsonKey(name: 'project_id')  int? projectId,  String? description,  User? author,  List<User> assignees, @JsonKey(fromJson: Label.listFromJson)  List<Label> labels,  bool draft, @JsonKey(name: 'merge_status')  String? mergeStatus, @JsonKey(name: 'detailed_merge_status')  String? detailedMergeStatus, @JsonKey(name: 'user_notes_count')  int commentCount,  bool? subscribed, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MergeRequest() when $default != null:
return $default(_that.id,_that.iid,_that.title,_that.state,_that.sourceBranch,_that.targetBranch,_that.projectId,_that.description,_that.author,_that.assignees,_that.labels,_that.draft,_that.mergeStatus,_that.detailedMergeStatus,_that.commentCount,_that.subscribed,_that.webUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MergeRequest extends MergeRequest {
  const _MergeRequest({required this.id, required this.iid, required this.title, required this.state, @JsonKey(name: 'source_branch') required this.sourceBranch, @JsonKey(name: 'target_branch') required this.targetBranch, @JsonKey(name: 'project_id') this.projectId, this.description, this.author, final  List<User> assignees = const <User>[], @JsonKey(fromJson: Label.listFromJson) final  List<Label> labels = const <Label>[], this.draft = false, @JsonKey(name: 'merge_status') this.mergeStatus, @JsonKey(name: 'detailed_merge_status') this.detailedMergeStatus, @JsonKey(name: 'user_notes_count') this.commentCount = 0, this.subscribed, @JsonKey(name: 'web_url') this.webUrl, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _assignees = assignees,_labels = labels,super._();
  factory _MergeRequest.fromJson(Map<String, dynamic> json) => _$MergeRequestFromJson(json);

@override final  int id;
@override final  int iid;
@override final  String title;
@override final  String state;
@override@JsonKey(name: 'source_branch') final  String sourceBranch;
@override@JsonKey(name: 'target_branch') final  String targetBranch;
// Present in list and search responses; lets a search hit route to its
// project. Absent when a single MR is fetched under a known project.
@override@JsonKey(name: 'project_id') final  int? projectId;
@override final  String? description;
@override final  User? author;
 final  List<User> _assignees;
@override@JsonKey() List<User> get assignees {
  if (_assignees is EqualUnmodifiableListView) return _assignees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignees);
}

 final  List<Label> _labels;
@override@JsonKey(fromJson: Label.listFromJson) List<Label> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

@override@JsonKey() final  bool draft;
@override@JsonKey(name: 'merge_status') final  String? mergeStatus;
@override@JsonKey(name: 'detailed_merge_status') final  String? detailedMergeStatus;
@override@JsonKey(name: 'user_notes_count') final  int commentCount;
@override final  bool? subscribed;
@override@JsonKey(name: 'web_url') final  String? webUrl;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of MergeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MergeRequestCopyWith<_MergeRequest> get copyWith => __$MergeRequestCopyWithImpl<_MergeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MergeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MergeRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.iid, iid) || other.iid == iid)&&(identical(other.title, title) || other.title == title)&&(identical(other.state, state) || other.state == state)&&(identical(other.sourceBranch, sourceBranch) || other.sourceBranch == sourceBranch)&&(identical(other.targetBranch, targetBranch) || other.targetBranch == targetBranch)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other._assignees, _assignees)&&const DeepCollectionEquality().equals(other._labels, _labels)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.mergeStatus, mergeStatus) || other.mergeStatus == mergeStatus)&&(identical(other.detailedMergeStatus, detailedMergeStatus) || other.detailedMergeStatus == detailedMergeStatus)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,iid,title,state,sourceBranch,targetBranch,projectId,description,author,const DeepCollectionEquality().hash(_assignees),const DeepCollectionEquality().hash(_labels),draft,mergeStatus,detailedMergeStatus,commentCount,subscribed,webUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'MergeRequest(id: $id, iid: $iid, title: $title, state: $state, sourceBranch: $sourceBranch, targetBranch: $targetBranch, projectId: $projectId, description: $description, author: $author, assignees: $assignees, labels: $labels, draft: $draft, mergeStatus: $mergeStatus, detailedMergeStatus: $detailedMergeStatus, commentCount: $commentCount, subscribed: $subscribed, webUrl: $webUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MergeRequestCopyWith<$Res> implements $MergeRequestCopyWith<$Res> {
  factory _$MergeRequestCopyWith(_MergeRequest value, $Res Function(_MergeRequest) _then) = __$MergeRequestCopyWithImpl;
@override @useResult
$Res call({
 int id, int iid, String title, String state,@JsonKey(name: 'source_branch') String sourceBranch,@JsonKey(name: 'target_branch') String targetBranch,@JsonKey(name: 'project_id') int? projectId, String? description, User? author, List<User> assignees,@JsonKey(fromJson: Label.listFromJson) List<Label> labels, bool draft,@JsonKey(name: 'merge_status') String? mergeStatus,@JsonKey(name: 'detailed_merge_status') String? detailedMergeStatus,@JsonKey(name: 'user_notes_count') int commentCount, bool? subscribed,@JsonKey(name: 'web_url') String? webUrl,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});


@override $UserCopyWith<$Res>? get author;

}
/// @nodoc
class __$MergeRequestCopyWithImpl<$Res>
    implements _$MergeRequestCopyWith<$Res> {
  __$MergeRequestCopyWithImpl(this._self, this._then);

  final _MergeRequest _self;
  final $Res Function(_MergeRequest) _then;

/// Create a copy of MergeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? iid = null,Object? title = null,Object? state = null,Object? sourceBranch = null,Object? targetBranch = null,Object? projectId = freezed,Object? description = freezed,Object? author = freezed,Object? assignees = null,Object? labels = null,Object? draft = null,Object? mergeStatus = freezed,Object? detailedMergeStatus = freezed,Object? commentCount = null,Object? subscribed = freezed,Object? webUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_MergeRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,iid: null == iid ? _self.iid : iid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,sourceBranch: null == sourceBranch ? _self.sourceBranch : sourceBranch // ignore: cast_nullable_to_non_nullable
as String,targetBranch: null == targetBranch ? _self.targetBranch : targetBranch // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as User?,assignees: null == assignees ? _self._assignees : assignees // ignore: cast_nullable_to_non_nullable
as List<User>,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<Label>,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as bool,mergeStatus: freezed == mergeStatus ? _self.mergeStatus : mergeStatus // ignore: cast_nullable_to_non_nullable
as String?,detailedMergeStatus: freezed == detailedMergeStatus ? _self.detailedMergeStatus : detailedMergeStatus // ignore: cast_nullable_to_non_nullable
as String?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,subscribed: freezed == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as bool?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of MergeRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}

// dart format on
