// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_comment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullCommentCWProxy {
  PullComment id(String id);

  PullComment author(String author);

  PullComment avatarUrl(String? avatarUrl);

  PullComment body(String body);

  PullComment createdAt(DateTime createdAt);

  PullComment updatedAt(DateTime updatedAt);

  PullComment url(String? url);

  PullComment mine(bool mine);

  PullComment system(bool system);

  PullComment agnts(bool agnts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullComment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullComment(...).copyWith(id: 12, name: "My name")
  /// ````
  PullComment call({
    String id,
    String author,
    String? avatarUrl,
    String body,
    DateTime createdAt,
    DateTime updatedAt,
    String? url,
    bool mine,
    bool system,
    bool agnts,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullComment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullComment.copyWith.fieldName(...)`
class _$PullCommentCWProxyImpl implements _$PullCommentCWProxy {
  const _$PullCommentCWProxyImpl(this._value);

  final PullComment _value;

  @override
  PullComment id(String id) => this(id: id);

  @override
  PullComment author(String author) => this(author: author);

  @override
  PullComment avatarUrl(String? avatarUrl) => this(avatarUrl: avatarUrl);

  @override
  PullComment body(String body) => this(body: body);

  @override
  PullComment createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  PullComment updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  PullComment url(String? url) => this(url: url);

  @override
  PullComment mine(bool mine) => this(mine: mine);

  @override
  PullComment system(bool system) => this(system: system);

  @override
  PullComment agnts(bool agnts) => this(agnts: agnts);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullComment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullComment(...).copyWith(id: 12, name: "My name")
  /// ````
  PullComment call({
    Object? id = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? avatarUrl = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? mine = const $CopyWithPlaceholder(),
    Object? system = const $CopyWithPlaceholder(),
    Object? agnts = const $CopyWithPlaceholder(),
  }) {
    return PullComment(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      author: author == const $CopyWithPlaceholder()
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      avatarUrl: avatarUrl == const $CopyWithPlaceholder()
          ? _value.avatarUrl
          // ignore: cast_nullable_to_non_nullable
          : avatarUrl as String?,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      mine: mine == const $CopyWithPlaceholder()
          ? _value.mine
          // ignore: cast_nullable_to_non_nullable
          : mine as bool,
      system: system == const $CopyWithPlaceholder()
          ? _value.system
          // ignore: cast_nullable_to_non_nullable
          : system as bool,
      agnts: agnts == const $CopyWithPlaceholder()
          ? _value.agnts
          // ignore: cast_nullable_to_non_nullable
          : agnts as bool,
    );
  }
}

extension $PullCommentCopyWith on PullComment {
  /// Returns a callable class that can be used as follows: `instanceOfPullComment.copyWith(...)` or like so:`instanceOfPullComment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullCommentCWProxy get copyWith => _$PullCommentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullComment _$PullCommentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PullComment', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'author',
      'body',
      'createdAt',
      'updatedAt',
      'mine',
      'system',
      'agnts',
    ],
  );
  final val = PullComment(
    id: $checkedConvert('id', (v) => v as String),
    author: $checkedConvert('author', (v) => v as String),
    avatarUrl: $checkedConvert('avatarUrl', (v) => v as String?),
    body: $checkedConvert('body', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    url: $checkedConvert('url', (v) => v as String?),
    mine: $checkedConvert('mine', (v) => v as bool),
    system: $checkedConvert('system', (v) => v as bool),
    agnts: $checkedConvert('agnts', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$PullCommentToJson(PullComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'avatarUrl': ?instance.avatarUrl,
      'body': instance.body,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'url': ?instance.url,
      'mine': instance.mine,
      'system': instance.system,
      'agnts': instance.agnts,
    };
