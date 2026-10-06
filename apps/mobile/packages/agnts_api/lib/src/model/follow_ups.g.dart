// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_ups.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FollowUpsCWProxy {
  FollowUps enabled(bool enabled);

  FollowUps suggestions(List<FollowUpSuggestion> suggestions);

  FollowUps children(List<FollowUpTicket> children);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowUps(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowUps(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowUps call({
    bool enabled,
    List<FollowUpSuggestion> suggestions,
    List<FollowUpTicket> children,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFollowUps.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFollowUps.copyWith.fieldName(...)`
class _$FollowUpsCWProxyImpl implements _$FollowUpsCWProxy {
  const _$FollowUpsCWProxyImpl(this._value);

  final FollowUps _value;

  @override
  FollowUps enabled(bool enabled) => this(enabled: enabled);

  @override
  FollowUps suggestions(List<FollowUpSuggestion> suggestions) =>
      this(suggestions: suggestions);

  @override
  FollowUps children(List<FollowUpTicket> children) => this(children: children);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowUps(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowUps(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowUps call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? suggestions = const $CopyWithPlaceholder(),
    Object? children = const $CopyWithPlaceholder(),
  }) {
    return FollowUps(
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      suggestions: suggestions == const $CopyWithPlaceholder()
          ? _value.suggestions
          // ignore: cast_nullable_to_non_nullable
          : suggestions as List<FollowUpSuggestion>,
      children: children == const $CopyWithPlaceholder()
          ? _value.children
          // ignore: cast_nullable_to_non_nullable
          : children as List<FollowUpTicket>,
    );
  }
}

extension $FollowUpsCopyWith on FollowUps {
  /// Returns a callable class that can be used as follows: `instanceOfFollowUps.copyWith(...)` or like so:`instanceOfFollowUps.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FollowUpsCWProxy get copyWith => _$FollowUpsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowUps _$FollowUpsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('FollowUps', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['enabled', 'suggestions', 'children']);
  final val = FollowUps(
    enabled: $checkedConvert('enabled', (v) => v as bool),
    suggestions: $checkedConvert(
      'suggestions',
      (v) => (v as List<dynamic>)
          .map((e) => FollowUpSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    children: $checkedConvert(
      'children',
      (v) => (v as List<dynamic>)
          .map((e) => FollowUpTicket.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$FollowUpsToJson(FollowUps instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'suggestions': instance.suggestions.map((e) => e.toJson()).toList(),
  'children': instance.children.map((e) => e.toJson()).toList(),
};
