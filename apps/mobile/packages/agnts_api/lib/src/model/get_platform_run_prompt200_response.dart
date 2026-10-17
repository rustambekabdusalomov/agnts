//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_platform_run_prompt200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GetPlatformRunPrompt200Response {
  /// Returns a new [GetPlatformRunPrompt200Response] instance.
  GetPlatformRunPrompt200Response({

    required  this.prompt,
  });

  @JsonKey(
    
    name: r'prompt',
    required: true,
    includeIfNull: false,
  )


  final String prompt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GetPlatformRunPrompt200Response &&
      other.prompt == prompt;

    @override
    int get hashCode =>
        prompt.hashCode;

  factory GetPlatformRunPrompt200Response.fromJson(Map<String, dynamic> json) => _$GetPlatformRunPrompt200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetPlatformRunPrompt200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

