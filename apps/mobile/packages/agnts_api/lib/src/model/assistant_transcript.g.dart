// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_transcript.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantTranscriptCWProxy {
  AssistantTranscript text(String text);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantTranscript(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantTranscript(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantTranscript call({String text});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantTranscript.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantTranscript.copyWith.fieldName(...)`
class _$AssistantTranscriptCWProxyImpl implements _$AssistantTranscriptCWProxy {
  const _$AssistantTranscriptCWProxyImpl(this._value);

  final AssistantTranscript _value;

  @override
  AssistantTranscript text(String text) => this(text: text);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantTranscript(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantTranscript(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantTranscript call({Object? text = const $CopyWithPlaceholder()}) {
    return AssistantTranscript(
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
    );
  }
}

extension $AssistantTranscriptCopyWith on AssistantTranscript {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantTranscript.copyWith(...)` or like so:`instanceOfAssistantTranscript.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantTranscriptCWProxy get copyWith =>
      _$AssistantTranscriptCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantTranscript _$AssistantTranscriptFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantTranscript', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['text']);
      final val = AssistantTranscript(
        text: $checkedConvert('text', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AssistantTranscriptToJson(
  AssistantTranscript instance,
) => <String, dynamic>{'text': instance.text};
