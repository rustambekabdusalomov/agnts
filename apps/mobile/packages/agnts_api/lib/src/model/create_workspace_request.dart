//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_workspace_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateWorkspaceRequest {
  /// Returns a new [CreateWorkspaceRequest] instance.
  CreateWorkspaceRequest({

    required  this.name,

     this.slug,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// The address in links; derived from the name when empty
  @JsonKey(
    
    name: r'slug',
    required: false,
    includeIfNull: false,
  )


  final String? slug;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateWorkspaceRequest &&
      other.name == name &&
      other.slug == slug;

    @override
    int get hashCode =>
        name.hashCode +
        slug.hashCode;

  factory CreateWorkspaceRequest.fromJson(Map<String, dynamic> json) => _$CreateWorkspaceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateWorkspaceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

