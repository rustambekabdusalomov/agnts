// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_ticket_link.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingTicketLinkCWProxy {
  MeetingTicketLink meetingId(int meetingId);

  MeetingTicketLink meetingTitle(String meetingTitle);

  MeetingTicketLink meetingCode(String meetingCode);

  MeetingTicketLink sessionId(int? sessionId);

  MeetingTicketLink ticketKey(String ticketKey);

  MeetingTicketLink quote(String quote);

  MeetingTicketLink createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingTicketLink(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingTicketLink(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingTicketLink call({
    int meetingId,
    String meetingTitle,
    String meetingCode,
    int? sessionId,
    String ticketKey,
    String quote,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingTicketLink.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingTicketLink.copyWith.fieldName(...)`
class _$MeetingTicketLinkCWProxyImpl implements _$MeetingTicketLinkCWProxy {
  const _$MeetingTicketLinkCWProxyImpl(this._value);

  final MeetingTicketLink _value;

  @override
  MeetingTicketLink meetingId(int meetingId) => this(meetingId: meetingId);

  @override
  MeetingTicketLink meetingTitle(String meetingTitle) =>
      this(meetingTitle: meetingTitle);

  @override
  MeetingTicketLink meetingCode(String meetingCode) =>
      this(meetingCode: meetingCode);

  @override
  MeetingTicketLink sessionId(int? sessionId) => this(sessionId: sessionId);

  @override
  MeetingTicketLink ticketKey(String ticketKey) => this(ticketKey: ticketKey);

  @override
  MeetingTicketLink quote(String quote) => this(quote: quote);

  @override
  MeetingTicketLink createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingTicketLink(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingTicketLink(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingTicketLink call({
    Object? meetingId = const $CopyWithPlaceholder(),
    Object? meetingTitle = const $CopyWithPlaceholder(),
    Object? meetingCode = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? quote = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return MeetingTicketLink(
      meetingId: meetingId == const $CopyWithPlaceholder()
          ? _value.meetingId
          // ignore: cast_nullable_to_non_nullable
          : meetingId as int,
      meetingTitle: meetingTitle == const $CopyWithPlaceholder()
          ? _value.meetingTitle
          // ignore: cast_nullable_to_non_nullable
          : meetingTitle as String,
      meetingCode: meetingCode == const $CopyWithPlaceholder()
          ? _value.meetingCode
          // ignore: cast_nullable_to_non_nullable
          : meetingCode as String,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as int?,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String,
      quote: quote == const $CopyWithPlaceholder()
          ? _value.quote
          // ignore: cast_nullable_to_non_nullable
          : quote as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $MeetingTicketLinkCopyWith on MeetingTicketLink {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingTicketLink.copyWith(...)` or like so:`instanceOfMeetingTicketLink.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingTicketLinkCWProxy get copyWith =>
      _$MeetingTicketLinkCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingTicketLink _$MeetingTicketLinkFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingTicketLink', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'meetingId',
          'meetingTitle',
          'meetingCode',
          'ticketKey',
          'quote',
          'createdAt',
        ],
      );
      final val = MeetingTicketLink(
        meetingId: $checkedConvert('meetingId', (v) => (v as num).toInt()),
        meetingTitle: $checkedConvert('meetingTitle', (v) => v as String),
        meetingCode: $checkedConvert('meetingCode', (v) => v as String),
        sessionId: $checkedConvert('sessionId', (v) => (v as num?)?.toInt()),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String),
        quote: $checkedConvert('quote', (v) => v as String),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeetingTicketLinkToJson(MeetingTicketLink instance) =>
    <String, dynamic>{
      'meetingId': instance.meetingId,
      'meetingTitle': instance.meetingTitle,
      'meetingCode': instance.meetingCode,
      'sessionId': ?instance.sessionId,
      'ticketKey': instance.ticketKey,
      'quote': instance.quote,
      'createdAt': instance.createdAt.toIso8601String(),
    };
