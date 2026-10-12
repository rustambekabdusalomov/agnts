// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'try_enforce_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TryEnforceResultCWProxy {
  TryEnforceResult checked(int checked);

  TryEnforceResult tickets(List<String> tickets);

  TryEnforceResult hits(List<TryEnforceResultHitsInner> hits);

  TryEnforceResult note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TryEnforceResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TryEnforceResult(...).copyWith(id: 12, name: "My name")
  /// ````
  TryEnforceResult call({
    int checked,
    List<String> tickets,
    List<TryEnforceResultHitsInner> hits,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTryEnforceResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTryEnforceResult.copyWith.fieldName(...)`
class _$TryEnforceResultCWProxyImpl implements _$TryEnforceResultCWProxy {
  const _$TryEnforceResultCWProxyImpl(this._value);

  final TryEnforceResult _value;

  @override
  TryEnforceResult checked(int checked) => this(checked: checked);

  @override
  TryEnforceResult tickets(List<String> tickets) => this(tickets: tickets);

  @override
  TryEnforceResult hits(List<TryEnforceResultHitsInner> hits) =>
      this(hits: hits);

  @override
  TryEnforceResult note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TryEnforceResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TryEnforceResult(...).copyWith(id: 12, name: "My name")
  /// ````
  TryEnforceResult call({
    Object? checked = const $CopyWithPlaceholder(),
    Object? tickets = const $CopyWithPlaceholder(),
    Object? hits = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return TryEnforceResult(
      checked: checked == const $CopyWithPlaceholder()
          ? _value.checked
          // ignore: cast_nullable_to_non_nullable
          : checked as int,
      tickets: tickets == const $CopyWithPlaceholder()
          ? _value.tickets
          // ignore: cast_nullable_to_non_nullable
          : tickets as List<String>,
      hits: hits == const $CopyWithPlaceholder()
          ? _value.hits
          // ignore: cast_nullable_to_non_nullable
          : hits as List<TryEnforceResultHitsInner>,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $TryEnforceResultCopyWith on TryEnforceResult {
  /// Returns a callable class that can be used as follows: `instanceOfTryEnforceResult.copyWith(...)` or like so:`instanceOfTryEnforceResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TryEnforceResultCWProxy get copyWith => _$TryEnforceResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TryEnforceResult _$TryEnforceResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TryEnforceResult', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['checked', 'tickets', 'hits']);
      final val = TryEnforceResult(
        checked: $checkedConvert('checked', (v) => (v as num).toInt()),
        tickets: $checkedConvert(
          'tickets',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        hits: $checkedConvert(
          'hits',
          (v) => (v as List<dynamic>)
              .map(
                (e) => TryEnforceResultHitsInner.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$TryEnforceResultToJson(TryEnforceResult instance) =>
    <String, dynamic>{
      'checked': instance.checked,
      'tickets': instance.tickets,
      'hits': instance.hits.map((e) => e.toJson()).toList(),
      'note': ?instance.note,
    };
