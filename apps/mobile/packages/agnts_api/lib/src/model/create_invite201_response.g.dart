// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_invite201_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateInvite201ResponseCWProxy {
  CreateInvite201Response invite(Invite invite);

  CreateInvite201Response url(String url);

  CreateInvite201Response emailed(bool? emailed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateInvite201Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateInvite201Response(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateInvite201Response call({Invite invite, String url, bool? emailed});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateInvite201Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateInvite201Response.copyWith.fieldName(...)`
class _$CreateInvite201ResponseCWProxyImpl
    implements _$CreateInvite201ResponseCWProxy {
  const _$CreateInvite201ResponseCWProxyImpl(this._value);

  final CreateInvite201Response _value;

  @override
  CreateInvite201Response invite(Invite invite) => this(invite: invite);

  @override
  CreateInvite201Response url(String url) => this(url: url);

  @override
  CreateInvite201Response emailed(bool? emailed) => this(emailed: emailed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateInvite201Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateInvite201Response(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateInvite201Response call({
    Object? invite = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? emailed = const $CopyWithPlaceholder(),
  }) {
    return CreateInvite201Response(
      invite: invite == const $CopyWithPlaceholder()
          ? _value.invite
          // ignore: cast_nullable_to_non_nullable
          : invite as Invite,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      emailed: emailed == const $CopyWithPlaceholder()
          ? _value.emailed
          // ignore: cast_nullable_to_non_nullable
          : emailed as bool?,
    );
  }
}

extension $CreateInvite201ResponseCopyWith on CreateInvite201Response {
  /// Returns a callable class that can be used as follows: `instanceOfCreateInvite201Response.copyWith(...)` or like so:`instanceOfCreateInvite201Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateInvite201ResponseCWProxy get copyWith =>
      _$CreateInvite201ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateInvite201Response _$CreateInvite201ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateInvite201Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['invite', 'url']);
  final val = CreateInvite201Response(
    invite: $checkedConvert(
      'invite',
      (v) => Invite.fromJson(v as Map<String, dynamic>),
    ),
    url: $checkedConvert('url', (v) => v as String),
    emailed: $checkedConvert('emailed', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$CreateInvite201ResponseToJson(
  CreateInvite201Response instance,
) => <String, dynamic>{
  'invite': instance.invite.toJson(),
  'url': instance.url,
  'emailed': ?instance.emailed,
};
