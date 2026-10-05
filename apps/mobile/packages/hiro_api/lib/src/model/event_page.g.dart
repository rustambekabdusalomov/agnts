// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_page.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EventPageCWProxy {
  EventPage events(List<Event> events);

  EventPage nextBefore(int? nextBefore);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EventPage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EventPage(...).copyWith(id: 12, name: "My name")
  /// ````
  EventPage call({List<Event> events, int? nextBefore});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEventPage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEventPage.copyWith.fieldName(...)`
class _$EventPageCWProxyImpl implements _$EventPageCWProxy {
  const _$EventPageCWProxyImpl(this._value);

  final EventPage _value;

  @override
  EventPage events(List<Event> events) => this(events: events);

  @override
  EventPage nextBefore(int? nextBefore) => this(nextBefore: nextBefore);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EventPage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EventPage(...).copyWith(id: 12, name: "My name")
  /// ````
  EventPage call({
    Object? events = const $CopyWithPlaceholder(),
    Object? nextBefore = const $CopyWithPlaceholder(),
  }) {
    return EventPage(
      events: events == const $CopyWithPlaceholder()
          ? _value.events
          // ignore: cast_nullable_to_non_nullable
          : events as List<Event>,
      nextBefore: nextBefore == const $CopyWithPlaceholder()
          ? _value.nextBefore
          // ignore: cast_nullable_to_non_nullable
          : nextBefore as int?,
    );
  }
}

extension $EventPageCopyWith on EventPage {
  /// Returns a callable class that can be used as follows: `instanceOfEventPage.copyWith(...)` or like so:`instanceOfEventPage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EventPageCWProxy get copyWith => _$EventPageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventPage _$EventPageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EventPage', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['events']);
      final val = EventPage(
        events: $checkedConvert(
          'events',
          (v) => (v as List<dynamic>)
              .map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextBefore: $checkedConvert('nextBefore', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$EventPageToJson(EventPage instance) => <String, dynamic>{
  'events': instance.events.map((e) => e.toJson()).toList(),
  'nextBefore': ?instance.nextBefore,
};
