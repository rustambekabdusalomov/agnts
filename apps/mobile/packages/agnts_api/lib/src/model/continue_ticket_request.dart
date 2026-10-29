//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'continue_ticket_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ContinueTicketRequest {
  /// Returns a new [ContinueTicketRequest] instance.
  ContinueTicketRequest({

     this.note,

     this.attachments,

     this.discardWork,
  });

      /// What to do differently. The next coding run gets it, like requested changes. Not allowed when the ticket goes back to answers or to a failed state, since no Claude run follows.
  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;



      /// Uploads that go with the note; the next coding run reads them. Same rule as note.
  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<int>? attachments;



      /// Throw away the unfinished change a stopped run left (the ticket's savedWork); the next coding run starts from the last commit instead.
  @JsonKey(
    
    name: r'discardWork',
    required: false,
    includeIfNull: false,
  )


  final bool? discardWork;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ContinueTicketRequest &&
      other.note == note &&
      other.attachments == attachments &&
      other.discardWork == discardWork;

    @override
    int get hashCode =>
        note.hashCode +
        attachments.hashCode +
        discardWork.hashCode;

  factory ContinueTicketRequest.fromJson(Map<String, dynamic> json) => _$ContinueTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ContinueTicketRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

