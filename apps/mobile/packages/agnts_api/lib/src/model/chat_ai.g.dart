// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_ai.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatAICWProxy {
  ChatAI provider(String provider);

  ChatAI model(String model);

  ChatAI ms(int ms);

  ChatAI costUsd(num costUsd);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatAI(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatAI(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatAI call({String provider, String model, int ms, num costUsd});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatAI.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatAI.copyWith.fieldName(...)`
class _$ChatAICWProxyImpl implements _$ChatAICWProxy {
  const _$ChatAICWProxyImpl(this._value);

  final ChatAI _value;

  @override
  ChatAI provider(String provider) => this(provider: provider);

  @override
  ChatAI model(String model) => this(model: model);

  @override
  ChatAI ms(int ms) => this(ms: ms);

  @override
  ChatAI costUsd(num costUsd) => this(costUsd: costUsd);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatAI(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatAI(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatAI call({
    Object? provider = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
    Object? ms = const $CopyWithPlaceholder(),
    Object? costUsd = const $CopyWithPlaceholder(),
  }) {
    return ChatAI(
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as String,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      ms: ms == const $CopyWithPlaceholder()
          ? _value.ms
          // ignore: cast_nullable_to_non_nullable
          : ms as int,
      costUsd: costUsd == const $CopyWithPlaceholder()
          ? _value.costUsd
          // ignore: cast_nullable_to_non_nullable
          : costUsd as num,
    );
  }
}

extension $ChatAICopyWith on ChatAI {
  /// Returns a callable class that can be used as follows: `instanceOfChatAI.copyWith(...)` or like so:`instanceOfChatAI.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatAICWProxy get copyWith => _$ChatAICWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatAI _$ChatAIFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatAI', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['provider', 'model', 'ms', 'costUsd'],
      );
      final val = ChatAI(
        provider: $checkedConvert('provider', (v) => v as String),
        model: $checkedConvert('model', (v) => v as String),
        ms: $checkedConvert('ms', (v) => (v as num).toInt()),
        costUsd: $checkedConvert('costUsd', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$ChatAIToJson(ChatAI instance) => <String, dynamic>{
  'provider': instance.provider,
  'model': instance.model,
  'ms': instance.ms,
  'costUsd': instance.costUsd,
};
