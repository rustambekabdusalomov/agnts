// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'git_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GitSettingsCWProxy {
  GitSettings authorName(String authorName);

  GitSettings authorEmail(String authorEmail);

  GitSettings coAuthor(bool coAuthor);

  GitSettings prTitle(String prTitle);

  GitSettings draft(bool draft);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GitSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GitSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  GitSettings call({
    String authorName,
    String authorEmail,
    bool coAuthor,
    String prTitle,
    bool draft,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGitSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGitSettings.copyWith.fieldName(...)`
class _$GitSettingsCWProxyImpl implements _$GitSettingsCWProxy {
  const _$GitSettingsCWProxyImpl(this._value);

  final GitSettings _value;

  @override
  GitSettings authorName(String authorName) => this(authorName: authorName);

  @override
  GitSettings authorEmail(String authorEmail) => this(authorEmail: authorEmail);

  @override
  GitSettings coAuthor(bool coAuthor) => this(coAuthor: coAuthor);

  @override
  GitSettings prTitle(String prTitle) => this(prTitle: prTitle);

  @override
  GitSettings draft(bool draft) => this(draft: draft);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GitSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GitSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  GitSettings call({
    Object? authorName = const $CopyWithPlaceholder(),
    Object? authorEmail = const $CopyWithPlaceholder(),
    Object? coAuthor = const $CopyWithPlaceholder(),
    Object? prTitle = const $CopyWithPlaceholder(),
    Object? draft = const $CopyWithPlaceholder(),
  }) {
    return GitSettings(
      authorName: authorName == const $CopyWithPlaceholder()
          ? _value.authorName
          // ignore: cast_nullable_to_non_nullable
          : authorName as String,
      authorEmail: authorEmail == const $CopyWithPlaceholder()
          ? _value.authorEmail
          // ignore: cast_nullable_to_non_nullable
          : authorEmail as String,
      coAuthor: coAuthor == const $CopyWithPlaceholder()
          ? _value.coAuthor
          // ignore: cast_nullable_to_non_nullable
          : coAuthor as bool,
      prTitle: prTitle == const $CopyWithPlaceholder()
          ? _value.prTitle
          // ignore: cast_nullable_to_non_nullable
          : prTitle as String,
      draft: draft == const $CopyWithPlaceholder()
          ? _value.draft
          // ignore: cast_nullable_to_non_nullable
          : draft as bool,
    );
  }
}

extension $GitSettingsCopyWith on GitSettings {
  /// Returns a callable class that can be used as follows: `instanceOfGitSettings.copyWith(...)` or like so:`instanceOfGitSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GitSettingsCWProxy get copyWith => _$GitSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GitSettings _$GitSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GitSettings', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'authorName',
          'authorEmail',
          'coAuthor',
          'prTitle',
          'draft',
        ],
      );
      final val = GitSettings(
        authorName: $checkedConvert('authorName', (v) => v as String),
        authorEmail: $checkedConvert('authorEmail', (v) => v as String),
        coAuthor: $checkedConvert('coAuthor', (v) => v as bool),
        prTitle: $checkedConvert('prTitle', (v) => v as String),
        draft: $checkedConvert('draft', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$GitSettingsToJson(GitSettings instance) =>
    <String, dynamic>{
      'authorName': instance.authorName,
      'authorEmail': instance.authorEmail,
      'coAuthor': instance.coAuthor,
      'prTitle': instance.prTitle,
      'draft': instance.draft,
    };
