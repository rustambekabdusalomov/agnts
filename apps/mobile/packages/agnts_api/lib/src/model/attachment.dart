//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Attachment {
  /// Returns a new [Attachment] instance.
  Attachment({

    required  this.id,

    required  this.name,

    required  this.contentType,

    required  this.size,

    required  this.purpose,

     this.questionId,

     this.image,

    required  this.url,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'contentType',
    required: true,
    includeIfNull: false,
  )


  final String contentType;



      /// Bytes
  @JsonKey(
    
    name: r'size',
    required: true,
    includeIfNull: false,
  )


  final int size;



      /// pending = uploaded, not attached yet; ticket = the task description; answer = an answer (see questionId); retry = a retry note; feedback = requested changes; chat = a team chat message; assistant = an AI chat question
  @JsonKey(
    
    name: r'purpose',
    required: true,
    includeIfNull: false,
  )


  final AttachmentPurposeEnum purpose;



  @JsonKey(
    
    name: r'questionId',
    required: false,
    includeIfNull: false,
  )


  final int? questionId;



      /// A picture clients can show in place
  @JsonKey(
    
    name: r'image',
    required: false,
    includeIfNull: false,
  )


  final bool? image;



      /// Where to load the file, relative to the API base
  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Attachment &&
      other.id == id &&
      other.name == name &&
      other.contentType == contentType &&
      other.size == size &&
      other.purpose == purpose &&
      other.questionId == questionId &&
      other.image == image &&
      other.url == url &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        contentType.hashCode +
        size.hashCode +
        purpose.hashCode +
        questionId.hashCode +
        image.hashCode +
        url.hashCode +
        createdAt.hashCode;

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// pending = uploaded, not attached yet; ticket = the task description; answer = an answer (see questionId); retry = a retry note; feedback = requested changes; chat = a team chat message; assistant = an AI chat question
enum AttachmentPurposeEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'ticket')
ticket(r'ticket'),
@JsonValue(r'answer')
answer(r'answer'),
@JsonValue(r'retry')
retry(r'retry'),
@JsonValue(r'feedback')
feedback(r'feedback'),
@JsonValue(r'chat')
chat(r'chat'),
@JsonValue(r'assistant')
assistant(r'assistant');

const AttachmentPurposeEnum(this.value);

final String value;

@override
String toString() => value;
}


