//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_rights.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingRights {
  /// Returns a new [MeetingRights] instance.
  MeetingRights({

    required  this.publish,

    required  this.screenShare,

    required  this.chat,

    required  this.admit,

    required  this.moderate,

    required  this.record,

    required  this.manageCohosts,
  });

  @JsonKey(
    
    name: r'publish',
    required: true,
    includeIfNull: false,
  )


  final bool publish;



  @JsonKey(
    
    name: r'screenShare',
    required: true,
    includeIfNull: false,
  )


  final bool screenShare;



  @JsonKey(
    
    name: r'chat',
    required: true,
    includeIfNull: false,
  )


  final bool chat;



  @JsonKey(
    
    name: r'admit',
    required: true,
    includeIfNull: false,
  )


  final bool admit;



  @JsonKey(
    
    name: r'moderate',
    required: true,
    includeIfNull: false,
  )


  final bool moderate;



  @JsonKey(
    
    name: r'record',
    required: true,
    includeIfNull: false,
  )


  final bool record;



  @JsonKey(
    
    name: r'manageCohosts',
    required: true,
    includeIfNull: false,
  )


  final bool manageCohosts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingRights &&
      other.publish == publish &&
      other.screenShare == screenShare &&
      other.chat == chat &&
      other.admit == admit &&
      other.moderate == moderate &&
      other.record == record &&
      other.manageCohosts == manageCohosts;

    @override
    int get hashCode =>
        publish.hashCode +
        screenShare.hashCode +
        chat.hashCode +
        admit.hashCode +
        moderate.hashCode +
        record.hashCode +
        manageCohosts.hashCode;

  factory MeetingRights.fromJson(Map<String, dynamic> json) => _$MeetingRightsFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingRightsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

