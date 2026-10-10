// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_spend_row.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TicketSpendRowCWProxy {
  TicketSpendRow key(String key);

  TicketSpendRow title(String title);

  TicketSpendRow kind(TicketKind kind);

  TicketSpendRow state(TicketState state);

  TicketSpendRow repoName(String? repoName);

  TicketSpendRow calls(int calls);

  TicketSpendRow topStage(TicketSpendRowTopStageEnum topStage);

  TicketSpendRow spend(TokenSpend spend);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketSpendRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketSpendRow(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketSpendRow call({
    String key,
    String title,
    TicketKind kind,
    TicketState state,
    String? repoName,
    int calls,
    TicketSpendRowTopStageEnum topStage,
    TokenSpend spend,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTicketSpendRow.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTicketSpendRow.copyWith.fieldName(...)`
class _$TicketSpendRowCWProxyImpl implements _$TicketSpendRowCWProxy {
  const _$TicketSpendRowCWProxyImpl(this._value);

  final TicketSpendRow _value;

  @override
  TicketSpendRow key(String key) => this(key: key);

  @override
  TicketSpendRow title(String title) => this(title: title);

  @override
  TicketSpendRow kind(TicketKind kind) => this(kind: kind);

  @override
  TicketSpendRow state(TicketState state) => this(state: state);

  @override
  TicketSpendRow repoName(String? repoName) => this(repoName: repoName);

  @override
  TicketSpendRow calls(int calls) => this(calls: calls);

  @override
  TicketSpendRow topStage(TicketSpendRowTopStageEnum topStage) =>
      this(topStage: topStage);

  @override
  TicketSpendRow spend(TokenSpend spend) => this(spend: spend);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketSpendRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketSpendRow(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketSpendRow call({
    Object? key = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? calls = const $CopyWithPlaceholder(),
    Object? topStage = const $CopyWithPlaceholder(),
    Object? spend = const $CopyWithPlaceholder(),
  }) {
    return TicketSpendRow(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as TicketKind,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as TicketState,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String?,
      calls: calls == const $CopyWithPlaceholder()
          ? _value.calls
          // ignore: cast_nullable_to_non_nullable
          : calls as int,
      topStage: topStage == const $CopyWithPlaceholder()
          ? _value.topStage
          // ignore: cast_nullable_to_non_nullable
          : topStage as TicketSpendRowTopStageEnum,
      spend: spend == const $CopyWithPlaceholder()
          ? _value.spend
          // ignore: cast_nullable_to_non_nullable
          : spend as TokenSpend,
    );
  }
}

extension $TicketSpendRowCopyWith on TicketSpendRow {
  /// Returns a callable class that can be used as follows: `instanceOfTicketSpendRow.copyWith(...)` or like so:`instanceOfTicketSpendRow.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TicketSpendRowCWProxy get copyWith => _$TicketSpendRowCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketSpendRow _$TicketSpendRowFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TicketSpendRow', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'key',
          'title',
          'kind',
          'state',
          'calls',
          'topStage',
          'spend',
        ],
      );
      final val = TicketSpendRow(
        key: $checkedConvert('key', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$TicketKindEnumMap, v),
        ),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$TicketStateEnumMap, v),
        ),
        repoName: $checkedConvert('repoName', (v) => v as String?),
        calls: $checkedConvert('calls', (v) => (v as num).toInt()),
        topStage: $checkedConvert(
          'topStage',
          (v) => $enumDecode(_$TicketSpendRowTopStageEnumEnumMap, v),
        ),
        spend: $checkedConvert(
          'spend',
          (v) => TokenSpend.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TicketSpendRowToJson(TicketSpendRow instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'kind': _$TicketKindEnumMap[instance.kind]!,
      'state': _$TicketStateEnumMap[instance.state]!,
      'repoName': ?instance.repoName,
      'calls': instance.calls,
      'topStage': _$TicketSpendRowTopStageEnumEnumMap[instance.topStage]!,
      'spend': instance.spend.toJson(),
    };

const _$TicketKindEnumMap = {
  TicketKind.code: 'code',
  TicketKind.test: 'test',
  TicketKind.plan: 'plan',
  TicketKind.analysis: 'analysis',
  TicketKind.bug: 'bug',
  TicketKind.review: 'review',
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

const _$TicketSpendRowTopStageEnumEnumMap = {
  TicketSpendRowTopStageEnum.analyze: 'analyze',
  TicketSpendRowTopStageEnum.coding: 'coding',
  TicketSpendRowTopStageEnum.retry: 'retry',
  TicketSpendRowTopStageEnum.helper: 'helper',
  TicketSpendRowTopStageEnum.learn: 'learn',
  TicketSpendRowTopStageEnum.review: 'review',
  TicketSpendRowTopStageEnum.preview: 'preview',
};
