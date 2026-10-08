//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_workspace_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateWorkspaceRequest {
  /// Returns a new [UpdateWorkspaceRequest] instance.
  UpdateWorkspaceRequest({

     this.name,

     this.slug,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'slug',
    required: false,
    includeIfNull: false,
  )


  final String? slug;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateWorkspaceRequest &&
      other.name == name &&
      other.slug == slug;

    @override
    int get hashCode =>
        name.hashCode +
        slug.hashCode;

  factory UpdateWorkspaceRequest.fromJson(Map<String, dynamic> json) => _$UpdateWorkspaceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateWorkspaceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

