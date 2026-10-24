// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WikiPage _$WikiPageFromJson(Map<String, dynamic> json) => _WikiPage(
  title: json['title'] as String,
  slug: json['slug'] as String,
  content: json['content'] as String?,
  format: json['format'] as String?,
);

Map<String, dynamic> _$WikiPageToJson(_WikiPage instance) => <String, dynamic>{
  'title': instance.title,
  'slug': instance.slug,
  'content': instance.content,
  'format': instance.format,
};
