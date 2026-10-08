//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_feedback_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendFeedbackRequest {
  /// Returns a new [SendFeedbackRequest] instance.
  SendFeedbackRequest({

    required  this.title,

    required  this.description,

     this.workspace,
  });

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



      /// The slug of the workspace it is sent from (yours), for context
  @JsonKey(
    
    name: r'workspace',
    required: false,
    includeIfNull: false,
  )


  final String? workspace;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SendFeedbackRequest &&
      other.title == title &&
      other.description == description &&
      other.workspace == workspace;

    @override
    int get hashCode =>
        title.hashCode +
        description.hashCode +
        workspace.hashCode;

  factory SendFeedbackRequest.fromJson(Map<String, dynamic> json) => _$SendFeedbackRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendFeedbackRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

