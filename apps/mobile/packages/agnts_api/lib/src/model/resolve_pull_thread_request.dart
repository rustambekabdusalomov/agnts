//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'resolve_pull_thread_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResolvePullThreadRequest {
  /// Returns a new [ResolvePullThreadRequest] instance.
  ResolvePullThreadRequest({

    required  this.threadId,

    required  this.resolved,
  });

  @JsonKey(
    
    name: r'threadId',
    required: true,
    includeIfNull: false,
  )


  final String threadId;



  @JsonKey(
    
    name: r'resolved',
    required: true,
    includeIfNull: false,
  )


  final bool resolved;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ResolvePullThreadRequest &&
      other.threadId == threadId &&
      other.resolved == resolved;

    @override
    int get hashCode =>
        threadId.hashCode +
        resolved.hashCode;

  factory ResolvePullThreadRequest.fromJson(Map<String, dynamic> json) => _$ResolvePullThreadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResolvePullThreadRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

