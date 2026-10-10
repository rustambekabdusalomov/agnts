//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tracker_update.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TrackerUpdate {
  /// Returns a new [TrackerUpdate] instance.
  TrackerUpdate({

    required  this.title,

    required  this.description,

    required  this.at,
  });

  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



      /// When agnts saw it
  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TrackerUpdate &&
      other.title == title &&
      other.description == description &&
      other.at == at;

    @override
    int get hashCode =>
        title.hashCode +
        description.hashCode +
        at.hashCode;

  factory TrackerUpdate.fromJson(Map<String, dynamic> json) => _$TrackerUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$TrackerUpdateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

