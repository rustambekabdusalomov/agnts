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





    @override
    bool operator ==(Object other) => identical(this, other) || other is RetryTicketRequest &&
      other.note == note &&
      other.attachments == attachments;

    @override
    int get hashCode =>
        note.hashCode +
        attachments.hashCode;

  factory RetryTicketRequest.fromJson(Map<String, dynamic> json) => _$RetryTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RetryTicketRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

