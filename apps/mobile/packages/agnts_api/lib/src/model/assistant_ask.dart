//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/assistant_language.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_ask.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantAsk {
  /// Returns a new [AssistantAsk] instance.
  AssistantAsk({

     this.question,

     this.attachments,

     this.lang,
  });

      /// May be empty when attachments are sent
  @JsonKey(
    
    name: r'question',
    required: false,
    includeIfNull: false,
  )


  final String? question;



      /// The asker's pending uploads (uploadAttachment); the answer reads them
  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<int>? attachments;



  @JsonKey(
    
    name: r'lang',
    required: false,
    includeIfNull: false,
  )


  final AssistantLanguage? lang;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantAsk &&
      other.question == question &&
      other.attachments == attachments &&
      other.lang == lang;

    @override
    int get hashCode =>
        question.hashCode +
        attachments.hashCode +
        lang.hashCode;

  factory AssistantAsk.fromJson(Map<String, dynamic> json) => _$AssistantAskFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantAskToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

