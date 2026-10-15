//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rotate_swagger_suite_hook200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RotateSwaggerSuiteHook200Response {
  /// Returns a new [RotateSwaggerSuiteHook200Response] instance.
  RotateSwaggerSuiteHook200Response({

    required  this.url,
  });

  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RotateSwaggerSuiteHook200Response &&
      other.url == url;

    @override
    int get hashCode =>
        url.hashCode;

  factory RotateSwaggerSuiteHook200Response.fromJson(Map<String, dynamic> json) => _$RotateSwaggerSuiteHook200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RotateSwaggerSuiteHook200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

