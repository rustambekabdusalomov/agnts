// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_ref.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatRefCWProxy {
  ChatRef type(ChatRefTypeEnum type);

  ChatRef id(String id);

  ChatRef source_(ChatRefSource_Enum source_);

  ChatRef confidence(num confidence);

  ChatRef reason(String? reason);

  ChatRef label(String? label);

  ChatRef url(String? url);

  ChatRef ai(ChatAI? ai);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatRef(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatRef call({
    ChatRefTypeEnum type,
    String id,
    ChatRefSource_Enum source_,
    num confidence,
    String? reason,
    String? label,
    String? url,
    ChatAI? ai,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatRef.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatRef.copyWith.fieldName(...)`
class _$ChatRefCWProxyImpl implements _$ChatRefCWProxy {
  const _$ChatRefCWProxyImpl(this._value);

  final ChatRef _value;

  @override
  ChatRef type(ChatRefTypeEnum type) => this(type: type);

  @override
  ChatRef id(String id) => this(id: id);

  @override
  ChatRef source_(ChatRefSource_Enum source_) => this(source_: source_);

  @override
  ChatRef confidence(num confidence) => this(confidence: confidence);

  @override
  ChatRef reason(String? reason) => this(reason: reason);

  @override
  ChatRef label(String? label) => this(label: label);

  @override
  ChatRef url(String? url) => this(url: url);

  @override
  ChatRef ai(ChatAI? ai) => this(ai: ai);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatRef(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatRef call({
    Object? type = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? ai = const $CopyWithPlaceholder(),
  }) {
    return ChatRef(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as ChatRefTypeEnum,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as ChatRefSource_Enum,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as num,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      ai: ai == const $CopyWithPlaceholder()
          ? _value.ai
          // ignore: cast_nullable_to_non_nullable
          : ai as ChatAI?,
    );
  }
}

extension $ChatRefCopyWith on ChatRef {
  /// Returns a callable class that can be used as follows: `instanceOfChatRef.copyWith(...)` or like so:`instanceOfChatRef.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatRefCWProxy get copyWith => _$ChatRefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRef _$ChatRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatRef', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['type', 'id', 'source', 'confidence'],
      );
      final val = ChatRef(
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$ChatRefTypeEnumEnumMap, v),
        ),
        id: $checkedConvert('id', (v) => v as String),
        source_: $checkedConvert(
          'source',
          (v) => $enumDecode(_$ChatRefSource_EnumEnumMap, v),
        ),
        confidence: $checkedConvert('confidence', (v) => v as num),
        reason: $checkedConvert('reason', (v) => v as String?),
        label: $checkedConvert('label', (v) => v as String?),
        url: $checkedConvert('url', (v) => v as String?),
        ai: $checkedConvert(
          'ai',
          (v) => v == null ? null : ChatAI.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$ChatRefToJson(ChatRef instance) => <String, dynamic>{
  'type': _$ChatRefTypeEnumEnumMap[instance.type]!,
  'id': instance.id,
  'source': _$ChatRefSource_EnumEnumMap[instance.source_]!,
  'confidence': instance.confidence,
  'reason': ?instance.reason,
  'label': ?instance.label,
  'url': ?instance.url,
  'ai': ?instance.ai?.toJson(),
};

const _$ChatRefTypeEnumEnumMap = {
  ChatRefTypeEnum.ticket: 'ticket',
  ChatRefTypeEnum.pr: 'pr',
  ChatRefTypeEnum.repo: 'repo',
  ChatRefTypeEnum.finding: 'finding',
};

const _$ChatRefSource_EnumEnumMap = {
  ChatRefSource_Enum.explicit: 'explicit',
  ChatRefSource_Enum.model: 'model',
  ChatRefSource_Enum.card: 'card',
};
