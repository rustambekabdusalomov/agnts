//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shot_ref.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShotRef {
  /// Returns a new [ShotRef] instance.
  ShotRef({

    required  this.runId,

    required  this.shotId,
  });

  @JsonKey(
    
    name: r'runId',
    required: true,
    includeIfNull: false,
  )


  final int runId;



  @JsonKey(
    
    name: r'shotId',
    required: true,
    includeIfNull: false,
  )


  final String shotId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShotRef &&
      other.runId == runId &&
      other.shotId == shotId;

    @override
    int get hashCode =>
        runId.hashCode +
        shotId.hashCode;

  factory ShotRef.fromJson(Map<String, dynamic> json) => _$ShotRefFromJson(json);

  Map<String, dynamic> toJson() => _$ShotRefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

