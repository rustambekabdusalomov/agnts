//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'set_slots_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetSlotsRequest {
  /// Returns a new [SetSlotsRequest] instance.
  SetSlotsRequest({

    required  this.slots,
  });

      /// At most AGNTS_MAX_SLOTS (5 by default)
          // minimum: 1
          // maximum: 50
  @JsonKey(
    
    name: r'slots',
    required: true,
    includeIfNull: false,
  )


  final int slots;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SetSlotsRequest &&
      other.slots == slots;

    @override
    int get hashCode =>
        slots.hashCode;

  factory SetSlotsRequest.fromJson(Map<String, dynamic> json) => _$SetSlotsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetSlotsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

