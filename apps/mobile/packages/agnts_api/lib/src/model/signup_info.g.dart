// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SignupInfoCWProxy {
  SignupInfo open(bool open);

  SignupInfo firstUser(bool firstUser);

  SignupInfo emailEnabled(bool emailEnabled);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SignupInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SignupInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  SignupInfo call({bool open, bool firstUser, bool emailEnabled});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSignupInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSignupInfo.copyWith.fieldName(...)`
class _$SignupInfoCWProxyImpl implements _$SignupInfoCWProxy {
  const _$SignupInfoCWProxyImpl(this._value);

  final SignupInfo _value;

  @override
  SignupInfo open(bool open) => this(open: open);

  @override
  SignupInfo firstUser(bool firstUser) => this(firstUser: firstUser);

  @override
  SignupInfo emailEnabled(bool emailEnabled) =>
      this(emailEnabled: emailEnabled);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SignupInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SignupInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  SignupInfo call({
    Object? open = const $CopyWithPlaceholder(),
    Object? firstUser = const $CopyWithPlaceholder(),
    Object? emailEnabled = const $CopyWithPlaceholder(),
  }) {
    return SignupInfo(
      open: open == const $CopyWithPlaceholder()
          ? _value.open
          // ignore: cast_nullable_to_non_nullable
          : open as bool,
      firstUser: firstUser == const $CopyWithPlaceholder()
          ? _value.firstUser
          // ignore: cast_nullable_to_non_nullable
          : firstUser as bool,
      emailEnabled: emailEnabled == const $CopyWithPlaceholder()
          ? _value.emailEnabled
          // ignore: cast_nullable_to_non_nullable
          : emailEnabled as bool,
    );
  }
}

extension $SignupInfoCopyWith on SignupInfo {
  /// Returns a callable class that can be used as follows: `instanceOfSignupInfo.copyWith(...)` or like so:`instanceOfSignupInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SignupInfoCWProxy get copyWith => _$SignupInfoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupInfo _$SignupInfoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SignupInfo',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['open', 'firstUser', 'emailEnabled']);
    final val = SignupInfo(
      open: $checkedConvert('open', (v) => v as bool),
      firstUser: $checkedConvert('firstUser', (v) => v as bool),
      emailEnabled: $checkedConvert('emailEnabled', (v) => v as bool),
    );
    return val;
  },
);

Map<String, dynamic> _$SignupInfoToJson(SignupInfo instance) =>
    <String, dynamic>{
      'open': instance.open,
      'firstUser': instance.firstUser,
      'emailEnabled': instance.emailEnabled,
    };
