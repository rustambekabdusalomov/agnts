// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grant_credits_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrantCreditsRequestCWProxy {
  GrantCreditsRequest amount(int amount);

  GrantCreditsRequest note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrantCreditsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrantCreditsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GrantCreditsRequest call({int amount, String? note});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrantCreditsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrantCreditsRequest.copyWith.fieldName(...)`
class _$GrantCreditsRequestCWProxyImpl implements _$GrantCreditsRequestCWProxy {
  const _$GrantCreditsRequestCWProxyImpl(this._value);

  final GrantCreditsRequest _value;

  @override
  GrantCreditsRequest amount(int amount) => this(amount: amount);

  @override
  GrantCreditsRequest note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrantCreditsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrantCreditsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GrantCreditsRequest call({
    Object? amount = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return GrantCreditsRequest(
      amount: amount == const $CopyWithPlaceholder()
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as int,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $GrantCreditsRequestCopyWith on GrantCreditsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfGrantCreditsRequest.copyWith(...)` or like so:`instanceOfGrantCreditsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrantCreditsRequestCWProxy get copyWith =>
      _$GrantCreditsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrantCreditsRequest _$GrantCreditsRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GrantCreditsRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['amount']);
      final val = GrantCreditsRequest(
        amount: $checkedConvert('amount', (v) => (v as num).toInt()),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$GrantCreditsRequestToJson(
  GrantCreditsRequest instance,
) => <String, dynamic>{'amount': instance.amount, 'note': ?instance.note};
