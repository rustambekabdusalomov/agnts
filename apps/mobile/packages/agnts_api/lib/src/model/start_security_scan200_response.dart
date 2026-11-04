//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/security_scan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'start_security_scan200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StartSecurityScan200Response {
  /// Returns a new [StartSecurityScan200Response] instance.
  StartSecurityScan200Response({

    required  this.scan,

    required  this.queued,
  });

  @JsonKey(
    
    name: r'scan',
    required: true,
    includeIfNull: false,
  )


  final SecurityScan scan;



  @JsonKey(
    
    name: r'queued',
    required: true,
    includeIfNull: false,
  )


  final bool queued;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StartSecurityScan200Response &&
      other.scan == scan &&
      other.queued == queued;

    @override
    int get hashCode =>
        scan.hashCode +
        queued.hashCode;

  factory StartSecurityScan200Response.fromJson(Map<String, dynamic> json) => _$StartSecurityScan200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StartSecurityScan200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

