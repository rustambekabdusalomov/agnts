//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_ticket_document_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateTicketDocumentRequest {
  /// Returns a new [CreateTicketDocumentRequest] instance.
  CreateTicketDocumentRequest({

     this.instruction,

     this.language,
  });

      /// How to write it: \"for the client, no technical detail\"
  @JsonKey(
    
    name: r'instruction',
    required: false,
    includeIfNull: false,
  )


  final String? instruction;



  @JsonKey(
    
    name: r'language',
    required: false,
    includeIfNull: false,
  )


  final CreateTicketDocumentRequestLanguageEnum? language;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateTicketDocumentRequest &&
      other.instruction == instruction &&
      other.language == language;

    @override
    int get hashCode =>
        instruction.hashCode +
        language.hashCode;

  factory CreateTicketDocumentRequest.fromJson(Map<String, dynamic> json) => _$CreateTicketDocumentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTicketDocumentRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum CreateTicketDocumentRequestLanguageEnum {
@JsonValue(r'en')
en(r'en'),
@JsonValue(r'ru')
ru(r'ru'),
@JsonValue(r'uz')
uz(r'uz');

const CreateTicketDocumentRequestLanguageEnum(this.value);

final String value;

@override
String toString() => value;
}


