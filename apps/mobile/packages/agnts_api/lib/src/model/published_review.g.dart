// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'published_review.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublishedReviewCWProxy {
  PublishedReview ticket(Ticket ticket);

  PublishedReview summary(PublishedReviewSummaryEnum summary);

  PublishedReview inline(int inline);

  PublishedReview still(int still);

  PublishedReview resolved(int resolved);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishedReview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishedReview(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishedReview call({
    Ticket ticket,
    PublishedReviewSummaryEnum summary,
    int inline,
    int still,
    int resolved,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublishedReview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublishedReview.copyWith.fieldName(...)`
class _$PublishedReviewCWProxyImpl implements _$PublishedReviewCWProxy {
  const _$PublishedReviewCWProxyImpl(this._value);

  final PublishedReview _value;

  @override
  PublishedReview ticket(Ticket ticket) => this(ticket: ticket);

  @override
  PublishedReview summary(PublishedReviewSummaryEnum summary) =>
      this(summary: summary);

  @override
  PublishedReview inline(int inline) => this(inline: inline);

  @override
  PublishedReview still(int still) => this(still: still);

  @override
  PublishedReview resolved(int resolved) => this(resolved: resolved);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublishedReview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublishedReview(...).copyWith(id: 12, name: "My name")
  /// ````
  PublishedReview call({
    Object? ticket = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? inline = const $CopyWithPlaceholder(),
    Object? still = const $CopyWithPlaceholder(),
    Object? resolved = const $CopyWithPlaceholder(),
  }) {
    return PublishedReview(
      ticket: ticket == const $CopyWithPlaceholder()
          ? _value.ticket
          // ignore: cast_nullable_to_non_nullable
          : ticket as Ticket,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as PublishedReviewSummaryEnum,
      inline: inline == const $CopyWithPlaceholder()
          ? _value.inline
          // ignore: cast_nullable_to_non_nullable
          : inline as int,
      still: still == const $CopyWithPlaceholder()
          ? _value.still
          // ignore: cast_nullable_to_non_nullable
          : still as int,
      resolved: resolved == const $CopyWithPlaceholder()
          ? _value.resolved
          // ignore: cast_nullable_to_non_nullable
          : resolved as int,
    );
  }
}

extension $PublishedReviewCopyWith on PublishedReview {
  /// Returns a callable class that can be used as follows: `instanceOfPublishedReview.copyWith(...)` or like so:`instanceOfPublishedReview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublishedReviewCWProxy get copyWith => _$PublishedReviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishedReview _$PublishedReviewFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PublishedReview', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'ticket',
          'summary',
          'inline',
          'still',
          'resolved',
        ],
      );
      final val = PublishedReview(
        ticket: $checkedConvert(
          'ticket',
          (v) => Ticket.fromJson(v as Map<String, dynamic>),
        ),
        summary: $checkedConvert(
          'summary',
          (v) => $enumDecode(_$PublishedReviewSummaryEnumEnumMap, v),
        ),
        inline: $checkedConvert('inline', (v) => (v as num).toInt()),
        still: $checkedConvert('still', (v) => (v as num).toInt()),
        resolved: $checkedConvert('resolved', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$PublishedReviewToJson(PublishedReview instance) =>
    <String, dynamic>{
      'ticket': instance.ticket.toJson(),
      'summary': _$PublishedReviewSummaryEnumEnumMap[instance.summary]!,
      'inline': instance.inline,
      'still': instance.still,
      'resolved': instance.resolved,
    };

const _$PublishedReviewSummaryEnumEnumMap = {
  PublishedReviewSummaryEnum.empty: '',
  PublishedReviewSummaryEnum.posted: 'posted',
  PublishedReviewSummaryEnum.edited: 'edited',
};
