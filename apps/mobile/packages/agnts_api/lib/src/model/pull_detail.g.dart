// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullDetailCWProxy {
  PullDetail repoId(int repoId);

  PullDetail repoName(String repoName);

  PullDetail provider(PullDetailProviderEnum provider);

  PullDetail pull(PullItem pull);

  PullDetail body(String? body);

  PullDetail login(String? login);

  PullDetail files(List<FileChange> files);

  PullDetail filesError(String? filesError);

  PullDetail ticketKey(String? ticketKey);

  PullDetail own(bool own);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  PullDetail call({
    int repoId,
    String repoName,
    PullDetailProviderEnum provider,
    PullItem pull,
    String? body,
    String? login,
    List<FileChange> files,
    String? filesError,
    String? ticketKey,
    bool own,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullDetail.copyWith.fieldName(...)`
class _$PullDetailCWProxyImpl implements _$PullDetailCWProxy {
  const _$PullDetailCWProxyImpl(this._value);

  final PullDetail _value;

  @override
  PullDetail repoId(int repoId) => this(repoId: repoId);

  @override
  PullDetail repoName(String repoName) => this(repoName: repoName);

  @override
  PullDetail provider(PullDetailProviderEnum provider) =>
      this(provider: provider);

  @override
  PullDetail pull(PullItem pull) => this(pull: pull);

  @override
  PullDetail body(String? body) => this(body: body);

  @override
  PullDetail login(String? login) => this(login: login);

  @override
  PullDetail files(List<FileChange> files) => this(files: files);

  @override
  PullDetail filesError(String? filesError) => this(filesError: filesError);

  @override
  PullDetail ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  PullDetail own(bool own) => this(own: own);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  PullDetail call({
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? pull = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? login = const $CopyWithPlaceholder(),
    Object? files = const $CopyWithPlaceholder(),
    Object? filesError = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? own = const $CopyWithPlaceholder(),
  }) {
    return PullDetail(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as PullDetailProviderEnum,
      pull: pull == const $CopyWithPlaceholder()
          ? _value.pull
          // ignore: cast_nullable_to_non_nullable
          : pull as PullItem,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String?,
      login: login == const $CopyWithPlaceholder()
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as String?,
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<FileChange>,
      filesError: filesError == const $CopyWithPlaceholder()
          ? _value.filesError
          // ignore: cast_nullable_to_non_nullable
          : filesError as String?,
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

extension $PullDetailCopyWith on PullDetail {
  /// Returns a callable class that can be used as follows: `instanceOfPullDetail.copyWith(...)` or like so:`instanceOfPullDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullDetailCWProxy get copyWith => _$PullDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullDetail _$PullDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PullDetail', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'repoId',
          'repoName',
          'provider',
          'pull',
          'files',
          'own',
        ],
      );
      final val = PullDetail(
        repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
        repoName: $checkedConvert('repoName', (v) => v as String),
        provider: $checkedConvert(
          'provider',
          (v) => $enumDecode(_$PullDetailProviderEnumEnumMap, v),
        ),
        pull: $checkedConvert(
          'pull',
          (v) => PullItem.fromJson(v as Map<String, dynamic>),
        ),
        body: $checkedConvert('body', (v) => v as String?),
        login: $checkedConvert('login', (v) => v as String?),
        files: $checkedConvert(
          'files',
          (v) => (v as List<dynamic>)
              .map((e) => FileChange.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        filesError: $checkedConvert('filesError', (v) => v as String?),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
        own: $checkedConvert('own', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$PullDetailToJson(PullDetail instance) =>
    <String, dynamic>{
      'repoId': instance.repoId,
      'repoName': instance.repoName,
      'provider': _$PullDetailProviderEnumEnumMap[instance.provider]!,
      'pull': instance.pull.toJson(),
      'body': ?instance.body,
      'login': ?instance.login,
      'files': instance.files.map((e) => e.toJson()).toList(),
      'filesError': ?instance.filesError,
      'ticketKey': ?instance.ticketKey,
      'own': instance.own,
    };

const _$PullDetailProviderEnumEnumMap = {
  PullDetailProviderEnum.github: 'github',
  PullDetailProviderEnum.gitlab: 'gitlab',
};
