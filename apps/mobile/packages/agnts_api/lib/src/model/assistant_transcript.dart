//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_transcript.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantTranscript {
  /// Returns a new [AssistantTranscript] instance.
  AssistantTranscript({

    required  this.text,
  });

      /// The words Muse heard in the recording
  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantTranscript &&
      other.text == text;

    @override
    int get hashCode =>
        text.hashCode;

  factory AssistantTranscript.fromJson(Map<String, dynamic> json) => _$AssistantTranscriptFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantTranscriptToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

