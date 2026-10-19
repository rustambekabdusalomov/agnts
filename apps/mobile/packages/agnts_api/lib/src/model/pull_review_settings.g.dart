// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_review_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullReviewSettingsCWProxy {
  PullReviewSettings enabled(bool enabled);

  PullReviewSettings reviewRequested(bool reviewRequested);

  PullReviewSettings all(bool? all);

  PullReviewSettings skipDrafts(bool skipDrafts);

  PullReviewSettings rereview(bool rereview);

  PullReviewSettings mergeMethod(PullReviewSettingsMergeMethodEnum mergeMethod);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullReviewSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullReviewSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  PullReviewSettings call({
    bool enabled,
    bool reviewRequested,
    bool? all,
    bool skipDrafts,
    bool rereview,
    PullReviewSettingsMergeMethodEnum mergeMethod,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullReviewSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullReviewSettings.copyWith.fieldName(...)`
class _$PullReviewSettingsCWProxyImpl implements _$PullReviewSettingsCWProxy {
  const _$PullReviewSettingsCWProxyImpl(this._value);

  final PullReviewSettings _value;

  @override
  PullReviewSettings enabled(bool enabled) => this(enabled: enabled);

  @override
  PullReviewSettings reviewRequested(bool reviewRequested) =>
      this(reviewRequested: reviewRequested);

  @override
  PullReviewSettings all(bool? all) => this(all: all);

  @override
  PullReviewSettings skipDrafts(bool skipDrafts) =>
      this(skipDrafts: skipDrafts);

  @override
  PullReviewSettings rereview(bool rereview) => this(rereview: rereview);

  @override
  PullReviewSettings mergeMethod(
    PullReviewSettingsMergeMethodEnum mergeMethod,
  ) => this(mergeMethod: mergeMethod);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullReviewSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullReviewSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  PullReviewSettings call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? reviewRequested = const $CopyWithPlaceholder(),
    Object? all = const $CopyWithPlaceholder(),
    Object? skipDrafts = const $CopyWithPlaceholder(),
    Object? rereview = const $CopyWithPlaceholder(),
    Object? mergeMethod = const $CopyWithPlaceholder(),
  }) {
    return PullReviewSettings(
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      reviewRequested: reviewRequested == const $CopyWithPlaceholder()
          ? _value.reviewRequested
          // ignore: cast_nullable_to_non_nullable
          : reviewRequested as bool,
      all: all == const $CopyWithPlaceholder()
          ? _value.all
          // ignore: cast_nullable_to_non_nullable
          : all as bool?,
      skipDrafts: skipDrafts == const $CopyWithPlaceholder()
          ? _value.skipDrafts
          // ignore: cast_nullable_to_non_nullable
          : skipDrafts as bool,
      rereview: rereview == const $CopyWithPlaceholder()
          ? _value.rereview
          // ignore: cast_nullable_to_non_nullable
          : rereview as bool,
      mergeMethod: mergeMethod == const $CopyWithPlaceholder()
          ? _value.mergeMethod
          // ignore: cast_nullable_to_non_nullable
          : mergeMethod as PullReviewSettingsMergeMethodEnum,
    );
  }
}

extension $PullReviewSettingsCopyWith on PullReviewSettings {
  /// Returns a callable class that can be used as follows: `instanceOfPullReviewSettings.copyWith(...)` or like so:`instanceOfPullReviewSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullReviewSettingsCWProxy get copyWith =>
      _$PullReviewSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullReviewSettings _$PullReviewSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PullReviewSettings', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'enabled',
          'reviewRequested',
          'skipDrafts',
          'rereview',
          'mergeMethod',
        ],
      );
      final val = PullReviewSettings(
        enabled: $checkedConvert('enabled', (v) => v as bool),
        reviewRequested: $checkedConvert('reviewRequested', (v) => v as bool),
        all: $checkedConvert('all', (v) => v as bool?),
        skipDrafts: $checkedConvert('skipDrafts', (v) => v as bool),
        rereview: $checkedConvert('rereview', (v) => v as bool),
        mergeMethod: $checkedConvert(
          'mergeMethod',
          (v) => $enumDecode(_$PullReviewSettingsMergeMethodEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PullReviewSettingsToJson(PullReviewSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'reviewRequested': instance.reviewRequested,
      'all': ?instance.all,
      'skipDrafts': instance.skipDrafts,
      'rereview': instance.rereview,
      'mergeMethod':
          _$PullReviewSettingsMergeMethodEnumEnumMap[instance.mergeMethod]!,
    };

const _$PullReviewSettingsMergeMethodEnumEnumMap = {
  PullReviewSettingsMergeMethodEnum.merge: 'merge',
  PullReviewSettingsMergeMethodEnum.squash: 'squash',
  PullReviewSettingsMergeMethodEnum.rebase: 'rebase',
};
