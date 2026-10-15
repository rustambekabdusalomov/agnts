//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_rerun_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerRerunInput {
  /// Returns a new [SwaggerRerunInput] instance.
  SwaggerRerunInput({

     this.token,
  });

      /// A new token; required for a closed test with auth
  @JsonKey(
    
    name: r'token',
    required: false,
    includeIfNull: false,
  )


  final String? token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerRerunInput &&
      other.token == token;

    @override
    int get hashCode =>
        token.hashCode;

  factory SwaggerRerunInput.fromJson(Map<String, dynamic> json) => _$SwaggerRerunInputFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerRerunInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

