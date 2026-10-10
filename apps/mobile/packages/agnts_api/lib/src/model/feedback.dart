//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feedback.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Feedback {
  /// Returns a new [Feedback] instance.
  Feedback({

    required  this.id,

    required  this.kind,

    required  this.title,

    required  this.description,

    required  this.status,

    required  this.sender,

     this.email,

     this.userId,

     this.workspace,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// feedback: sent from an account; connector: a connector request from the website
  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final FeedbackKindEnum kind;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final FeedbackStatusEnum status;



      /// The sender's name when they sent it
  @JsonKey(
    
    name: r'sender',
    required: true,
    includeIfNull: false,
  )


  final String sender;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



      /// Absent once the account is deleted
  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final int? userId;



      /// The name of the workspace it was sent from
  @JsonKey(
    
    name: r'workspace',
    required: false,
    includeIfNull: false,
  )


  final String? workspace;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Feedback &&
      other.id == id &&
      other.kind == kind &&
      other.title == title &&
      other.description == description &&
      other.status == status &&
      other.sender == sender &&
      other.email == email &&
      other.userId == userId &&
      other.workspace == workspace &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        title.hashCode +
        description.hashCode +
        status.hashCode +
        sender.hashCode +
        email.hashCode +
        userId.hashCode +
        workspace.hashCode +
        createdAt.hashCode;

  factory Feedback.fromJson(Map<String, dynamic> json) => _$FeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$FeedbackToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// feedback: sent from an account; connector: a connector request from the website
enum FeedbackKindEnum {
@JsonValue(r'feedback')
feedback(r'feedback'),
@JsonValue(r'connector')
connector(r'connector');

const FeedbackKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum FeedbackStatusEnum {
@JsonValue(r'new')
new_(r'new'),
@JsonValue(r'done')
done(r'done');

const FeedbackStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


