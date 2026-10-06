// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learn_queue_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LearnQueueItemCWProxy {
  LearnQueueItem key(String key);

  LearnQueueItem title(String title);

  LearnQueueItem repoName(String repoName);

  LearnQueueItem status(LearnQueueItemStatusEnum status);

  LearnQueueItem lessons(int lessons);

  LearnQueueItem updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LearnQueueItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LearnQueueItem(...).copyWith(id: 12, name: "My name")
  /// ````
  LearnQueueItem call({
    String key,
    String title,
    String repoName,
    LearnQueueItemStatusEnum status,
    int lessons,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLearnQueueItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLearnQueueItem.copyWith.fieldName(...)`
class _$LearnQueueItemCWProxyImpl implements _$LearnQueueItemCWProxy {
  const _$LearnQueueItemCWProxyImpl(this._value);

  final LearnQueueItem _value;

  @override
  LearnQueueItem key(String key) => this(key: key);

  @override
  LearnQueueItem title(String title) => this(title: title);

  @override
  LearnQueueItem repoName(String repoName) => this(repoName: repoName);

  @override
  LearnQueueItem status(LearnQueueItemStatusEnum status) =>
      this(status: status);

  @override
  LearnQueueItem lessons(int lessons) => this(lessons: lessons);

  @override
  LearnQueueItem updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LearnQueueItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LearnQueueItem(...).copyWith(id: 12, name: "My name")
  /// ````
  LearnQueueItem call({
    Object? key = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? lessons = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return LearnQueueItem(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as LearnQueueItemStatusEnum,
      lessons: lessons == const $CopyWithPlaceholder()
          ? _value.lessons
          // ignore: cast_nullable_to_non_nullable
          : lessons as int,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $LearnQueueItemCopyWith on LearnQueueItem {
  /// Returns a callable class that can be used as follows: `instanceOfLearnQueueItem.copyWith(...)` or like so:`instanceOfLearnQueueItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LearnQueueItemCWProxy get copyWith => _$LearnQueueItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearnQueueItem _$LearnQueueItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LearnQueueItem', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'key',
          'title',
          'repoName',
          'status',
          'lessons',
          'updatedAt',
        ],
      );
      final val = LearnQueueItem(
        key: $checkedConvert('key', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        repoName: $checkedConvert('repoName', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$LearnQueueItemStatusEnumEnumMap, v),
        ),
        lessons: $checkedConvert('lessons', (v) => (v as num).toInt()),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LearnQueueItemToJson(LearnQueueItem instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'repoName': instance.repoName,
      'status': _$LearnQueueItemStatusEnumEnumMap[instance.status]!,
      'lessons': instance.lessons,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$LearnQueueItemStatusEnumEnumMap = {
  LearnQueueItemStatusEnum.running: 'running',
  LearnQueueItemStatusEnum.pending: 'pending',
  LearnQueueItemStatusEnum.failed: 'failed',
  LearnQueueItemStatusEnum.none: 'none',
};
