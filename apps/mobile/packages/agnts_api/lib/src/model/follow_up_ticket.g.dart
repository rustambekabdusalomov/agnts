// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_up_ticket.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FollowUpTicketCWProxy {
  FollowUpTicket key(String key);

  FollowUpTicket title(String title);

  FollowUpTicket state(TicketState state);

  FollowUpTicket kind(TicketKind kind);

  FollowUpTicket source_(FollowUpTicketSource_Enum source_);

  FollowUpTicket held(bool? held);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowUpTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowUpTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowUpTicket call({
    String key,
    String title,
    TicketState state,
    TicketKind kind,
    FollowUpTicketSource_Enum source_,
    bool? held,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFollowUpTicket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFollowUpTicket.copyWith.fieldName(...)`
class _$FollowUpTicketCWProxyImpl implements _$FollowUpTicketCWProxy {
  const _$FollowUpTicketCWProxyImpl(this._value);

  final FollowUpTicket _value;

  @override
  FollowUpTicket key(String key) => this(key: key);

  @override
  FollowUpTicket title(String title) => this(title: title);

  @override
  FollowUpTicket state(TicketState state) => this(state: state);

  @override
  FollowUpTicket kind(TicketKind kind) => this(kind: kind);

  @override
  FollowUpTicket source_(FollowUpTicketSource_Enum source_) =>
      this(source_: source_);

  @override
  FollowUpTicket held(bool? held) => this(held: held);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowUpTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowUpTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowUpTicket call({
    Object? key = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? held = const $CopyWithPlaceholder(),
  }) {
    return FollowUpTicket(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as TicketState,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as TicketKind,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as FollowUpTicketSource_Enum,
      held: held == const $CopyWithPlaceholder()
          ? _value.held
          // ignore: cast_nullable_to_non_nullable
          : held as bool?,
    );
  }
}

extension $FollowUpTicketCopyWith on FollowUpTicket {
  /// Returns a callable class that can be used as follows: `instanceOfFollowUpTicket.copyWith(...)` or like so:`instanceOfFollowUpTicket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FollowUpTicketCWProxy get copyWith => _$FollowUpTicketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowUpTicket _$FollowUpTicketFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FollowUpTicket', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['key', 'title', 'state', 'kind', 'source'],
      );
      final val = FollowUpTicket(
        key: $checkedConvert('key', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$TicketStateEnumMap, v),
        ),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$TicketKindEnumMap, v),
        ),
        source_: $checkedConvert(
          'source',
          (v) => $enumDecode(_$FollowUpTicketSource_EnumEnumMap, v),
        ),
        held: $checkedConvert('held', (v) => v as bool?),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$FollowUpTicketToJson(FollowUpTicket instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'state': _$TicketStateEnumMap[instance.state]!,
      'kind': _$TicketKindEnumMap[instance.kind]!,
      'source': _$FollowUpTicketSource_EnumEnumMap[instance.source_]!,
      'held': ?instance.held,
    };

const _$TicketStateEnumMap = {
  TicketState.new_: 'new',
  TicketState.analyzing: 'analyzing',
  TicketState.waitingForAnswers: 'waiting_for_answers',
  TicketState.coding: 'coding',
  TicketState.testing: 'testing',
  TicketState.waitingForReview: 'waiting_for_review',
  TicketState.pushing: 'pushing',
  TicketState.done: 'done',
  TicketState.rejected: 'rejected',
  TicketState.failed: 'failed',
  TicketState.rateLimited: 'rate_limited',
};

const _$TicketKindEnumMap = {
  TicketKind.code: 'code',
  TicketKind.test: 'test',
  TicketKind.plan: 'plan',
  TicketKind.analysis: 'analysis',
  TicketKind.bug: 'bug',
  TicketKind.review: 'review',
  TicketKind.swaggertest: 'swaggertest',
};

const _$FollowUpTicketSource_EnumEnumMap = {
  FollowUpTicketSource_Enum.jira: 'jira',
  FollowUpTicketSource_Enum.plane: 'plane',
  FollowUpTicketSource_Enum.local: 'local',
  FollowUpTicketSource_Enum.git: 'git',
  FollowUpTicketSource_Enum.ci: 'ci',
  FollowUpTicketSource_Enum.logs: 'logs',
};
