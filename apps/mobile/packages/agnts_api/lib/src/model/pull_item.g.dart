// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullItemCWProxy {
  PullItem number(int number);

  PullItem url(String url);

  PullItem title(String title);

  PullItem author(String author);

  PullItem headRef(String headRef);

  PullItem headSha(String headSha);

  PullItem baseRef(String baseRef);

  PullItem draft(bool draft);

  PullItem state(PullItemStateEnum state);

  PullItem why(String why);

  PullItem updatedAt(DateTime updatedAt);

  PullItem ticketKey(String? ticketKey);

  PullItem own(bool own);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullItem(...).copyWith(id: 12, name: "My name")
  /// ````
  PullItem call({
    int number,
    String url,
    String title,
    String author,
    String headRef,
    String headSha,
    String baseRef,
    bool draft,
    PullItemStateEnum state,
    String why,
    DateTime updatedAt,
    String? ticketKey,
    bool own,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullItem.copyWith.fieldName(...)`
class _$PullItemCWProxyImpl implements _$PullItemCWProxy {
  const _$PullItemCWProxyImpl(this._value);

  final PullItem _value;

  @override
  PullItem number(int number) => this(number: number);

  @override
  PullItem url(String url) => this(url: url);

  @override
  PullItem title(String title) => this(title: title);

  @override
  PullItem author(String author) => this(author: author);

  @override
  PullItem headRef(String headRef) => this(headRef: headRef);

  @override
  PullItem headSha(String headSha) => this(headSha: headSha);

  @override
  PullItem baseRef(String baseRef) => this(baseRef: baseRef);

  @override
  PullItem draft(bool draft) => this(draft: draft);

  @override
  PullItem state(PullItemStateEnum state) => this(state: state);

  @override
  PullItem why(String why) => this(why: why);

  @override
  PullItem updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  PullItem ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  PullItem own(bool own) => this(own: own);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullItem(...).copyWith(id: 12, name: "My name")
  /// ````
  PullItem call({
    Object? number = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? headRef = const $CopyWithPlaceholder(),
    Object? headSha = const $CopyWithPlaceholder(),
    Object? baseRef = const $CopyWithPlaceholder(),
    Object? draft = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? why = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? own = const $CopyWithPlaceholder(),
  }) {
    return PullItem(
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as int,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      author: author == const $CopyWithPlaceholder()
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      headRef: headRef == const $CopyWithPlaceholder()
          ? _value.headRef
          // ignore: cast_nullable_to_non_nullable
          : headRef as String,
      headSha: headSha == const $CopyWithPlaceholder()
          ? _value.headSha
          // ignore: cast_nullable_to_non_nullable
          : headSha as String,
      baseRef: baseRef == const $CopyWithPlaceholder()
          ? _value.baseRef
          // ignore: cast_nullable_to_non_nullable
          : baseRef as String,
      draft: draft == const $CopyWithPlaceholder()
          ? _value.draft
          // ignore: cast_nullable_to_non_nullable
          : draft as bool,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as PullItemStateEnum,
      why: why == const $CopyWithPlaceholder()
          ? _value.why
          // ignore: cast_nullable_to_non_nullable
          : why as String,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
      own: own == const $CopyWithPlaceholder()
          ? _value.own
          // ignore: cast_nullable_to_non_nullable
          : own as bool,
    );
  }
}

extension $PullItemCopyWith on PullItem {
  /// Returns a callable class that can be used as follows: `instanceOfPullItem.copyWith(...)` or like so:`instanceOfPullItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullItemCWProxy get copyWith => _$PullItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullItem _$PullItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PullItem', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'number',
          'url',
          'title',
          'author',
          'headRef',
          'headSha',
          'baseRef',
          'draft',
          'state',
          'why',
          'updatedAt',
          'own',
        ],
      );
      final val = PullItem(
        number: $checkedConvert('number', (v) => (v as num).toInt()),
        url: $checkedConvert('url', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        author: $checkedConvert('author', (v) => v as String),
        headRef: $checkedConvert('headRef', (v) => v as String),
        headSha: $checkedConvert('headSha', (v) => v as String),
        baseRef: $checkedConvert('baseRef', (v) => v as String),
        draft: $checkedConvert('draft', (v) => v as bool),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$PullItemStateEnumEnumMap, v),
        ),
        why: $checkedConvert('why', (v) => v as String),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => DateTime.parse(v as String),
        ),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
        own: $checkedConvert('own', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$PullItemToJson(PullItem instance) => <String, dynamic>{
  'number': instance.number,
  'url': instance.url,
  'title': instance.title,
  'author': instance.author,
  'headRef': instance.headRef,
  'headSha': instance.headSha,
  'baseRef': instance.baseRef,
  'draft': instance.draft,
  'state': _$PullItemStateEnumEnumMap[instance.state]!,
  'why': instance.why,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'ticketKey': ?instance.ticketKey,
  'own': instance.own,
};

const _$PullItemStateEnumEnumMap = {
  PullItemStateEnum.open: 'open',
  PullItemStateEnum.closed: 'closed',
  PullItemStateEnum.merged: 'merged',
};
