//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'approve_ticket_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApproveTicketRequest {
  /// Returns a new [ApproveTicketRequest] instance.
  ApproveTicketRequest({

     this.assignees,

     this.postReport,
  });

      /// Git host usernames to assign the pull request to (changes only)
  @JsonKey(
    
    name: r'assignees',
    required: false,
    includeIfNull: false,
  )


  final List<String>? assignees;



      /// Post the approved report as a comment on the tracker issue (reports only)
  @JsonKey(
    
    name: r'postReport',
    required: false,
    includeIfNull: false,
  )


  final bool? postReport;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ApproveTicketRequest &&
      other.assignees == assignees &&
      other.postReport == postReport;

    @override
    int get hashCode =>
        assignees.hashCode +
        postReport.hashCode;

  factory ApproveTicketRequest.fromJson(Map<String, dynamic> json) => _$ApproveTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ApproveTicketRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

