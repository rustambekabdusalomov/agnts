//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/module.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_user_modules_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetUserModulesRequest {
  /// Returns a new [SetUserModulesRequest] instance.
  SetUserModulesRequest({

     this.modules,
  });

  @JsonKey(
    
    name: r'modules',
    required: false,
    includeIfNull: false,
  )


  final List<Module>? modules;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetUserModulesRequest &&
      other.modules == modules;

    @override
    int get hashCode =>
        (modules == null ? 0 : modules.hashCode);

  factory SetUserModulesRequest.fromJson(Map<String, dynamic> json) => _$SetUserModulesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetUserModulesRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

