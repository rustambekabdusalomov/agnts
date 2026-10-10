// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviewer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewerCWProxy {
  Reviewer login(String login);

  Reviewer profile(String profile);

  Reviewer notesFolded(int notesFolded);

  Reviewer updatedAt(DateTime? updatedAt);

  Reviewer pending(List<ReviewerNote> pending);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reviewer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reviewer(...).copyWith(id: 12, name: "My name")
  /// ````
  Reviewer call({
    String login,
    String profile,
    int notesFolded,
    DateTime? updatedAt,
    List<ReviewerNote> pending,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewer.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewer.copyWith.fieldName(...)`
class _$ReviewerCWProxyImpl implements _$ReviewerCWProxy {
  const _$ReviewerCWProxyImpl(this._value);

  final Reviewer _value;

  @override
  Reviewer login(String login) => this(login: login);

  @override
  Reviewer profile(String profile) => this(profile: profile);

  @override
  Reviewer notesFolded(int notesFolded) => this(notesFolded: notesFolded);

  @override
  Reviewer updatedAt(DateTime? updatedAt) => this(updatedAt: updatedAt);

  @override
  Reviewer pending(List<ReviewerNote> pending) => this(pending: pending);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reviewer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reviewer(...).copyWith(id: 12, name: "My name")
  /// ````
  Reviewer call({
    Object? login = const $CopyWithPlaceholder(),
    Object? profile = const $CopyWithPlaceholder(),
    Object? notesFolded = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? pending = const $CopyWithPlaceholder(),
  }) {
    return Reviewer(
      login: login == const $CopyWithPlaceholder()
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as String,
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as String,
      notesFolded: notesFolded == const $CopyWithPlaceholder()
          ? _value.notesFolded
          // ignore: cast_nullable_to_non_nullable
          : notesFolded as int,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      pending: pending == const $CopyWithPlaceholder()
          ? _value.pending
          // ignore: cast_nullable_to_non_nullable
          : pending as List<ReviewerNote>,
    );
  }
}

extension $ReviewerCopyWith on Reviewer {
  /// Returns a callable class that can be used as follows: `instanceOfReviewer.copyWith(...)` or like so:`instanceOfReviewer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewerCWProxy get copyWith => _$ReviewerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reviewer _$ReviewerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Reviewer', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['login', 'profile', 'notesFolded', 'pending'],
      );
      final val = Reviewer(
        login: $checkedConvert('login', (v) => v as String),
        profile: $checkedConvert('profile', (v) => v as String),
        notesFolded: $checkedConvert('notesFolded', (v) => (v as num).toInt()),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        pending: $checkedConvert(
          'pending',
          (v) => (v as List<dynamic>)
              .map((e) => ReviewerNote.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReviewerToJson(Reviewer instance) => <String, dynamic>{
  'login': instance.login,
  'profile': instance.profile,
  'notesFolded': instance.notesFolded,
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
  'pending': instance.pending.map((e) => e.toJson()).toList(),
};
