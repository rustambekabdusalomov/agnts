// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linked_commit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LinkedCommitCWProxy {
  LinkedCommit sha(String sha);

  LinkedCommit shortSha(String shortSha);

  LinkedCommit subject(String subject);

  LinkedCommit author(String author);

  LinkedCommit authorLogin(String? authorLogin);

  LinkedCommit branch(String branch);

  LinkedCommit repoId(int repoId);

  LinkedCommit repo(String repo);

  LinkedCommit url(String url);

  LinkedCommit committedAt(DateTime committedAt);

  LinkedCommit matchedOn(List<LinkedCommitMatchedOnEnum> matchedOn);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LinkedCommit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LinkedCommit(...).copyWith(id: 12, name: "My name")
  /// ````
  LinkedCommit call({
    String sha,
    String shortSha,
    String subject,
    String author,
    String? authorLogin,
    String branch,
    int repoId,
    String repo,
    String url,
    DateTime committedAt,
    List<LinkedCommitMatchedOnEnum> matchedOn,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLinkedCommit.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLinkedCommit.copyWith.fieldName(...)`
class _$LinkedCommitCWProxyImpl implements _$LinkedCommitCWProxy {
  const _$LinkedCommitCWProxyImpl(this._value);

  final LinkedCommit _value;

  @override
  LinkedCommit sha(String sha) => this(sha: sha);

  @override
  LinkedCommit shortSha(String shortSha) => this(shortSha: shortSha);

  @override
  LinkedCommit subject(String subject) => this(subject: subject);

  @override
  LinkedCommit author(String author) => this(author: author);

  @override
  LinkedCommit authorLogin(String? authorLogin) =>
      this(authorLogin: authorLogin);

  @override
  LinkedCommit branch(String branch) => this(branch: branch);

  @override
  LinkedCommit repoId(int repoId) => this(repoId: repoId);

  @override
  LinkedCommit repo(String repo) => this(repo: repo);

  @override
  LinkedCommit url(String url) => this(url: url);

  @override
  LinkedCommit committedAt(DateTime committedAt) =>
      this(committedAt: committedAt);

  @override
  LinkedCommit matchedOn(List<LinkedCommitMatchedOnEnum> matchedOn) =>
      this(matchedOn: matchedOn);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LinkedCommit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LinkedCommit(...).copyWith(id: 12, name: "My name")
  /// ````
  LinkedCommit call({
    Object? sha = const $CopyWithPlaceholder(),
    Object? shortSha = const $CopyWithPlaceholder(),
    Object? subject = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? authorLogin = const $CopyWithPlaceholder(),
    Object? branch = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repo = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? committedAt = const $CopyWithPlaceholder(),
    Object? matchedOn = const $CopyWithPlaceholder(),
  }) {
    return LinkedCommit(
      sha: sha == const $CopyWithPlaceholder()
          ? _value.sha
          // ignore: cast_nullable_to_non_nullable
          : sha as String,
      shortSha: shortSha == const $CopyWithPlaceholder()
          ? _value.shortSha
          // ignore: cast_nullable_to_non_nullable
          : shortSha as String,
      subject: subject == const $CopyWithPlaceholder()
          ? _value.subject
          // ignore: cast_nullable_to_non_nullable
          : subject as String,
      author: author == const $CopyWithPlaceholder()
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      authorLogin: authorLogin == const $CopyWithPlaceholder()
          ? _value.authorLogin
          // ignore: cast_nullable_to_non_nullable
          : authorLogin as String?,
      branch: branch == const $CopyWithPlaceholder()
          ? _value.branch
          // ignore: cast_nullable_to_non_nullable
          : branch as String,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      repo: repo == const $CopyWithPlaceholder()
          ? _value.repo
          // ignore: cast_nullable_to_non_nullable
          : repo as String,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      committedAt: committedAt == const $CopyWithPlaceholder()
          ? _value.committedAt
          // ignore: cast_nullable_to_non_nullable
          : committedAt as DateTime,
      matchedOn: matchedOn == const $CopyWithPlaceholder()
          ? _value.matchedOn
          // ignore: cast_nullable_to_non_nullable
          : matchedOn as List<LinkedCommitMatchedOnEnum>,
    );
  }
}

extension $LinkedCommitCopyWith on LinkedCommit {
  /// Returns a callable class that can be used as follows: `instanceOfLinkedCommit.copyWith(...)` or like so:`instanceOfLinkedCommit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LinkedCommitCWProxy get copyWith => _$LinkedCommitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkedCommit _$LinkedCommitFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LinkedCommit', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'sha',
          'shortSha',
          'subject',
          'author',
          'branch',
          'repoId',
          'repo',
          'url',
          'committedAt',
          'matchedOn',
        ],
      );
      final val = LinkedCommit(
        sha: $checkedConvert('sha', (v) => v as String),
        shortSha: $checkedConvert('shortSha', (v) => v as String),
        subject: $checkedConvert('subject', (v) => v as String),
        author: $checkedConvert('author', (v) => v as String),
        authorLogin: $checkedConvert('authorLogin', (v) => v as String?),
        branch: $checkedConvert('branch', (v) => v as String),
        repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
        repo: $checkedConvert('repo', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
        committedAt: $checkedConvert(
          'committedAt',
          (v) => DateTime.parse(v as String),
        ),
        matchedOn: $checkedConvert(
          'matchedOn',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$LinkedCommitMatchedOnEnumEnumMap, e))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LinkedCommitToJson(LinkedCommit instance) =>
    <String, dynamic>{
      'sha': instance.sha,
      'shortSha': instance.shortSha,
      'subject': instance.subject,
      'author': instance.author,
      'authorLogin': ?instance.authorLogin,
      'branch': instance.branch,
      'repoId': instance.repoId,
      'repo': instance.repo,
      'url': instance.url,
      'committedAt': instance.committedAt.toIso8601String(),
      'matchedOn': instance.matchedOn
          .map((e) => _$LinkedCommitMatchedOnEnumEnumMap[e]!)
          .toList(),
    };

const _$LinkedCommitMatchedOnEnumEnumMap = {
  LinkedCommitMatchedOnEnum.branch: 'branch',
  LinkedCommitMatchedOnEnum.message: 'message',
};
