//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_plane200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SyncPlane200Response {
  /// Returns a new [SyncPlane200Response] instance.
  SyncPlane200Response({

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
    bool operator ==(Object other) => identical(this, other) || other is SyncPlane200Response &&
      other.found == found &&
      other.created == created;

    @override
    int get hashCode =>
        found.hashCode +
        created.hashCode;

  factory SyncPlane200Response.fromJson(Map<String, dynamic> json) => _$SyncPlane200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SyncPlane200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

