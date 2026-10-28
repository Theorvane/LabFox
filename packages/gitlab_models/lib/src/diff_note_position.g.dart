// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diff_note_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiffNotePosition _$DiffNotePositionFromJson(Map<String, dynamic> json) =>
    _DiffNotePosition(
      baseSha: json['base_sha'] as String?,
      startSha: json['start_sha'] as String?,
      headSha: json['head_sha'] as String?,
      oldPath: json['old_path'] as String?,
      newPath: json['new_path'] as String?,
      positionType: json['position_type'] as String?,
      oldLine: (json['old_line'] as num?)?.toInt(),
      newLine: (json['new_line'] as num?)?.toInt(),
      lineRange: json['line_range'] == null
          ? null
          : DiffNoteLineRange.fromJson(
              json['line_range'] as Map<String, dynamic>,
            ),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DiffNotePositionToJson(_DiffNotePosition instance) =>
    <String, dynamic>{
      'base_sha': instance.baseSha,
      'start_sha': instance.startSha,
      'head_sha': instance.headSha,
      'old_path': instance.oldPath,
      'new_path': instance.newPath,
      'position_type': instance.positionType,
      'old_line': instance.oldLine,
      'new_line': instance.newLine,
      'line_range': instance.lineRange?.toJson(),
      'width': instance.width,
      'height': instance.height,
      'x': instance.x,
      'y': instance.y,
    };

_DiffNoteLineRange _$DiffNoteLineRangeFromJson(Map<String, dynamic> json) =>
    _DiffNoteLineRange(
      start: json['start'] == null
          ? null
          : DiffNoteRangeEndpoint.fromJson(
              json['start'] as Map<String, dynamic>,
            ),
      end: json['end'] == null
          ? null
          : DiffNoteRangeEndpoint.fromJson(json['end'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DiffNoteLineRangeToJson(_DiffNoteLineRange instance) =>
    <String, dynamic>{
      'start': instance.start?.toJson(),
      'end': instance.end?.toJson(),
    };

_DiffNoteRangeEndpoint _$DiffNoteRangeEndpointFromJson(
  Map<String, dynamic> json,
) => _DiffNoteRangeEndpoint(
  lineCode: json['line_code'] as String?,
  type: json['type'] as String?,
  oldLine: (json['old_line'] as num?)?.toInt(),
  newLine: (json['new_line'] as num?)?.toInt(),
);

Map<String, dynamic> _$DiffNoteRangeEndpointToJson(
  _DiffNoteRangeEndpoint instance,
) => <String, dynamic>{
  'line_code': instance.lineCode,
  'type': instance.type,
  'old_line': instance.oldLine,
  'new_line': instance.newLine,
};
