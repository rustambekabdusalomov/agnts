// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pr_comment_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PRCommentSettingsCWProxy {
  PRCommentSettings attribution(bool attribution);

  PRCommentSettings learnFromComments(bool learnFromComments);

  PRCommentSettings resolveFixed(bool resolveFixed);

  PRCommentSettings autoAddress(bool autoAddress);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PRCommentSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PRCommentSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  PRCommentSettings call({
    bool attribution,
    bool learnFromComments,
    bool resolveFixed,
    bool autoAddress,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPRCommentSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPRCommentSettings.copyWith.fieldName(...)`
class _$PRCommentSettingsCWProxyImpl implements _$PRCommentSettingsCWProxy {
  const _$PRCommentSettingsCWProxyImpl(this._value);

  final PRCommentSettings _value;

  @override
  PRCommentSettings attribution(bool attribution) =>
      this(attribution: attribution);

  @override
  PRCommentSettings learnFromComments(bool learnFromComments) =>
      this(learnFromComments: learnFromComments);

  @override
  PRCommentSettings resolveFixed(bool resolveFixed) =>
      this(resolveFixed: resolveFixed);

  @override
  PRCommentSettings autoAddress(bool autoAddress) =>
      this(autoAddress: autoAddress);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PRCommentSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PRCommentSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  PRCommentSettings call({
    Object? attribution = const $CopyWithPlaceholder(),
    Object? learnFromComments = const $CopyWithPlaceholder(),
    Object? resolveFixed = const $CopyWithPlaceholder(),
    Object? autoAddress = const $CopyWithPlaceholder(),
  }) {
    return PRCommentSettings(
      attribution: attribution == const $CopyWithPlaceholder()
          ? _value.attribution
          // ignore: cast_nullable_to_non_nullable
          : attribution as bool,
      learnFromComments: learnFromComments == const $CopyWithPlaceholder()
          ? _value.learnFromComments
          // ignore: cast_nullable_to_non_nullable
          : learnFromComments as bool,
      resolveFixed: resolveFixed == const $CopyWithPlaceholder()
          ? _value.resolveFixed
          // ignore: cast_nullable_to_non_nullable
          : resolveFixed as bool,
      autoAddress: autoAddress == const $CopyWithPlaceholder()
          ? _value.autoAddress
          // ignore: cast_nullable_to_non_nullable
          : autoAddress as bool,
    );
  }
}

extension $PRCommentSettingsCopyWith on PRCommentSettings {
  /// Returns a callable class that can be used as follows: `instanceOfPRCommentSettings.copyWith(...)` or like so:`instanceOfPRCommentSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PRCommentSettingsCWProxy get copyWith =>
      _$PRCommentSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PRCommentSettings _$PRCommentSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PRCommentSettings', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'attribution',
          'learnFromComments',
          'resolveFixed',
          'autoAddress',
        ],
      );
      final val = PRCommentSettings(
        attribution: $checkedConvert('attribution', (v) => v as bool),
        learnFromComments: $checkedConvert(
          'learnFromComments',
          (v) => v as bool,
        ),
        resolveFixed: $checkedConvert('resolveFixed', (v) => v as bool),
        autoAddress: $checkedConvert('autoAddress', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$PRCommentSettingsToJson(PRCommentSettings instance) =>
    <String, dynamic>{
      'attribution': instance.attribution,
      'learnFromComments': instance.learnFromComments,
      'resolveFixed': instance.resolveFixed,
      'autoAddress': instance.autoAddress,
    };
