//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_jira200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SyncJira200Response {
  /// Returns a new [SyncJira200Response] instance.
  SyncJira200Response({

    required  this.found,

    required  this.created,
  });

  @JsonKey(
    
    name: r'found',
    required: true,
    includeIfNull: false,
  )


  final int found;



  @JsonKey(
    
    name: r'created',
    required: true,
    includeIfNull: false,
  )


  final int created;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SyncJira200Response &&
      other.found == found &&
      other.created == created;

    @override
    int get hashCode =>
        found.hashCode +
        created.hashCode;

  factory SyncJira200Response.fromJson(Map<String, dynamic> json) => _$SyncJira200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SyncJira200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

