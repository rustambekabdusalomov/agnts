// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviewer_note.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewerNoteCWProxy {
  ReviewerNote id(int id);

  ReviewerNote login(String login);

  ReviewerNote username(String? username);

  ReviewerNote repoName(String? repoName);

  ReviewerNote ticketKey(String? ticketKey);

  ReviewerNote pullTitle(String? pullTitle);

  ReviewerNote kind(ReviewerNoteKindEnum kind);

  ReviewerNote note(String note);

  ReviewerNote createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewerNote(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewerNote(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewerNote call({
    int id,
    String login,
    String? username,
    String? repoName,
    String? ticketKey,
    String? pullTitle,
    ReviewerNoteKindEnum kind,
    String note,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewerNote.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewerNote.copyWith.fieldName(...)`
class _$ReviewerNoteCWProxyImpl implements _$ReviewerNoteCWProxy {
  const _$ReviewerNoteCWProxyImpl(this._value);

  final ReviewerNote _value;

  @override
  ReviewerNote id(int id) => this(id: id);

  @override
  ReviewerNote login(String login) => this(login: login);

  @override
  ReviewerNote username(String? username) => this(username: username);

  @override
  ReviewerNote repoName(String? repoName) => this(repoName: repoName);

  @override
  ReviewerNote ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  ReviewerNote pullTitle(String? pullTitle) => this(pullTitle: pullTitle);

  @override
  ReviewerNote kind(ReviewerNoteKindEnum kind) => this(kind: kind);

  @override
  ReviewerNote note(String note) => this(note: note);

  @override
  ReviewerNote createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewerNote(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewerNote(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewerNote call({
    Object? id = const $CopyWithPlaceholder(),
    Object? login = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? pullTitle = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return ReviewerNote(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      login: login == const $CopyWithPlaceholder()
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as String,
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String?,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String?,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
      pullTitle: pullTitle == const $CopyWithPlaceholder()
          ? _value.pullTitle
          // ignore: cast_nullable_to_non_nullable
          : pullTitle as String?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as ReviewerNoteKindEnum,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $ReviewerNoteCopyWith on ReviewerNote {
  /// Returns a callable class that can be used as follows: `instanceOfReviewerNote.copyWith(...)` or like so:`instanceOfReviewerNote.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewerNoteCWProxy get copyWith => _$ReviewerNoteCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewerNote _$ReviewerNoteFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReviewerNote', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'login', 'kind', 'note', 'createdAt'],
      );
      final val = ReviewerNote(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        login: $checkedConvert('login', (v) => v as String),
        username: $checkedConvert('username', (v) => v as String?),
        repoName: $checkedConvert('repoName', (v) => v as String?),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
        pullTitle: $checkedConvert('pullTitle', (v) => v as String?),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$ReviewerNoteKindEnumEnumMap, v),
        ),
        note: $checkedConvert('note', (v) => v as String),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReviewerNoteToJson(ReviewerNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'login': instance.login,
      'username': ?instance.username,
      'repoName': ?instance.repoName,
      'ticketKey': ?instance.ticketKey,
      'pullTitle': ?instance.pullTitle,
      'kind': _$ReviewerNoteKindEnumEnumMap[instance.kind]!,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ReviewerNoteKindEnumEnumMap = {
  ReviewerNoteKindEnum.rereview: 'rereview',
  ReviewerNoteKindEnum.dismissed: 'dismissed',
  ReviewerNoteKindEnum.manual: 'manual',
};
