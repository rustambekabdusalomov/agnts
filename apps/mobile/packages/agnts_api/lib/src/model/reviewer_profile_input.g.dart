// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviewer_profile_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewerProfileInputCWProxy {
  ReviewerProfileInput profile(String profile);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewerProfileInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewerProfileInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewerProfileInput call({String profile});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewerProfileInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewerProfileInput.copyWith.fieldName(...)`
class _$ReviewerProfileInputCWProxyImpl
    implements _$ReviewerProfileInputCWProxy {
  const _$ReviewerProfileInputCWProxyImpl(this._value);

  final ReviewerProfileInput _value;

  @override
  ReviewerProfileInput profile(String profile) => this(profile: profile);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewerProfileInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewerProfileInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewerProfileInput call({Object? profile = const $CopyWithPlaceholder()}) {
    return ReviewerProfileInput(
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as String,
    );
  }
}

extension $ReviewerProfileInputCopyWith on ReviewerProfileInput {
  /// Returns a callable class that can be used as follows: `instanceOfReviewerProfileInput.copyWith(...)` or like so:`instanceOfReviewerProfileInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewerProfileInputCWProxy get copyWith =>
      _$ReviewerProfileInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewerProfileInput _$ReviewerProfileInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReviewerProfileInput', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['profile']);
  final val = ReviewerProfileInput(
    profile: $checkedConvert('profile', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ReviewerProfileInputToJson(
  ReviewerProfileInput instance,
) => <String, dynamic>{'profile': instance.profile};
