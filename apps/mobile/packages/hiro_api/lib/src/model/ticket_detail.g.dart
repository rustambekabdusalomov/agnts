// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TicketDetailCWProxy {
  TicketDetail ticket(Ticket ticket);

  TicketDetail questions(List<Question> questions);

  TicketDetail analysis(Analysis? analysis);

  TicketDetail result(Result? result);

  TicketDetail childKey(String? childKey);

  TicketDetail review(CodeReview? review);

  TicketDetail history(List<HistoryItem>? history);

  TicketDetail maxTurns(int? maxTurns);

  TicketDetail effectiveModels(StageModels? effectiveModels);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketDetail call({
    Ticket ticket,
    List<Question> questions,
    Analysis? analysis,
    Result? result,
    String? childKey,
    CodeReview? review,
    List<HistoryItem>? history,
    int? maxTurns,
    StageModels? effectiveModels,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTicketDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTicketDetail.copyWith.fieldName(...)`
class _$TicketDetailCWProxyImpl implements _$TicketDetailCWProxy {
  const _$TicketDetailCWProxyImpl(this._value);

  final TicketDetail _value;

  @override
  TicketDetail ticket(Ticket ticket) => this(ticket: ticket);

  @override
  TicketDetail questions(List<Question> questions) =>
      this(questions: questions);

  @override
  TicketDetail analysis(Analysis? analysis) => this(analysis: analysis);

  @override
  TicketDetail result(Result? result) => this(result: result);

  @override
  TicketDetail childKey(String? childKey) => this(childKey: childKey);

  @override
  TicketDetail review(CodeReview? review) => this(review: review);

  @override
  TicketDetail history(List<HistoryItem>? history) => this(history: history);

  @override
  TicketDetail maxTurns(int? maxTurns) => this(maxTurns: maxTurns);

  @override
  TicketDetail effectiveModels(StageModels? effectiveModels) =>
      this(effectiveModels: effectiveModels);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketDetail call({
    Object? ticket = const $CopyWithPlaceholder(),
    Object? questions = const $CopyWithPlaceholder(),
    Object? analysis = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? childKey = const $CopyWithPlaceholder(),
    Object? review = const $CopyWithPlaceholder(),
    Object? history = const $CopyWithPlaceholder(),
    Object? maxTurns = const $CopyWithPlaceholder(),
    Object? effectiveModels = const $CopyWithPlaceholder(),
  }) {
    return TicketDetail(
      ticket: ticket == const $CopyWithPlaceholder()
          ? _value.ticket
          // ignore: cast_nullable_to_non_nullable
          : ticket as Ticket,
      questions: questions == const $CopyWithPlaceholder()
          ? _value.questions
          // ignore: cast_nullable_to_non_nullable
          : questions as List<Question>,
      analysis: analysis == const $CopyWithPlaceholder()
          ? _value.analysis
          // ignore: cast_nullable_to_non_nullable
          : analysis as Analysis?,
      result: result == const $CopyWithPlaceholder()
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as Result?,
      childKey: childKey == const $CopyWithPlaceholder()
          ? _value.childKey
          // ignore: cast_nullable_to_non_nullable
          : childKey as String?,
      review: review == const $CopyWithPlaceholder()
          ? _value.review
          // ignore: cast_nullable_to_non_nullable
          : review as CodeReview?,
      history: history == const $CopyWithPlaceholder()
          ? _value.history
          // ignore: cast_nullable_to_non_nullable
          : history as List<HistoryItem>?,
      maxTurns: maxTurns == const $CopyWithPlaceholder()
          ? _value.maxTurns
          // ignore: cast_nullable_to_non_nullable
          : maxTurns as int?,
      effectiveModels: effectiveModels == const $CopyWithPlaceholder()
          ? _value.effectiveModels
          // ignore: cast_nullable_to_non_nullable
          : effectiveModels as StageModels?,
    );
  }
}

extension $TicketDetailCopyWith on TicketDetail {
  /// Returns a callable class that can be used as follows: `instanceOfTicketDetail.copyWith(...)` or like so:`instanceOfTicketDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TicketDetailCWProxy get copyWith => _$TicketDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketDetail _$TicketDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TicketDetail', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['ticket', 'questions']);
      final val = TicketDetail(
        ticket: $checkedConvert(
          'ticket',
          (v) => Ticket.fromJson(v as Map<String, dynamic>),
        ),
        questions: $checkedConvert(
          'questions',
          (v) => (v as List<dynamic>)
              .map((e) => Question.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        analysis: $checkedConvert(
          'analysis',
          (v) =>
              v == null ? null : Analysis.fromJson(v as Map<String, dynamic>),
        ),
        result: $checkedConvert(
          'result',
          (v) => v == null ? null : Result.fromJson(v as Map<String, dynamic>),
        ),
        childKey: $checkedConvert('childKey', (v) => v as String?),
        review: $checkedConvert(
          'review',
          (v) =>
              v == null ? null : CodeReview.fromJson(v as Map<String, dynamic>),
        ),
        history: $checkedConvert(
          'history',
          (v) => (v as List<dynamic>?)
              ?.map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        maxTurns: $checkedConvert('maxTurns', (v) => (v as num?)?.toInt()),
        effectiveModels: $checkedConvert(
          'effectiveModels',
          (v) => v == null
              ? null
              : StageModels.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TicketDetailToJson(TicketDetail instance) =>
    <String, dynamic>{
      'ticket': instance.ticket.toJson(),
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'analysis': ?instance.analysis?.toJson(),
      'result': ?instance.result?.toJson(),
      'childKey': ?instance.childKey,
      'review': ?instance.review?.toJson(),
      'history': ?instance.history?.map((e) => e.toJson()).toList(),
      'maxTurns': ?instance.maxTurns,
      'effectiveModels': ?instance.effectiveModels?.toJson(),
    };
