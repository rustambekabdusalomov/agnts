// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_run.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LiveRunCWProxy {
  LiveRun ticket(Ticket ticket);

  LiveRun model(String model);

  LiveRun turns(int turns);

  LiveRun maxTurns(int maxTurns);

  LiveRun lastMessage(String lastMessage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LiveRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LiveRun(...).copyWith(id: 12, name: "My name")
  /// ````
  LiveRun call({
    Ticket ticket,
    String model,
    int turns,
    int maxTurns,
    String lastMessage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLiveRun.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLiveRun.copyWith.fieldName(...)`
class _$LiveRunCWProxyImpl implements _$LiveRunCWProxy {
  const _$LiveRunCWProxyImpl(this._value);

  final LiveRun _value;

  @override
  LiveRun ticket(Ticket ticket) => this(ticket: ticket);

  @override
  LiveRun model(String model) => this(model: model);

  @override
  LiveRun turns(int turns) => this(turns: turns);

  @override
  LiveRun maxTurns(int maxTurns) => this(maxTurns: maxTurns);

  @override
  LiveRun lastMessage(String lastMessage) => this(lastMessage: lastMessage);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LiveRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LiveRun(...).copyWith(id: 12, name: "My name")
  /// ````
  LiveRun call({
    Object? ticket = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
    Object? turns = const $CopyWithPlaceholder(),
    Object? maxTurns = const $CopyWithPlaceholder(),
    Object? lastMessage = const $CopyWithPlaceholder(),
  }) {
    return LiveRun(
      ticket: ticket == const $CopyWithPlaceholder()
          ? _value.ticket
          // ignore: cast_nullable_to_non_nullable
          : ticket as Ticket,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      turns: turns == const $CopyWithPlaceholder()
          ? _value.turns
          // ignore: cast_nullable_to_non_nullable
          : turns as int,
      maxTurns: maxTurns == const $CopyWithPlaceholder()
          ? _value.maxTurns
          // ignore: cast_nullable_to_non_nullable
          : maxTurns as int,
      lastMessage: lastMessage == const $CopyWithPlaceholder()
          ? _value.lastMessage
          // ignore: cast_nullable_to_non_nullable
          : lastMessage as String,
    );
  }
}

extension $LiveRunCopyWith on LiveRun {
  /// Returns a callable class that can be used as follows: `instanceOfLiveRun.copyWith(...)` or like so:`instanceOfLiveRun.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LiveRunCWProxy get copyWith => _$LiveRunCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveRun _$LiveRunFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LiveRun', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'ticket',
          'model',
          'turns',
          'maxTurns',
          'lastMessage',
        ],
      );
      final val = LiveRun(
        ticket: $checkedConvert(
          'ticket',
          (v) => Ticket.fromJson(v as Map<String, dynamic>),
        ),
        model: $checkedConvert('model', (v) => v as String),
        turns: $checkedConvert('turns', (v) => (v as num).toInt()),
        maxTurns: $checkedConvert('maxTurns', (v) => (v as num).toInt()),
        lastMessage: $checkedConvert('lastMessage', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LiveRunToJson(LiveRun instance) => <String, dynamic>{
  'ticket': instance.ticket.toJson(),
  'model': instance.model,
  'turns': instance.turns,
  'maxTurns': instance.maxTurns,
  'lastMessage': instance.lastMessage,
};
