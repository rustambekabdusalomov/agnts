//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presence_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PresenceInput {
  /// Returns a new [PresenceInput] instance.
  PresenceInput({

     this.leaving,
  });

  @JsonKey(
    
    name: r'leaving',
    required: false,
    includeIfNull: false,
  )


  final bool? leaving;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PresenceInput &&
      other.leaving == leaving;

    @override
    int get hashCode =>
        leaving.hashCode;

  factory PresenceInput.fromJson(Map<String, dynamic> json) => _$PresenceInputFromJson(json);

  Map<String, dynamic> toJson() => _$PresenceInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

