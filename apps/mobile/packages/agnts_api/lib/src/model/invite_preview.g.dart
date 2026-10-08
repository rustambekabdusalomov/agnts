// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_preview.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InvitePreviewCWProxy {
  InvitePreview workspace(String workspace);

  InvitePreview invitedBy(String? invitedBy);

  InvitePreview email(String? email);

  InvitePreview expiresAt(DateTime expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InvitePreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InvitePreview(...).copyWith(id: 12, name: "My name")
  /// ````
  InvitePreview call({
    String workspace,
    String? invitedBy,
    String? email,
    DateTime expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInvitePreview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInvitePreview.copyWith.fieldName(...)`
class _$InvitePreviewCWProxyImpl implements _$InvitePreviewCWProxy {
  const _$InvitePreviewCWProxyImpl(this._value);

  final InvitePreview _value;

  @override
  InvitePreview workspace(String workspace) => this(workspace: workspace);

  @override
  InvitePreview invitedBy(String? invitedBy) => this(invitedBy: invitedBy);

  @override
  InvitePreview email(String? email) => this(email: email);

  @override
  InvitePreview expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InvitePreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InvitePreview(...).copyWith(id: 12, name: "My name")
  /// ````
  InvitePreview call({
    Object? workspace = const $CopyWithPlaceholder(),
    Object? invitedBy = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return InvitePreview(
      workspace: workspace == const $CopyWithPlaceholder()
          ? _value.workspace
          // ignore: cast_nullable_to_non_nullable
          : workspace as String,
      invitedBy: invitedBy == const $CopyWithPlaceholder()
          ? _value.invitedBy
          // ignore: cast_nullable_to_non_nullable
          : invitedBy as String?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $InvitePreviewCopyWith on InvitePreview {
  /// Returns a callable class that can be used as follows: `instanceOfInvitePreview.copyWith(...)` or like so:`instanceOfInvitePreview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InvitePreviewCWProxy get copyWith => _$InvitePreviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitePreview _$InvitePreviewFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InvitePreview', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['workspace', 'expiresAt']);
      final val = InvitePreview(
        workspace: $checkedConvert('workspace', (v) => v as String),
        invitedBy: $checkedConvert('invitedBy', (v) => v as String?),
        email: $checkedConvert('email', (v) => v as String?),
        expiresAt: $checkedConvert(
          'expiresAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$InvitePreviewToJson(InvitePreview instance) =>
    <String, dynamic>{
      'workspace': instance.workspace,
      'invitedBy': ?instance.invitedBy,
      'email': ?instance.email,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
