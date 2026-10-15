//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'swagger_spec_choices_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SwaggerSpecChoicesInner {
  /// Returns a new [SwaggerSpecChoicesInner] instance.
  SwaggerSpecChoicesInner({

     this.name,

    required  this.url,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SwaggerSpecChoicesInner &&
      other.name == name &&
      other.url == url;

    @override
    int get hashCode =>
        name.hashCode +
        url.hashCode;

  factory SwaggerSpecChoicesInner.fromJson(Map<String, dynamic> json) => _$SwaggerSpecChoicesInnerFromJson(json);

  Map<String, dynamic> toJson() => _$SwaggerSpecChoicesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

