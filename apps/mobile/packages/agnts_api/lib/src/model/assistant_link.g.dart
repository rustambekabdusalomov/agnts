// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_link.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantLinkCWProxy {
  AssistantLink kind(AssistantLinkKindEnum kind);

  AssistantLink key(String? key);

  AssistantLink id(int? id);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantLink(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantLink(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantLink call({AssistantLinkKindEnum kind, String? key, int? id});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantLink.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantLink.copyWith.fieldName(...)`
class _$AssistantLinkCWProxyImpl implements _$AssistantLinkCWProxy {
  const _$AssistantLinkCWProxyImpl(this._value);

  final AssistantLink _value;

  @override
  AssistantLink kind(AssistantLinkKindEnum kind) => this(kind: kind);

  @override
  AssistantLink key(String? key) => this(key: key);

  @override
  AssistantLink id(int? id) => this(id: id);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantLink(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantLink(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantLink call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? key = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
  }) {
    return AssistantLink(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as AssistantLinkKindEnum,
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String?,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
    );
  }
}

extension $AssistantLinkCopyWith on AssistantLink {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantLink.copyWith(...)` or like so:`instanceOfAssistantLink.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantLinkCWProxy get copyWith => _$AssistantLinkCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantLink _$AssistantLinkFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantLink', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind']);
      final val = AssistantLink(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$AssistantLinkKindEnumEnumMap, v),
        ),
        key: $checkedConvert('key', (v) => v as String?),
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AssistantLinkToJson(AssistantLink instance) =>
    <String, dynamic>{
      'kind': _$AssistantLinkKindEnumEnumMap[instance.kind]!,
      'key': ?instance.key,
      'id': ?instance.id,
    };

const _$AssistantLinkKindEnumEnumMap = {
  AssistantLinkKindEnum.ticket: 'ticket',
  AssistantLinkKindEnum.ci: 'ci',
  AssistantLinkKindEnum.lesson: 'lesson',
};
