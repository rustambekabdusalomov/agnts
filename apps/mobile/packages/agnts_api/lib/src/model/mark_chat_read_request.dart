//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mark_chat_read_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MarkChatReadRequest {
  /// Returns a new [MarkChatReadRequest] instance.
  MarkChatReadRequest({

    required  this.lastReadId,
  });

  @JsonKey(
    
    name: r'lastReadId',
    required: true,
    includeIfNull: false,
  )


  final int lastReadId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MarkChatReadRequest &&
      other.lastReadId == lastReadId;

    @override
    int get hashCode =>
        lastReadId.hashCode;

  factory MarkChatReadRequest.fromJson(Map<String, dynamic> json) => _$MarkChatReadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MarkChatReadRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

