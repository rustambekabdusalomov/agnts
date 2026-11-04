//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'remove_chat_ref_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RemoveChatRefRequest {
  /// Returns a new [RemoveChatRefRequest] instance.
  RemoveChatRefRequest({

    required  this.type,

    required  this.id,
  });

  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final String type;



  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RemoveChatRefRequest &&
      other.type == type &&
      other.id == id;

    @override
    int get hashCode =>
        type.hashCode +
        id.hashCode;

  factory RemoveChatRefRequest.fromJson(Map<String, dynamic> json) => _$RemoveChatRefRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RemoveChatRefRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

