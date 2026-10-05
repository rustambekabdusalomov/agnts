// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_brief.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LessonBriefCWProxy {
  LessonBrief id(int id);

  LessonBrief repoId(int repoId);

  LessonBrief repoName(String repoName);

  LessonBrief ticketKey(String ticketKey);

  LessonBrief slug(String slug);

  LessonBrief title(String title);

  LessonBrief category(LessonCategory category);

  LessonBrief level(LessonLevel level);

  LessonBrief summary(String summary);

  LessonBrief quizCount(int quizCount);

  LessonBrief readMinutes(int readMinutes);

  LessonBrief learnedAt(DateTime? learnedAt);

  LessonBrief createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LessonBrief(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LessonBrief(...).copyWith(id: 12, name: "My name")
  /// ````
  LessonBrief call({
    int id,
    int repoId,
    String repoName,
    String ticketKey,
    String slug,
    String title,
    LessonCategory category,
    LessonLevel level,
    String summary,
    int quizCount,
    int readMinutes,
    DateTime? learnedAt,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLessonBrief.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLessonBrief.copyWith.fieldName(...)`
class _$LessonBriefCWProxyImpl implements _$LessonBriefCWProxy {
  const _$LessonBriefCWProxyImpl(this._value);

  final LessonBrief _value;

  @override
  LessonBrief id(int id) => this(id: id);

  @override
  LessonBrief repoId(int repoId) => this(repoId: repoId);

  @override
  LessonBrief repoName(String repoName) => this(repoName: repoName);

  @override
  LessonBrief ticketKey(String ticketKey) => this(ticketKey: ticketKey);

  @override
  LessonBrief slug(String slug) => this(slug: slug);

  @override
  LessonBrief title(String title) => this(title: title);

  @override
  LessonBrief category(LessonCategory category) => this(category: category);

  @override
  LessonBrief level(LessonLevel level) => this(level: level);

  @override
  LessonBrief summary(String summary) => this(summary: summary);

  @override
  LessonBrief quizCount(int quizCount) => this(quizCount: quizCount);

  @override
  LessonBrief readMinutes(int readMinutes) => this(readMinutes: readMinutes);

  @override
  LessonBrief learnedAt(DateTime? learnedAt) => this(learnedAt: learnedAt);

  @override
  LessonBrief createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LessonBrief(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LessonBrief(...).copyWith(id: 12, name: "My name")
  /// ````
  LessonBrief call({
    Object? id = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? level = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? quizCount = const $CopyWithPlaceholder(),
    Object? readMinutes = const $CopyWithPlaceholder(),
    Object? learnedAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return LessonBrief(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String,
      slug: slug == const $CopyWithPlaceholder()
          ? _value.slug
          // ignore: cast_nullable_to_non_nullable
          : slug as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as LessonCategory,
      level: level == const $CopyWithPlaceholder()
          ? _value.level
          // ignore: cast_nullable_to_non_nullable
          : level as LessonLevel,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String,
      quizCount: quizCount == const $CopyWithPlaceholder()
          ? _value.quizCount
          // ignore: cast_nullable_to_non_nullable
          : quizCount as int,
      readMinutes: readMinutes == const $CopyWithPlaceholder()
          ? _value.readMinutes
          // ignore: cast_nullable_to_non_nullable
          : readMinutes as int,
      learnedAt: learnedAt == const $CopyWithPlaceholder()
          ? _value.learnedAt
          // ignore: cast_nullable_to_non_nullable
          : learnedAt as DateTime?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $LessonBriefCopyWith on LessonBrief {
  /// Returns a callable class that can be used as follows: `instanceOfLessonBrief.copyWith(...)` or like so:`instanceOfLessonBrief.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LessonBriefCWProxy get copyWith => _$LessonBriefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonBrief _$LessonBriefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LessonBrief', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'repoId',
          'repoName',
          'ticketKey',
          'slug',
          'title',
          'category',
          'level',
          'summary',
          'quizCount',
          'readMinutes',
          'createdAt',
        ],
      );
      final val = LessonBrief(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
        repoName: $checkedConvert('repoName', (v) => v as String),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String),
        slug: $checkedConvert('slug', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        category: $checkedConvert(
          'category',
          (v) => $enumDecode(_$LessonCategoryEnumMap, v),
        ),
        level: $checkedConvert(
          'level',
          (v) => $enumDecode(_$LessonLevelEnumMap, v),
        ),
        summary: $checkedConvert('summary', (v) => v as String),
        quizCount: $checkedConvert('quizCount', (v) => (v as num).toInt()),
        readMinutes: $checkedConvert('readMinutes', (v) => (v as num).toInt()),
        learnedAt: $checkedConvert(
          'learnedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LessonBriefToJson(LessonBrief instance) =>
    <String, dynamic>{
      'id': instance.id,
      'repoId': instance.repoId,
      'repoName': instance.repoName,
      'ticketKey': instance.ticketKey,
      'slug': instance.slug,
      'title': instance.title,
      'category': _$LessonCategoryEnumMap[instance.category]!,
      'level': _$LessonLevelEnumMap[instance.level]!,
      'summary': instance.summary,
      'quizCount': instance.quizCount,
      'readMinutes': instance.readMinutes,
      'learnedAt': ?instance.learnedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$LessonCategoryEnumMap = {
  LessonCategory.pattern: 'pattern',
  LessonCategory.architecture: 'architecture',
  LessonCategory.algorithm: 'algorithm',
  LessonCategory.library_: 'library',
  LessonCategory.language: 'language',
  LessonCategory.testing: 'testing',
  LessonCategory.security: 'security',
  LessonCategory.performance: 'performance',
  LessonCategory.tooling: 'tooling',
  LessonCategory.other: 'other',
};

const _$LessonLevelEnumMap = {
  LessonLevel.beginner: 'beginner',
  LessonLevel.intermediate: 'intermediate',
  LessonLevel.advanced: 'advanced',
};
