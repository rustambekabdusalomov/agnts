// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviewers.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewersCWProxy {
  Reviewers reviewers(List<Reviewer> reviewers);

  Reviewers notes(List<ReviewerNote> notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reviewers(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reviewers(...).copyWith(id: 12, name: "My name")
  /// ````
  Reviewers call({List<Reviewer> reviewers, List<ReviewerNote> notes});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewers.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewers.copyWith.fieldName(...)`
class _$ReviewersCWProxyImpl implements _$ReviewersCWProxy {
  const _$ReviewersCWProxyImpl(this._value);

  final Reviewers _value;

  @override
  Reviewers reviewers(List<Reviewer> reviewers) => this(reviewers: reviewers);

  @override
  Reviewers notes(List<ReviewerNote> notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reviewers(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reviewers(...).copyWith(id: 12, name: "My name")
  /// ````
  Reviewers call({
    Object? reviewers = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return Reviewers(
      reviewers: reviewers == const $CopyWithPlaceholder()
          ? _value.reviewers
          // ignore: cast_nullable_to_non_nullable
          : reviewers as List<Reviewer>,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as List<ReviewerNote>,
    );
  }
}

extension $ReviewersCopyWith on Reviewers {
  /// Returns a callable class that can be used as follows: `instanceOfReviewers.copyWith(...)` or like so:`instanceOfReviewers.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewersCWProxy get copyWith => _$ReviewersCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reviewers _$ReviewersFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Reviewers', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['reviewers', 'notes']);
      final val = Reviewers(
        reviewers: $checkedConvert(
          'reviewers',
          (v) => (v as List<dynamic>)
              .map((e) => Reviewer.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        notes: $checkedConvert(
          'notes',
          (v) => (v as List<dynamic>)
              .map((e) => ReviewerNote.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReviewersToJson(Reviewers instance) => <String, dynamic>{
  'reviewers': instance.reviewers.map((e) => e.toJson()).toList(),
  'notes': instance.notes.map((e) => e.toJson()).toList(),
};
