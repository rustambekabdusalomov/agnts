// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stale_pr.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StalePRCWProxy {
  StalePR key(String key);

  StalePR title(String title);

  StalePR repo(String repo);

  StalePR url(String url);

  StalePR openedAt(DateTime openedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StalePR(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StalePR(...).copyWith(id: 12, name: "My name")
  /// ````
  StalePR call({
    String key,
    String title,
    String repo,
    String url,
    DateTime openedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStalePR.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStalePR.copyWith.fieldName(...)`
class _$StalePRCWProxyImpl implements _$StalePRCWProxy {
  const _$StalePRCWProxyImpl(this._value);

  final StalePR _value;

  @override
  StalePR key(String key) => this(key: key);

  @override
  StalePR title(String title) => this(title: title);

  @override
  StalePR repo(String repo) => this(repo: repo);

  @override
  StalePR url(String url) => this(url: url);

  @override
  StalePR openedAt(DateTime openedAt) => this(openedAt: openedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StalePR(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StalePR(...).copyWith(id: 12, name: "My name")
  /// ````
  StalePR call({
    Object? key = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? repo = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? openedAt = const $CopyWithPlaceholder(),
  }) {
    return StalePR(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      repo: repo == const $CopyWithPlaceholder()
          ? _value.repo
          // ignore: cast_nullable_to_non_nullable
          : repo as String,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      openedAt: openedAt == const $CopyWithPlaceholder()
          ? _value.openedAt
          // ignore: cast_nullable_to_non_nullable
          : openedAt as DateTime,
    );
  }
}

extension $StalePRCopyWith on StalePR {
  /// Returns a callable class that can be used as follows: `instanceOfStalePR.copyWith(...)` or like so:`instanceOfStalePR.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StalePRCWProxy get copyWith => _$StalePRCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StalePR _$StalePRFromJson(Map<String, dynamic> json) => $checkedCreate(
  'StalePR',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['key', 'title', 'repo', 'url', 'openedAt'],
    );
    final val = StalePR(
      key: $checkedConvert('key', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      repo: $checkedConvert('repo', (v) => v as String),
      url: $checkedConvert('url', (v) => v as String),
      openedAt: $checkedConvert('openedAt', (v) => DateTime.parse(v as String)),
    );
    return val;
  },
);

Map<String, dynamic> _$StalePRToJson(StalePR instance) => <String, dynamic>{
  'key': instance.key,
  'title': instance.title,
  'repo': instance.repo,
  'url': instance.url,
  'openedAt': instance.openedAt.toIso8601String(),
};
