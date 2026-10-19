//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/assistant_link.dart';
import 'package:agnts_api/src/model/assistant_language.dart';
import 'package:agnts_api/src/model/assistant_action.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_message.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantMessage {
  /// Returns a new [AssistantMessage] instance.
  AssistantMessage({

    required  this.id,

    required  this.role,

    required  this.text,

    required  this.speech,

    required  this.links,

    required  this.status,

     this.error,

    required  this.lang,

     this.durationMs,

     this.files,

    required  this.rating,

     this.ratingComment,

    required  this.shared,

     this.actions,

     this.actionErrors,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final AssistantMessageRoleEnum role;



      /// The question, or the answer in Markdown
  @JsonKey(
    
    name: r'text',
    required: true,
    includeIfNull: false,
  )


  final String text;



      /// The answer in 1-3 plain sentences (empty for questions)
  @JsonKey(
    
    name: r'speech',
    required: true,
    includeIfNull: false,
  )


  final String speech;



  @JsonKey(
    
    name: r'links',
    required: true,
    includeIfNull: false,
  )


  final List<AssistantLink> links;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final AssistantMessageStatusEnum status;



      /// Why the answer failed
  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false,
  )


  final String? error;



  @JsonKey(
    
    name: r'lang',
    required: true,
    includeIfNull: false,
  )


  final AssistantLanguage lang;



  @JsonKey(
    
    name: r'durationMs',
    required: false,
    includeIfNull: false,
  )


  final int? durationMs;



      /// The snapshot files the answer was made from
  @JsonKey(
    
    name: r'files',
    required: false,
    includeIfNull: false,
  )


  final List<String>? files;



      /// Your rating: 1 helpful, -1 not, 0 none
  @JsonKey(
    
    name: r'rating',
    required: true,
    includeIfNull: false,
  )


  final AssistantMessageRatingEnum rating;



  @JsonKey(
    
    name: r'ratingComment',
    required: false,
    includeIfNull: false,
  )


  final String? ratingComment;



      /// The answer's snapshot is kept for prompt tests
  @JsonKey(
    
    name: r'shared',
    required: true,
    includeIfNull: false,
  )


  final bool shared;



      /// Actions the answer proposes, each waiting for you to confirm
  @JsonKey(
    
    name: r'actions',
    required: false,
    includeIfNull: false,
  )


  final List<AssistantAction>? actions;



      /// Actions the assistant tried to propose that agnts could not prepare, and why
  @JsonKey(
    
    name: r'actionErrors',
    required: false,
    includeIfNull: false,
  )


  final List<String>? actionErrors;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantMessage &&
      other.id == id &&
      other.role == role &&
      other.text == text &&
      other.speech == speech &&
      other.links == links &&
      other.status == status &&
      other.error == error &&
      other.lang == lang &&
      other.durationMs == durationMs &&
      other.files == files &&
      other.rating == rating &&
      other.ratingComment == ratingComment &&
      other.shared == shared &&
      other.actions == actions &&
      other.actionErrors == actionErrors &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        role.hashCode +
        text.hashCode +
        speech.hashCode +
        links.hashCode +
        status.hashCode +
        error.hashCode +
        lang.hashCode +
        durationMs.hashCode +
        files.hashCode +
        rating.hashCode +
        ratingComment.hashCode +
        shared.hashCode +
        actions.hashCode +
        actionErrors.hashCode +
        createdAt.hashCode;

  factory AssistantMessage.fromJson(Map<String, dynamic> json) => _$AssistantMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantMessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AssistantMessageRoleEnum {
@JsonValue(r'user')
user(r'user'),
@JsonValue(r'assistant')
assistant(r'assistant');

const AssistantMessageRoleEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AssistantMessageStatusEnum {
@JsonValue(r'pending')
pending(r'pending'),
@JsonValue(r'answering')
answering(r'answering'),
@JsonValue(r'done')
done(r'done'),
@JsonValue(r'failed')
failed(r'failed');

const AssistantMessageStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


/// Your rating: 1 helpful, -1 not, 0 none
enum AssistantMessageRatingEnum {
@JsonValue(-1)
numberNegative1('-1'),
@JsonValue(0)
number0('0'),
@JsonValue(1)
number1('1');

const AssistantMessageRatingEnum(this.value);

final String value;

@override
String toString() => value;
}


