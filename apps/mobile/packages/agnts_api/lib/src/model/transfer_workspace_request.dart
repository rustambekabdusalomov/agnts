//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transfer_workspace_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TransferWorkspaceRequest {
  /// Returns a new [TransferWorkspaceRequest] instance.
  TransferWorkspaceRequest({

    required  this.userId,
  });

  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final int userId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TransferWorkspaceRequest &&
      other.userId == userId;

    @override
    int get hashCode =>
        userId.hashCode;

  factory TransferWorkspaceRequest.fromJson(Map<String, dynamic> json) => _$TransferWorkspaceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransferWorkspaceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

