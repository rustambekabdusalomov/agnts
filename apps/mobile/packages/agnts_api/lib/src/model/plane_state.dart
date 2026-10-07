//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plane_state.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlaneState {
  /// Returns a new [PlaneState] instance.
  PlaneState({

    required  this.name,

    required  this.group,

    required  this.projects,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'group',
    required: true,
    includeIfNull: false,
  )


  final PlaneStateGroupEnum group;



      /// Identifiers of the linked projects that have this state
  @JsonKey(
    
    name: r'projects',
    required: true,
    includeIfNull: false,
  )


  final List<String> projects;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlaneState &&
      other.name == name &&
      other.group == group &&
      other.projects == projects;

    @override
    int get hashCode =>
        name.hashCode +
        group.hashCode +
        projects.hashCode;

  factory PlaneState.fromJson(Map<String, dynamic> json) => _$PlaneStateFromJson(json);

  Map<String, dynamic> toJson() => _$PlaneStateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PlaneStateGroupEnum {
@JsonValue(r'backlog')
backlog(r'backlog'),
@JsonValue(r'unstarted')
unstarted(r'unstarted'),
@JsonValue(r'started')
started(r'started'),
@JsonValue(r'completed')
completed(r'completed'),
@JsonValue(r'cancelled')
cancelled(r'cancelled'),
@JsonValue(r'triage')
triage(r'triage');

const PlaneStateGroupEnum(this.value);

final String value;

@override
String toString() => value;
}


