//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_audio.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatAudio {
  /// Returns a new [ChatAudio] instance.
  ChatAudio({

    required  this.contentType,

    required  this.durationMs,

    required  this.transcript,

     this.error,
  });

  @JsonKey(
    
    name: r'contentType',
    required: true,
    includeIfNull: false,
  )


  final String contentType;



  @JsonKey(
    
    name: r'durationMs',
    required: true,
    includeIfNull: false,
  )


  final int durationMs;



      /// none: no words were heard
  @JsonKey(
    
    name: r'transcript',
    required: true,
    includeIfNull: false,
  )


  final ChatAudioTranscriptEnum transcript;



  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChatAudio &&
      other.contentType == contentType &&
      other.durationMs == durationMs &&
      other.transcript == transcript &&
      other.error == error;

    @override
    int get hashCode =>
        contentType.hashCode +
        durationMs.hashCode +
        transcript.hashCode +
        error.hashCode;

  factory ChatAudio.fromJson(Map<String, dynamic> json) => _$ChatAudioFromJson(json);

  Map<String, dynamic> toJson() => _$ChatAudioToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// none: no words were heard
enum ChatAudioTranscriptEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'failed')
failed(r'failed');

const ChatAudioTranscriptEnum(this.value);

final String value;

@override
String toString() => value;
}


