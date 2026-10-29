//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'retry_ticket_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RetryTicketRequest {
  /// Returns a new [RetryTicketRequest] instance.
  RetryTicketRequest({

     this.note,

     this.attachments,

     this.skipChecks,

     this.discardWork,
  });

      /// How to get past the failure. The next coding run gets it with the error, like requested changes. Not allowed when the ticket resumes at pushing, since no Claude run follows.
  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;



      /// Uploads that help get past the failure; the next coding run reads them. Same rule as note.
  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<int>? attachments;



      /// Skip the build, lint and test checks (and the proof and coverage that run tests) in this and later coding runs of the ticket, going to review on the code alone; false turns them back on. Left out, the ticket keeps its setting.
  @JsonKey(
    
    name: r'skipChecks',
    required: false,
    includeIfNull: false,
  )


  final bool? skipChecks;



      /// Throw away the unfinished change a stopped run left (the ticket's savedWork); the next coding run starts from the last commit instead.
  @JsonKey(
    
    name: r'discardWork',
    required: false,
    includeIfNull: false,
  )


  final bool? discardWork;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RetryTicketRequest &&
      other.note == note &&
      other.attachments == attachments &&
      other.skipChecks == skipChecks &&
      other.discardWork == discardWork;

    @override
    int get hashCode =>
        note.hashCode +
        attachments.hashCode +
        skipChecks.hashCode +
        discardWork.hashCode;

  factory RetryTicketRequest.fromJson(Map<String, dynamic> json) => _$RetryTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RetryTicketRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

