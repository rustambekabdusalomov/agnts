//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delete_workspace_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeleteWorkspaceRequest {
  /// Returns a new [DeleteWorkspaceRequest] instance.
  DeleteWorkspaceRequest({

    required  this.confirm,
  });

      /// The workspace's address, typed to confirm
  @JsonKey(
    
    name: r'confirm',
    required: true,
    includeIfNull: false,
  )


  final String confirm;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeleteWorkspaceRequest &&
      other.confirm == confirm;

    @override
    int get hashCode =>
        confirm.hashCode;

  factory DeleteWorkspaceRequest.fromJson(Map<String, dynamic> json) => _$DeleteWorkspaceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteWorkspaceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

