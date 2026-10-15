//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_pull_comments_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AddressPullCommentsRequest {
  /// Returns a new [AddressPullCommentsRequest] instance.
  AddressPullCommentsRequest({

     this.threadIds,
  });

  @JsonKey(
    
    name: r'threadIds',
    required: false,
    includeIfNull: false,
  )


  final List<String>? threadIds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AddressPullCommentsRequest &&
      other.threadIds == threadIds;

    @override
    int get hashCode =>
        threadIds.hashCode;

  factory AddressPullCommentsRequest.fromJson(Map<String, dynamic> json) => _$AddressPullCommentsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddressPullCommentsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

