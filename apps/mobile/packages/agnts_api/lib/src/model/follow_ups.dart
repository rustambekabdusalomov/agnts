//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/follow_up_ticket.dart';
import 'package:agnts_api/src/model/follow_up_suggestion.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'follow_ups.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FollowUps {
  /// Returns a new [FollowUps] instance.
  FollowUps({

    required  this.enabled,

    required  this.suggestions,

    required  this.children,
  });

      /// This ticket's runs suggest follow-ups
  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



  @JsonKey(
    
    name: r'suggestions',
    required: true,
    includeIfNull: false,
  )


  final List<FollowUpSuggestion> suggestions;



      /// Tickets made from the suggestions
  @JsonKey(
    
    name: r'children',
    required: true,
    includeIfNull: false,
  )


  final List<FollowUpTicket> children;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FollowUps &&
      other.enabled == enabled &&
      other.suggestions == suggestions &&
      other.children == children;

    @override
    int get hashCode =>
        enabled.hashCode +
        suggestions.hashCode +
        children.hashCode;

  factory FollowUps.fromJson(Map<String, dynamic> json) => _$FollowUpsFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUpsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

