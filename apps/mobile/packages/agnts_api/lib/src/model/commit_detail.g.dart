// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommitDetailCWProxy {
  CommitDetail sha(String sha);

  CommitDetail message(String message);

  CommitDetail author(String author);

  CommitDetail authorEmail(String? authorEmail);

  CommitDetail authorLogin(String? authorLogin);

  CommitDetail authorAvatar(String? authorAvatar);

  CommitDetail date(DateTime? date);

  CommitDetail committer(String? committer);

  CommitDetail committerEmail(String? committerEmail);

  CommitDetail committedDate(DateTime? committedDate);

  CommitDetail parents(List<String> parents);

  CommitDetail url(String url);

  CommitDetail add(int add);

  CommitDetail del(int del);

  CommitDetail files(List<FileChange> files);

  CommitDetail filesCapped(bool? filesCapped);

  CommitDetail pipelines(List<Pipeline> pipelines);

  CommitDetail pulls(List<CommitPull> pulls);

  CommitDetail ticketKey(String? ticketKey);

  CommitDetail provider(CommitDetailProviderEnum provider);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitDetail call({
    String sha,
    String message,
    String author,
    String? authorEmail,
    String? authorLogin,
    String? authorAvatar,
    DateTime? date,
    String? committer,
    String? committerEmail,
    DateTime? committedDate,
    List<String> parents,
    String url,
    int add,
    int del,
    List<FileChange> files,
    bool? filesCapped,
    List<Pipeline> pipelines,
    List<CommitPull> pulls,
    String? ticketKey,
    CommitDetailProviderEnum provider,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommitDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommitDetail.copyWith.fieldName(...)`
class _$CommitDetailCWProxyImpl implements _$CommitDetailCWProxy {
  const _$CommitDetailCWProxyImpl(this._value);

  final CommitDetail _value;

  @override
  CommitDetail sha(String sha) => this(sha: sha);

  @override
  CommitDetail message(String message) => this(message: message);

  @override
  CommitDetail author(String author) => this(author: author);

  @override
  CommitDetail authorEmail(String? authorEmail) =>
      this(authorEmail: authorEmail);

  @override
  CommitDetail authorLogin(String? authorLogin) =>
      this(authorLogin: authorLogin);

  @override
  CommitDetail authorAvatar(String? authorAvatar) =>
      this(authorAvatar: authorAvatar);

  @override
  CommitDetail date(DateTime? date) => this(date: date);

  @override
  CommitDetail committer(String? committer) => this(committer: committer);

  @override
  CommitDetail committerEmail(String? committerEmail) =>
      this(committerEmail: committerEmail);

  @override
  CommitDetail committedDate(DateTime? committedDate) =>
      this(committedDate: committedDate);

  @override
  CommitDetail parents(List<String> parents) => this(parents: parents);

  @override
  CommitDetail url(String url) => this(url: url);

  @override
  CommitDetail add(int add) => this(add: add);

  @override
  CommitDetail del(int del) => this(del: del);

  @override
  CommitDetail files(List<FileChange> files) => this(files: files);

  @override
  CommitDetail filesCapped(bool? filesCapped) => this(filesCapped: filesCapped);

  @override
  CommitDetail pipelines(List<Pipeline> pipelines) =>
      this(pipelines: pipelines);

  @override
  CommitDetail pulls(List<CommitPull> pulls) => this(pulls: pulls);

  @override
  CommitDetail ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  CommitDetail provider(CommitDetailProviderEnum provider) =>
      this(provider: provider);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitDetail call({
    Object? sha = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? authorEmail = const $CopyWithPlaceholder(),
    Object? authorLogin = const $CopyWithPlaceholder(),
    Object? authorAvatar = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? committer = const $CopyWithPlaceholder(),
    Object? committerEmail = const $CopyWithPlaceholder(),
    Object? committedDate = const $CopyWithPlaceholder(),
    Object? parents = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? add = const $CopyWithPlaceholder(),
    Object? del = const $CopyWithPlaceholder(),
    Object? files = const $CopyWithPlaceholder(),
    Object? filesCapped = const $CopyWithPlaceholder(),
    Object? pipelines = const $CopyWithPlaceholder(),
    Object? pulls = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
  }) {
    return CommitDetail(
      sha: sha == const $CopyWithPlaceholder()
          ? _value.sha
          // ignore: cast_nullable_to_non_nullable
          : sha as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      author: author == const $CopyWithPlaceholder()
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      authorEmail: authorEmail == const $CopyWithPlaceholder()
          ? _value.authorEmail
          // ignore: cast_nullable_to_non_nullable
          : authorEmail as String?,
      authorLogin: authorLogin == const $CopyWithPlaceholder()
          ? _value.authorLogin
          // ignore: cast_nullable_to_non_nullable
          : authorLogin as String?,
      authorAvatar: authorAvatar == const $CopyWithPlaceholder()
          ? _value.authorAvatar
          // ignore: cast_nullable_to_non_nullable
          : authorAvatar as String?,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime?,
      committer: committer == const $CopyWithPlaceholder()
          ? _value.committer
          // ignore: cast_nullable_to_non_nullable
          : committer as String?,
      committerEmail: committerEmail == const $CopyWithPlaceholder()
          ? _value.committerEmail
          // ignore: cast_nullable_to_non_nullable
          : committerEmail as String?,
      committedDate: committedDate == const $CopyWithPlaceholder()
          ? _value.committedDate
          // ignore: cast_nullable_to_non_nullable
          : committedDate as DateTime?,
      parents: parents == const $CopyWithPlaceholder()
          ? _value.parents
          // ignore: cast_nullable_to_non_nullable
          : parents as List<String>,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      add: add == const $CopyWithPlaceholder()
          ? _value.add
          // ignore: cast_nullable_to_non_nullable
          : add as int,
      del: del == const $CopyWithPlaceholder()
          ? _value.del
          // ignore: cast_nullable_to_non_nullable
          : del as int,
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<FileChange>,
      filesCapped: filesCapped == const $CopyWithPlaceholder()
          ? _value.filesCapped
          // ignore: cast_nullable_to_non_nullable
          : filesCapped as bool?,
      pipelines: pipelines == const $CopyWithPlaceholder()
          ? _value.pipelines
          // ignore: cast_nullable_to_non_nullable
          : pipelines as List<Pipeline>,
      pulls: pulls == const $CopyWithPlaceholder()
          ? _value.pulls
          // ignore: cast_nullable_to_non_nullable
          : pulls as List<CommitPull>,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as CommitDetailProviderEnum,
    );
  }
}

extension $CommitDetailCopyWith on CommitDetail {
  /// Returns a callable class that can be used as follows: `instanceOfCommitDetail.copyWith(...)` or like so:`instanceOfCommitDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommitDetailCWProxy get copyWith => _$CommitDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitDetail _$CommitDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CommitDetail', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'sha',
          'message',
          'author',
          'parents',
          'url',
          'add',
          'del',
          'files',
          'pipelines',
          'pulls',
          'provider',
        ],
      );
      final val = CommitDetail(
        sha: $checkedConvert('sha', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        author: $checkedConvert('author', (v) => v as String),
        authorEmail: $checkedConvert('authorEmail', (v) => v as String?),
        authorLogin: $checkedConvert('authorLogin', (v) => v as String?),
        authorAvatar: $checkedConvert('authorAvatar', (v) => v as String?),
        date: $checkedConvert(
          'date',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        committer: $checkedConvert('committer', (v) => v as String?),
        committerEmail: $checkedConvert('committerEmail', (v) => v as String?),
        committedDate: $checkedConvert(
          'committedDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        parents: $checkedConvert(
          'parents',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        url: $checkedConvert('url', (v) => v as String),
        add: $checkedConvert('add', (v) => (v as num).toInt()),
        del: $checkedConvert('del', (v) => (v as num).toInt()),
        files: $checkedConvert(
          'files',
          (v) => (v as List<dynamic>)
              .map((e) => FileChange.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        filesCapped: $checkedConvert('filesCapped', (v) => v as bool?),
        pipelines: $checkedConvert(
          'pipelines',
          (v) => (v as List<dynamic>)
              .map((e) => Pipeline.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        pulls: $checkedConvert(
          'pulls',
          (v) => (v as List<dynamic>)
              .map((e) => CommitPull.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
        provider: $checkedConvert(
          'provider',
          (v) => $enumDecode(_$CommitDetailProviderEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CommitDetailToJson(CommitDetail instance) =>
    <String, dynamic>{
      'sha': instance.sha,
      'message': instance.message,
      'author': instance.author,
      'authorEmail': ?instance.authorEmail,
      'authorLogin': ?instance.authorLogin,
      'authorAvatar': ?instance.authorAvatar,
      'date': ?instance.date?.toIso8601String(),
      'committer': ?instance.committer,
      'committerEmail': ?instance.committerEmail,
      'committedDate': ?instance.committedDate?.toIso8601String(),
      'parents': instance.parents,
      'url': instance.url,
      'add': instance.add,
      'del': instance.del,
      'files': instance.files.map((e) => e.toJson()).toList(),
      'filesCapped': ?instance.filesCapped,
      'pipelines': instance.pipelines.map((e) => e.toJson()).toList(),
      'pulls': instance.pulls.map((e) => e.toJson()).toList(),
      'ticketKey': ?instance.ticketKey,
      'provider': _$CommitDetailProviderEnumEnumMap[instance.provider]!,
    };

const _$CommitDetailProviderEnumEnumMap = {
  CommitDetailProviderEnum.github: 'github',
  CommitDetailProviderEnum.gitlab: 'gitlab',
};
