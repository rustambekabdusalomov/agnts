//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rename_ticket_branch_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RenameTicketBranchRequest {
  /// Returns a new [RenameTicketBranchRequest] instance.
  RenameTicketBranchRequest({

    required  this.branch,

     this.repoId,
  });

      /// The new name, as git takes it (no spaces, no .. or //)
  @JsonKey(
    
    name: r'branch',
    required: true,
    includeIfNull: false,
  )


  final String branch;



      /// Which repository of the ticket; absent is the primary
  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RenameTicketBranchRequest &&
      other.branch == branch &&
      other.repoId == repoId;

    @override
    int get hashCode =>
        branch.hashCode +
        repoId.hashCode;

  factory RenameTicketBranchRequest.fromJson(Map<String, dynamic> json) => _$RenameTicketBranchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RenameTicketBranchRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

