//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_finding_location.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecurityFindingLocation {
  /// Returns a new [SecurityFindingLocation] instance.
  SecurityFindingLocation({

     this.file,

     this.line,

     this.url,
  });

  @JsonKey(
    
    name: r'file',
    required: false,
    includeIfNull: false,
  )


  final String? file;



  @JsonKey(
    
    name: r'line',
    required: false,
    includeIfNull: false,
  )


  final int? line;



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SecurityFindingLocation &&
      other.file == file &&
      other.line == line &&
      other.url == url;

    @override
    int get hashCode =>
        file.hashCode +
        line.hashCode +
        url.hashCode;

  factory SecurityFindingLocation.fromJson(Map<String, dynamic> json) => _$SecurityFindingLocationFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityFindingLocationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

