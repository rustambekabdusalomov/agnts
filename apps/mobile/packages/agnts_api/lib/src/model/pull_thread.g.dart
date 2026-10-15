// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_thread.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullThreadCWProxy {
  PullThread id(String id);

  PullThread kind(PullThreadKindEnum kind);

  PullThread path(String? path);

  PullThread line(int? line);

  PullThread oldLine(int? oldLine);

  PullThread startLine(int? startLine);

  PullThread diffHunk(String? diffHunk);

  PullThread commitSha(String? commitSha);

  PullThread outdated(bool outdated);

  PullThread resolvable(bool resolvable);

  PullThread resolved(bool resolved);

  PullThread reviewState(String? reviewState);

  PullThread sent(bool? sent);

  PullThread replied(bool? replied);

  PullThread comments(List<PullComment> comments);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullThread(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullThread(...).copyWith(id: 12, name: "My name")
  /// ````
  PullThread call({
    String id,
    PullThreadKindEnum kind,
    String? path,
    int? line,
    int? oldLine,
    int? startLine,
    String? diffHunk,
    String? commitSha,
    bool outdated,
    bool resolvable,
    bool resolved,
    String? reviewState,
    bool? sent,
    bool? replied,
    List<PullComment> comments,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullThread.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullThread.copyWith.fieldName(...)`
class _$PullThreadCWProxyImpl implements _$PullThreadCWProxy {
  const _$PullThreadCWProxyImpl(this._value);

  final PullThread _value;

  @override
  PullThread id(String id) => this(id: id);

  @override
  PullThread kind(PullThreadKindEnum kind) => this(kind: kind);

  @override
  PullThread path(String? path) => this(path: path);

  @override
  PullThread line(int? line) => this(line: line);

  @override
  PullThread oldLine(int? oldLine) => this(oldLine: oldLine);

  @override
  PullThread startLine(int? startLine) => this(startLine: startLine);

  @override
  PullThread diffHunk(String? diffHunk) => this(diffHunk: diffHunk);

  @override
  PullThread commitSha(String? commitSha) => this(commitSha: commitSha);

  @override
  PullThread outdated(bool outdated) => this(outdated: outdated);

  @override
  PullThread resolvable(bool resolvable) => this(resolvable: resolvable);

  @override
  PullThread resolved(bool resolved) => this(resolved: resolved);

  @override
  PullThread reviewState(String? reviewState) => this(reviewState: reviewState);

  @override
  PullThread sent(bool? sent) => this(sent: sent);

  @override
  PullThread replied(bool? replied) => this(replied: replied);

  @override
  PullThread comments(List<PullComment> comments) => this(comments: comments);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullThread(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullThread(...).copyWith(id: 12, name: "My name")
  /// ````
  PullThread call({
    Object? id = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? line = const $CopyWithPlaceholder(),
    Object? oldLine = const $CopyWithPlaceholder(),
    Object? startLine = const $CopyWithPlaceholder(),
    Object? diffHunk = const $CopyWithPlaceholder(),
    Object? commitSha = const $CopyWithPlaceholder(),
    Object? outdated = const $CopyWithPlaceholder(),
    Object? resolvable = const $CopyWithPlaceholder(),
    Object? resolved = const $CopyWithPlaceholder(),
    Object? reviewState = const $CopyWithPlaceholder(),
    Object? sent = const $CopyWithPlaceholder(),
    Object? replied = const $CopyWithPlaceholder(),
    Object? comments = const $CopyWithPlaceholder(),
  }) {
    return PullThread(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as PullThreadKindEnum,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String?,
      line: line == const $CopyWithPlaceholder()
          ? _value.line
          // ignore: cast_nullable_to_non_nullable
          : line as int?,
      oldLine: oldLine == const $CopyWithPlaceholder()
          ? _value.oldLine
          // ignore: cast_nullable_to_non_nullable
          : oldLine as int?,
      startLine: startLine == const $CopyWithPlaceholder()
          ? _value.startLine
          // ignore: cast_nullable_to_non_nullable
          : startLine as int?,
      diffHunk: diffHunk == const $CopyWithPlaceholder()
          ? _value.diffHunk
          // ignore: cast_nullable_to_non_nullable
          : diffHunk as String?,
      commitSha: commitSha == const $CopyWithPlaceholder()
          ? _value.commitSha
          // ignore: cast_nullable_to_non_nullable
          : commitSha as String?,
      outdated: outdated == const $CopyWithPlaceholder()
          ? _value.outdated
          // ignore: cast_nullable_to_non_nullable
          : outdated as bool,
      resolvable: resolvable == const $CopyWithPlaceholder()
          ? _value.resolvable
          // ignore: cast_nullable_to_non_nullable
          : resolvable as bool,
      resolved: resolved == const $CopyWithPlaceholder()
          ? _value.resolved
          // ignore: cast_nullable_to_non_nullable
          : resolved as bool,
      reviewState: reviewState == const $CopyWithPlaceholder()
          ? _value.reviewState
          // ignore: cast_nullable_to_non_nullable
          : reviewState as String?,
      sent: sent == const $CopyWithPlaceholder()
          ? _value.sent
          // ignore: cast_nullable_to_non_nullable
          : sent as bool?,
      replied: replied == const $CopyWithPlaceholder()
          ? _value.replied
          // ignore: cast_nullable_to_non_nullable
          : replied as bool?,
      comments: comments == const $CopyWithPlaceholder()
          ? _value.comments
          // ignore: cast_nullable_to_non_nullable
          : comments as List<PullComment>,
    );
  }
}

extension $PullThreadCopyWith on PullThread {
  /// Returns a callable class that can be used as follows: `instanceOfPullThread.copyWith(...)` or like so:`instanceOfPullThread.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullThreadCWProxy get copyWith => _$PullThreadCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullThread _$PullThreadFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PullThread', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'kind',
          'outdated',
          'resolvable',
          'resolved',
          'comments',
        ],
      );
      final val = PullThread(
        id: $checkedConvert('id', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$PullThreadKindEnumEnumMap, v),
        ),
        path: $checkedConvert('path', (v) => v as String?),
        line: $checkedConvert('line', (v) => (v as num?)?.toInt()),
        oldLine: $checkedConvert('oldLine', (v) => (v as num?)?.toInt()),
        startLine: $checkedConvert('startLine', (v) => (v as num?)?.toInt()),
        diffHunk: $checkedConvert('diffHunk', (v) => v as String?),
        commitSha: $checkedConvert('commitSha', (v) => v as String?),
        outdated: $checkedConvert('outdated', (v) => v as bool),
        resolvable: $checkedConvert('resolvable', (v) => v as bool),
        resolved: $checkedConvert('resolved', (v) => v as bool),
        reviewState: $checkedConvert('reviewState', (v) => v as String?),
        sent: $checkedConvert('sent', (v) => v as bool?),
        replied: $checkedConvert('replied', (v) => v as bool?),
        comments: $checkedConvert(
          'comments',
          (v) => (v as List<dynamic>)
              .map((e) => PullComment.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PullThreadToJson(PullThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$PullThreadKindEnumEnumMap[instance.kind]!,
      'path': ?instance.path,
      'line': ?instance.line,
      'oldLine': ?instance.oldLine,
      'startLine': ?instance.startLine,
      'diffHunk': ?instance.diffHunk,
      'commitSha': ?instance.commitSha,
      'outdated': instance.outdated,
      'resolvable': instance.resolvable,
      'resolved': instance.resolved,
      'reviewState': ?instance.reviewState,
      'sent': ?instance.sent,
      'replied': ?instance.replied,
      'comments': instance.comments.map((e) => e.toJson()).toList(),
    };

const _$PullThreadKindEnumEnumMap = {
  PullThreadKindEnum.general: 'general',
  PullThreadKindEnum.inline: 'inline',
  PullThreadKindEnum.review: 'review',
};
