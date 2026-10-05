//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/event.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_page.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventPage {
  /// Returns a new [EventPage] instance.
  EventPage({

    required  this.events,

     this.nextBefore,
  });

  @JsonKey(
    
    name: r'events',
    required: true,
    includeIfNull: false,
  )


  final List<Event> events;



  @JsonKey(
    
    name: r'nextBefore',
    required: false,
    includeIfNull: false,
  )


  final int? nextBefore;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EventPage &&
      other.events == events &&
      other.nextBefore == nextBefore;

    @override
    int get hashCode =>
        events.hashCode +
        nextBefore.hashCode;

  factory EventPage.fromJson(Map<String, dynamic> json) => _$EventPageFromJson(json);

  Map<String, dynamic> toJson() => _$EventPageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

