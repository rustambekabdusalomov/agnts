//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_repo_pull409_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewRepoPull409Response {
  /// Returns a new [ReviewRepoPull409Response] instance.
  ReviewRepoPull409Response({

    required  this.code,

    required  this.message,

    required  this.ticketKey,
  });

  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'ticketKey',
    required: true,
    includeIfNull: false,
  )


  final String ticketKey;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewRepoPull409Response &&
      other.code == code &&
      other.message == message &&
      other.ticketKey == ticketKey;

    @override
    int get hashCode =>
        code.hashCode +
        message.hashCode +
        ticketKey.hashCode;

  factory ReviewRepoPull409Response.fromJson(Map<String, dynamic> json) => _$ReviewRepoPull409ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewRepoPull409ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

