//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/ticket.dart';
import 'package:agnts_api/src/model/reapply_commit_format200_response_changes_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reapply_commit_format200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReapplyCommitFormat200Response {
  /// Returns a new [ReapplyCommitFormat200Response] instance.
  ReapplyCommitFormat200Response({

    required  this.changes,

    required  this.ticket,
  });

  @JsonKey(
    
    name: r'changes',
    required: true,
    includeIfNull: false,
  )


  final List<ReapplyCommitFormat200ResponseChangesInner> changes;



  @JsonKey(
    
    name: r'ticket',
    required: true,
    includeIfNull: false,
  )


  final Ticket ticket;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReapplyCommitFormat200Response &&
      other.changes == changes &&
      other.ticket == ticket;

    @override
    int get hashCode =>
        changes.hashCode +
        ticket.hashCode;

  factory ReapplyCommitFormat200Response.fromJson(Map<String, dynamic> json) => _$ReapplyCommitFormat200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReapplyCommitFormat200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

