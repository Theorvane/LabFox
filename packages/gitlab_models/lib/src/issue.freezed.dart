// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Issue {

 int get id; int get iid; String get title; String get state;// Present in list and search responses; lets a search hit route to its
// project. Absent when a single issue is fetched under a known project.
@JsonKey(name: 'project_id') int? get projectId; String? get description; User? get author; List<User> get assignees;@JsonKey(fromJson: Label.listFromJson) List<Label> get labels;@JsonKey(name: 'web_url') String? get webUrl;@JsonKey(name: 'user_notes_count') int get commentCount; bool? get subscribed;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'due_date') DateTime? get dueDate;
/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueCopyWith<Issue> get copyWith => _$IssueCopyWithImpl<Issue>(this as Issue, _$identity);

  /// Serializes this Issue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Issue&&(identical(other.id, id) || other.id == id)&&(identical(other.iid, iid) || other.iid == iid)&&(identical(other.title, title) || other.title == title)&&(identical(other.state, state) || other.state == state)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other.assignees, assignees)&&const DeepCollectionEquality().equals(other.labels, labels)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,iid,title,state,projectId,description,author,const DeepCollectionEquality().hash(assignees),const DeepCollectionEquality().hash(labels),webUrl,commentCount,subscribed,createdAt,updatedAt,dueDate);

@override
String toString() {
  return 'Issue(id: $id, iid: $iid, title: $title, state: $state, projectId: $projectId, description: $description, author: $author, assignees: $assignees, labels: $labels, webUrl: $webUrl, commentCount: $commentCount, subscribed: $subscribed, createdAt: $createdAt, updatedAt: $updatedAt, dueDate: $dueDate)';
}


}

/// @nodoc
abstract mixin class $IssueCopyWith<$Res>  {
  factory $IssueCopyWith(Issue value, $Res Function(Issue) _then) = _$IssueCopyWithImpl;
@useResult
$Res call({
 int id, int iid, String title, String state,@JsonKey(name: 'project_id') int? projectId, String? description, User? author, List<User> assignees,@JsonKey(fromJson: Label.listFromJson) List<Label> labels,@JsonKey(name: 'web_url') String? webUrl,@JsonKey(name: 'user_notes_count') int commentCount, bool? subscribed,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'due_date') DateTime? dueDate
});


$UserCopyWith<$Res>? get author;

}
/// @nodoc
class _$IssueCopyWithImpl<$Res>
    implements $IssueCopyWith<$Res> {
  _$IssueCopyWithImpl(this._self, this._then);

  final Issue _self;
  final $Res Function(Issue) _then;

/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? iid = null,Object? title = null,Object? state = null,Object? projectId = freezed,Object? description = freezed,Object? author = freezed,Object? assignees = null,Object? labels = null,Object? webUrl = freezed,Object? commentCount = null,Object? subscribed = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? dueDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,iid: null == iid ? _self.iid : iid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as User?,assignees: null == assignees ? _self.assignees : assignees // ignore: cast_nullable_to_non_nullable
as List<User>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<Label>,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,subscribed: freezed == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Issue
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


/// Adds pattern-matching-related methods to [Issue].
extension IssuePatterns on Issue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Issue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Issue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Issue value)  $default,){
final _that = this;
switch (_that) {
case _Issue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Issue value)?  $default,){
final _that = this;
switch (_that) {
case _Issue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int iid,  String title,  String state, @JsonKey(name: 'project_id')  int? projectId,  String? description,  User? author,  List<User> assignees, @JsonKey(fromJson: Label.listFromJson)  List<Label> labels, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'user_notes_count')  int commentCount,  bool? subscribed, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'due_date')  DateTime? dueDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Issue() when $default != null:
return $default(_that.id,_that.iid,_that.title,_that.state,_that.projectId,_that.description,_that.author,_that.assignees,_that.labels,_that.webUrl,_that.commentCount,_that.subscribed,_that.createdAt,_that.updatedAt,_that.dueDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int iid,  String title,  String state, @JsonKey(name: 'project_id')  int? projectId,  String? description,  User? author,  List<User> assignees, @JsonKey(fromJson: Label.listFromJson)  List<Label> labels, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'user_notes_count')  int commentCount,  bool? subscribed, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'due_date')  DateTime? dueDate)  $default,) {final _that = this;
switch (_that) {
case _Issue():
return $default(_that.id,_that.iid,_that.title,_that.state,_that.projectId,_that.description,_that.author,_that.assignees,_that.labels,_that.webUrl,_that.commentCount,_that.subscribed,_that.createdAt,_that.updatedAt,_that.dueDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int iid,  String title,  String state, @JsonKey(name: 'project_id')  int? projectId,  String? description,  User? author,  List<User> assignees, @JsonKey(fromJson: Label.listFromJson)  List<Label> labels, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'user_notes_count')  int commentCount,  bool? subscribed, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'due_date')  DateTime? dueDate)?  $default,) {final _that = this;
switch (_that) {
case _Issue() when $default != null:
return $default(_that.id,_that.iid,_that.title,_that.state,_that.projectId,_that.description,_that.author,_that.assignees,_that.labels,_that.webUrl,_that.commentCount,_that.subscribed,_that.createdAt,_that.updatedAt,_that.dueDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Issue extends Issue {
  const _Issue({required this.id, required this.iid, required this.title, required this.state, @JsonKey(name: 'project_id') this.projectId, this.description, this.author, final  List<User> assignees = const <User>[], @JsonKey(fromJson: Label.listFromJson) final  List<Label> labels = const <Label>[], @JsonKey(name: 'web_url') this.webUrl, @JsonKey(name: 'user_notes_count') this.commentCount = 0, this.subscribed, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'due_date') this.dueDate}): _assignees = assignees,_labels = labels,super._();
  factory _Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);

@override final  int id;
@override final  int iid;
@override final  String title;
@override final  String state;
// Present in list and search responses; lets a search hit route to its
// project. Absent when a single issue is fetched under a known project.
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

@override@JsonKey(name: 'web_url') final  String? webUrl;
@override@JsonKey(name: 'user_notes_count') final  int commentCount;
@override final  bool? subscribed;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'due_date') final  DateTime? dueDate;

/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueCopyWith<_Issue> get copyWith => __$IssueCopyWithImpl<_Issue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Issue&&(identical(other.id, id) || other.id == id)&&(identical(other.iid, iid) || other.iid == iid)&&(identical(other.title, title) || other.title == title)&&(identical(other.state, state) || other.state == state)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other._assignees, _assignees)&&const DeepCollectionEquality().equals(other._labels, _labels)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,iid,title,state,projectId,description,author,const DeepCollectionEquality().hash(_assignees),const DeepCollectionEquality().hash(_labels),webUrl,commentCount,subscribed,createdAt,updatedAt,dueDate);

@override
String toString() {
  return 'Issue(id: $id, iid: $iid, title: $title, state: $state, projectId: $projectId, description: $description, author: $author, assignees: $assignees, labels: $labels, webUrl: $webUrl, commentCount: $commentCount, subscribed: $subscribed, createdAt: $createdAt, updatedAt: $updatedAt, dueDate: $dueDate)';
}


}

/// @nodoc
abstract mixin class _$IssueCopyWith<$Res> implements $IssueCopyWith<$Res> {
  factory _$IssueCopyWith(_Issue value, $Res Function(_Issue) _then) = __$IssueCopyWithImpl;
@override @useResult
$Res call({
 int id, int iid, String title, String state,@JsonKey(name: 'project_id') int? projectId, String? description, User? author, List<User> assignees,@JsonKey(fromJson: Label.listFromJson) List<Label> labels,@JsonKey(name: 'web_url') String? webUrl,@JsonKey(name: 'user_notes_count') int commentCount, bool? subscribed,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'due_date') DateTime? dueDate
});


@override $UserCopyWith<$Res>? get author;

}
/// @nodoc
class __$IssueCopyWithImpl<$Res>
    implements _$IssueCopyWith<$Res> {
  __$IssueCopyWithImpl(this._self, this._then);

  final _Issue _self;
  final $Res Function(_Issue) _then;

/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? iid = null,Object? title = null,Object? state = null,Object? projectId = freezed,Object? description = freezed,Object? author = freezed,Object? assignees = null,Object? labels = null,Object? webUrl = freezed,Object? commentCount = null,Object? subscribed = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? dueDate = freezed,}) {
  return _then(_Issue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,iid: null == iid ? _self.iid : iid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as User?,assignees: null == assignees ? _self._assignees : assignees // ignore: cast_nullable_to_non_nullable
as List<User>,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<Label>,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,subscribed: freezed == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Issue
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
