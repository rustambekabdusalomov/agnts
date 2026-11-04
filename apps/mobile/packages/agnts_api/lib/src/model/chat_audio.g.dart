// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_audio.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatAudioCWProxy {
  ChatAudio contentType(String contentType);

  ChatAudio durationMs(int durationMs);

  ChatAudio transcript(ChatAudioTranscriptEnum transcript);

  ChatAudio error(String? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatAudio(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatAudio(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatAudio call({
    String contentType,
    int durationMs,
    ChatAudioTranscriptEnum transcript,
    String? error,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatAudio.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatAudio.copyWith.fieldName(...)`
class _$ChatAudioCWProxyImpl implements _$ChatAudioCWProxy {
  const _$ChatAudioCWProxyImpl(this._value);

  final ChatAudio _value;

  @override
  ChatAudio contentType(String contentType) => this(contentType: contentType);

  @override
  ChatAudio durationMs(int durationMs) => this(durationMs: durationMs);

  @override
  ChatAudio transcript(ChatAudioTranscriptEnum transcript) =>
      this(transcript: transcript);

  @override
  ChatAudio error(String? error) => this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatAudio(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatAudio(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatAudio call({
    Object? contentType = const $CopyWithPlaceholder(),
    Object? durationMs = const $CopyWithPlaceholder(),
    Object? transcript = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return ChatAudio(
      contentType: contentType == const $CopyWithPlaceholder()
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String,
      durationMs: durationMs == const $CopyWithPlaceholder()
          ? _value.durationMs
          // ignore: cast_nullable_to_non_nullable
          : durationMs as int,
      transcript: transcript == const $CopyWithPlaceholder()
          ? _value.transcript
          // ignore: cast_nullable_to_non_nullable
          : transcript as ChatAudioTranscriptEnum,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
    );
  }
}

extension $ChatAudioCopyWith on ChatAudio {
  /// Returns a callable class that can be used as follows: `instanceOfChatAudio.copyWith(...)` or like so:`instanceOfChatAudio.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatAudioCWProxy get copyWith => _$ChatAudioCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatAudio _$ChatAudioFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatAudio', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['contentType', 'durationMs', 'transcript'],
      );
      final val = ChatAudio(
        contentType: $checkedConvert('contentType', (v) => v as String),
        durationMs: $checkedConvert('durationMs', (v) => (v as num).toInt()),
        transcript: $checkedConvert(
          'transcript',
          (v) => $enumDecode(_$ChatAudioTranscriptEnumEnumMap, v),
        ),
        error: $checkedConvert('error', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ChatAudioToJson(ChatAudio instance) => <String, dynamic>{
  'contentType': instance.contentType,
  'durationMs': instance.durationMs,
  'transcript': _$ChatAudioTranscriptEnumEnumMap[instance.transcript]!,
  'error': ?instance.error,
};

const _$ChatAudioTranscriptEnumEnumMap = {
  ChatAudioTranscriptEnum.pending: 'pending',
  ChatAudioTranscriptEnum.done: 'done',
  ChatAudioTranscriptEnum.none: 'none',
  ChatAudioTranscriptEnum.failed: 'failed',
};
