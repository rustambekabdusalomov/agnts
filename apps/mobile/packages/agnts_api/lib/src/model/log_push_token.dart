//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_push_token.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogPushToken {
  /// Returns a new [LogPushToken] instance.
  LogPushToken({

    required  this.token,

    required  this.url,
  });

  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogPushToken &&
      other.token == token &&
      other.url == url;

    @override
    int get hashCode =>
        token.hashCode +
        url.hashCode;

  factory LogPushToken.fromJson(Map<String, dynamic> json) => _$LogPushTokenFromJson(json);

  Map<String, dynamic> toJson() => _$LogPushTokenToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

