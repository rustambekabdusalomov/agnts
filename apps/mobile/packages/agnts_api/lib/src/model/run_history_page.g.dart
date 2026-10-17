// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_history_page.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RunHistoryPageCWProxy {
  RunHistoryPage items(List<RunTranscript> items);

  RunHistoryPage nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunHistoryPage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunHistoryPage(...).copyWith(id: 12, name: "My name")
  /// ````
  RunHistoryPage call({List<RunTranscript> items, String? nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRunHistoryPage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRunHistoryPage.copyWith.fieldName(...)`
class _$RunHistoryPageCWProxyImpl implements _$RunHistoryPageCWProxy {
  const _$RunHistoryPageCWProxyImpl(this._value);

  final RunHistoryPage _value;

  @override
  RunHistoryPage items(List<RunTranscript> items) => this(items: items);

  @override
  RunHistoryPage nextCursor(String? nextCursor) => this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RunHistoryPage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RunHistoryPage(...).copyWith(id: 12, name: "My name")
  /// ````
  RunHistoryPage call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return RunHistoryPage(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<RunTranscript>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $RunHistoryPageCopyWith on RunHistoryPage {
  /// Returns a callable class that can be used as follows: `instanceOfRunHistoryPage.copyWith(...)` or like so:`instanceOfRunHistoryPage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RunHistoryPageCWProxy get copyWith => _$RunHistoryPageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunHistoryPage _$RunHistoryPageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RunHistoryPage', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items']);
      final val = RunHistoryPage(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => RunTranscript.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextCursor: $checkedConvert('nextCursor', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$RunHistoryPageToJson(RunHistoryPage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'nextCursor': ?instance.nextCursor,
    };
