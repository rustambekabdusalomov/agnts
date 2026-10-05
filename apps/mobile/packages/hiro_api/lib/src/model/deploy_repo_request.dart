//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deploy_repo_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeployRepoRequest {
  /// Returns a new [DeployRepoRequest] instance.
  DeployRepoRequest({

     this.jobId,

     this.ref,
  });

      /// GitLab manual job to start
  @JsonKey(
    
    name: r'jobId',
    required: false,
    includeIfNull: false,
  )


  final int? jobId;



      /// GitHub: branch to deploy (default branch if empty)
  @JsonKey(
    
    name: r'ref',
    required: false,
    includeIfNull: false,
  )


  final String? ref;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeployRepoRequest &&
      other.jobId == jobId &&
      other.ref == ref;

    @override
    int get hashCode =>
        jobId.hashCode +
        ref.hashCode;

  factory DeployRepoRequest.fromJson(Map<String, dynamic> json) => _$DeployRepoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeployRepoRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

