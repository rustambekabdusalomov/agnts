// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'try_enforce_result_hits_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TryEnforceResultHitsInnerCWProxy {
  TryEnforceResultHitsInner ticket(String ticket);

  TryEnforceResultHitsInner path(String path);

  TryEnforceResultHitsInner line(int? line);

  TryEnforceResultHitsInner text(String text);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TryEnforceResultHitsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TryEnforceResultHitsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  TryEnforceResultHitsInner call({
    String ticket,
    String path,
    int? line,
    String text,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTryEnforceResultHitsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTryEnforceResultHitsInner.copyWith.fieldName(...)`
class _$TryEnforceResultHitsInnerCWProxyImpl
    implements _$TryEnforceResultHitsInnerCWProxy {
  const _$TryEnforceResultHitsInnerCWProxyImpl(this._value);

  final TryEnforceResultHitsInner _value;

  @override
  TryEnforceResultHitsInner ticket(String ticket) => this(ticket: ticket);

  @override
  TryEnforceResultHitsInner path(String path) => this(path: path);

  @override
  TryEnforceResultHitsInner line(int? line) => this(line: line);

  @override
  TryEnforceResultHitsInner text(String text) => this(text: text);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TryEnforceResultHitsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TryEnforceResultHitsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  TryEnforceResultHitsInner call({
    Object? ticket = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
  }) {
    return TryEnforceResultHitsInner(
      ticket: ticket == const $CopyWithPlaceholder()
          ? _value.ticket
          // ignore: cast_nullable_to_non_nullable
          : ticket as String,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int?,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
    );
  }
}

extension $TryEnforceResultHitsInnerCopyWith on TryEnforceResultHitsInner {
  /// Returns a callable class that can be used as follows: `instanceOfTryEnforceResultHitsInner.copyWith(...)` or like so:`instanceOfTryEnforceResultHitsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TryEnforceResultHitsInnerCWProxy get copyWith =>
      _$TryEnforceResultHitsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TryEnforceResultHitsInner _$TryEnforceResultHitsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TryEnforceResultHitsInner', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['ticket', 'path', 'text']);
  final val = TryEnforceResultHitsInner(
    ticket: $checkedConvert('ticket', (v) => v as String),
    path: $checkedConvert('path', (v) => v as String),
    line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
    text: $checkedConvert('text', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$TryEnforceResultHitsInnerToJson(
  TryEnforceResultHitsInner instance,
) => <String, dynamic>{
  'ticket': instance.ticket,
  'path': instance.path,
  'line': ?instance.line,
  'text': instance.text,
};
