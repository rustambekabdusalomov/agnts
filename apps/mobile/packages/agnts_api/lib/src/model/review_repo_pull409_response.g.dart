// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_repo_pull409_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewRepoPull409ResponseCWProxy {
  ReviewRepoPull409Response code(String code);

  ReviewRepoPull409Response message(String message);

  ReviewRepoPull409Response ticketKey(String ticketKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewRepoPull409Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewRepoPull409Response(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewRepoPull409Response call({
    String code,
    String message,
    String ticketKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewRepoPull409Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewRepoPull409Response.copyWith.fieldName(...)`
class _$ReviewRepoPull409ResponseCWProxyImpl
    implements _$ReviewRepoPull409ResponseCWProxy {
  const _$ReviewRepoPull409ResponseCWProxyImpl(this._value);

  final ReviewRepoPull409Response _value;

  @override
  ReviewRepoPull409Response code(String code) => this(code: code);

  @override
  ReviewRepoPull409Response message(String message) => this(message: message);

  @override
  ReviewRepoPull409Response ticketKey(String ticketKey) =>
      this(ticketKey: ticketKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewRepoPull409Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewRepoPull409Response(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewRepoPull409Response call({
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
  }) {
    return ReviewRepoPull409Response(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String,
    );
  }
}

extension $ReviewRepoPull409ResponseCopyWith on ReviewRepoPull409Response {
  /// Returns a callable class that can be used as follows: `instanceOfReviewRepoPull409Response.copyWith(...)` or like so:`instanceOfReviewRepoPull409Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewRepoPull409ResponseCWProxy get copyWith =>
      _$ReviewRepoPull409ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewRepoPull409Response _$ReviewRepoPull409ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReviewRepoPull409Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'ticketKey']);
  final val = ReviewRepoPull409Response(
    code: $checkedConvert('code', (v) => v as String),
    message: $checkedConvert('message', (v) => v as String),
    ticketKey: $checkedConvert('ticketKey', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ReviewRepoPull409ResponseToJson(
  ReviewRepoPull409Response instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'ticketKey': instance.ticketKey,
};
