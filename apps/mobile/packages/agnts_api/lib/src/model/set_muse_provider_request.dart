//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/muse_provider_mode.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_muse_provider_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetMuseProviderRequest {
  /// Returns a new [SetMuseProviderRequest] instance.
  SetMuseProviderRequest({

    required  this.mode,
  });

  @JsonKey(
    
    name: r'mode',
    required: true,
    includeIfNull: false,
  )


  final MuseProviderMode mode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetMuseProviderRequest &&
      other.mode == mode;

    @override
    int get hashCode =>
        mode.hashCode;

  factory SetMuseProviderRequest.fromJson(Map<String, dynamic> json) => _$SetMuseProviderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetMuseProviderRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

