// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_stats.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatStatsCWProxy {
  ChatStats links(int links);

  ChatStats answers(int answers);

  ChatStats drafts(int drafts);

  ChatStats medianMs(int medianMs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatStats(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatStats(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatStats call({int links, int answers, int drafts, int medianMs});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatStats.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatStats.copyWith.fieldName(...)`
class _$ChatStatsCWProxyImpl implements _$ChatStatsCWProxy {
  const _$ChatStatsCWProxyImpl(this._value);

  final ChatStats _value;

  @override
  ChatStats links(int links) => this(links: links);

  @override
  ChatStats answers(int answers) => this(answers: answers);

  @override
  ChatStats drafts(int drafts) => this(drafts: drafts);

  @override
  ChatStats medianMs(int medianMs) => this(medianMs: medianMs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatStats(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatStats(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatStats call({
    Object? links = const $CopyWithPlaceholder(),
    Object? answers = const $CopyWithPlaceholder(),
    Object? drafts = const $CopyWithPlaceholder(),
    Object? medianMs = const $CopyWithPlaceholder(),
  }) {
    return ChatStats(
      links: links == const $CopyWithPlaceholder()
          ? _value.links
          // ignore: cast_nullable_to_non_nullable
          : links as int,
      answers: answers == const $CopyWithPlaceholder()
          ? _value.answers
          // ignore: cast_nullable_to_non_nullable
          : answers as int,
      drafts: drafts == const $CopyWithPlaceholder()
          ? _value.drafts
          // ignore: cast_nullable_to_non_nullable
          : drafts as int,
      medianMs: medianMs == const $CopyWithPlaceholder()
          ? _value.medianMs
          // ignore: cast_nullable_to_non_nullable
          : medianMs as int,
    );
  }
}

extension $ChatStatsCopyWith on ChatStats {
  /// Returns a callable class that can be used as follows: `instanceOfChatStats.copyWith(...)` or like so:`instanceOfChatStats.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatStatsCWProxy get copyWith => _$ChatStatsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatStats _$ChatStatsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatStats', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['links', 'answers', 'drafts', 'medianMs'],
      );
      final val = ChatStats(
        links: $checkedConvert('links', (v) => (v as num).toInt()),
        answers: $checkedConvert('answers', (v) => (v as num).toInt()),
        drafts: $checkedConvert('drafts', (v) => (v as num).toInt()),
        medianMs: $checkedConvert('medianMs', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ChatStatsToJson(ChatStats instance) => <String, dynamic>{
  'links': instance.links,
  'answers': instance.answers,
  'drafts': instance.drafts,
  'medianMs': instance.medianMs,
};
