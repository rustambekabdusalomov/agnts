// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_ticket.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CodeTicketCWProxy {
  CodeTicket key(String key);

  CodeTicket title(String title);

  CodeTicket state(TicketState state);

  CodeTicket kind(TicketKind kind);

  CodeTicket repos(List<String> repos);

  CodeTicket current(bool current);

  CodeTicket moved(bool moved);

  CodeTicket attachedAt(DateTime attachedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeTicket call({
    String key,
    String title,
    TicketState state,
    TicketKind kind,
    List<String> repos,
    bool current,
    bool moved,
    DateTime attachedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCodeTicket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCodeTicket.copyWith.fieldName(...)`
class _$CodeTicketCWProxyImpl implements _$CodeTicketCWProxy {
  const _$CodeTicketCWProxyImpl(this._value);

  final CodeTicket _value;

  @override
  CodeTicket key(String key) => this(key: key);

  @override
  CodeTicket title(String title) => this(title: title);

  @override
  CodeTicket state(TicketState state) => this(state: state);

  @override
  CodeTicket kind(TicketKind kind) => this(kind: kind);

  @override
  CodeTicket repos(List<String> repos) => this(repos: repos);

  @override
  CodeTicket current(bool current) => this(current: current);

  @override
  CodeTicket moved(bool moved) => this(moved: moved);

  @override
  CodeTicket attachedAt(DateTime attachedAt) => this(attachedAt: attachedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeTicket call({
    Object? key = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? repos = const $CopyWithPlaceholder(),
    Object? current = const $CopyWithPlaceholder(),
    Object? moved = const $CopyWithPlaceholder(),
    Object? attachedAt = const $CopyWithPlaceholder(),
  }) {
    return CodeTicket(
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
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as List<String>,
      current: current == const $CopyWithPlaceholder()
          ? _value.current
          // ignore: cast_nullable_to_non_nullable
          : current as bool,
      moved: moved == const $CopyWithPlaceholder()
          ? _value.moved
          // ignore: cast_nullable_to_non_nullable
          : moved as bool,
      attachedAt: attachedAt == const $CopyWithPlaceholder()
          ? _value.attachedAt
          // ignore: cast_nullable_to_non_nullable
          : attachedAt as DateTime,
    );
  }
}

extension $CodeTicketCopyWith on CodeTicket {
  /// Returns a callable class that can be used as follows: `instanceOfCodeTicket.copyWith(...)` or like so:`instanceOfCodeTicket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CodeTicketCWProxy get copyWith => _$CodeTicketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeTicket _$CodeTicketFromJson(Map<String, dynamic> json) => $checkedCreate(
  'CodeTicket',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'key',
        'title',
        'state',
        'kind',
        'repos',
        'current',
        'moved',
        'attachedAt',
      ],
    );
    final val = CodeTicket(
      key: $checkedConvert('key', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      state: $checkedConvert(
        'state',
        (v) => $enumDecode(_$TicketStateEnumMap, v),
      ),
      kind: $checkedConvert('kind', (v) => $enumDecode(_$TicketKindEnumMap, v)),
      repos: $checkedConvert(
        'repos',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      current: $checkedConvert('current', (v) => v as bool),
      moved: $checkedConvert('moved', (v) => v as bool),
      attachedAt: $checkedConvert(
        'attachedAt',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$CodeTicketToJson(CodeTicket instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'state': _$TicketStateEnumMap[instance.state]!,
      'kind': _$TicketKindEnumMap[instance.kind]!,
      'repos': instance.repos,
      'current': instance.current,
      'moved': instance.moved,
      'attachedAt': instance.attachedAt.toIso8601String(),
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
