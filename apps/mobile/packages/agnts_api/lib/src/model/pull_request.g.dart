// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PullRequestCWProxy {
  PullRequest number(int number);

  PullRequest url(String url);

  PullRequest title(String title);

  PullRequest author(String author);

  PullRequest headRef(String headRef);

  PullRequest headSha(String headSha);

  PullRequest baseRef(String baseRef);

  PullRequest draft(bool draft);

  PullRequest state(PullRequestStateEnum state);

  PullRequest login(String login);

  PullRequest why(PullRequestWhyEnum why);

  PullRequest additions(int? additions);

  PullRequest deletions(int? deletions);

  PullRequest updatedAt(DateTime? updatedAt);

  PullRequest postedSha(String? postedSha);

  PullRequest postedAt(DateTime? postedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PullRequest call({
    int number,
    String url,
    String title,
    String author,
    String headRef,
    String headSha,
    String baseRef,
    bool draft,
    PullRequestStateEnum state,
    String login,
    PullRequestWhyEnum why,
    int? additions,
    int? deletions,
    DateTime? updatedAt,
    String? postedSha,
    DateTime? postedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPullRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPullRequest.copyWith.fieldName(...)`
class _$PullRequestCWProxyImpl implements _$PullRequestCWProxy {
  const _$PullRequestCWProxyImpl(this._value);

  final PullRequest _value;

  @override
  PullRequest number(int number) => this(number: number);

  @override
  PullRequest url(String url) => this(url: url);

  @override
  PullRequest title(String title) => this(title: title);

  @override
  PullRequest author(String author) => this(author: author);

  @override
  PullRequest headRef(String headRef) => this(headRef: headRef);

  @override
  PullRequest headSha(String headSha) => this(headSha: headSha);

  @override
  PullRequest baseRef(String baseRef) => this(baseRef: baseRef);

  @override
  PullRequest draft(bool draft) => this(draft: draft);

  @override
  PullRequest state(PullRequestStateEnum state) => this(state: state);

  @override
  PullRequest login(String login) => this(login: login);

  @override
  PullRequest why(PullRequestWhyEnum why) => this(why: why);

  @override
  PullRequest additions(int? additions) => this(additions: additions);

  @override
  PullRequest deletions(int? deletions) => this(deletions: deletions);

  @override
  PullRequest updatedAt(DateTime? updatedAt) => this(updatedAt: updatedAt);

  @override
  PullRequest postedSha(String? postedSha) => this(postedSha: postedSha);

  @override
  PullRequest postedAt(DateTime? postedAt) => this(postedAt: postedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PullRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PullRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PullRequest call({
    Object? number = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? headRef = const $CopyWithPlaceholder(),
    Object? headSha = const $CopyWithPlaceholder(),
    Object? baseRef = const $CopyWithPlaceholder(),
    Object? draft = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? login = const $CopyWithPlaceholder(),
    Object? why = const $CopyWithPlaceholder(),
    Object? additions = const $CopyWithPlaceholder(),
    Object? deletions = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? postedSha = const $CopyWithPlaceholder(),
    Object? postedAt = const $CopyWithPlaceholder(),
  }) {
    return PullRequest(
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as int,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      author: author == const $CopyWithPlaceholder()
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      headRef: headRef == const $CopyWithPlaceholder()
          ? _value.headRef
          // ignore: cast_nullable_to_non_nullable
          : headRef as String,
      headSha: headSha == const $CopyWithPlaceholder()
          ? _value.headSha
          // ignore: cast_nullable_to_non_nullable
          : headSha as String,
      baseRef: baseRef == const $CopyWithPlaceholder()
          ? _value.baseRef
          // ignore: cast_nullable_to_non_nullable
          : baseRef as String,
      draft: draft == const $CopyWithPlaceholder()
          ? _value.draft
          // ignore: cast_nullable_to_non_nullable
          : draft as bool,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as PullRequestStateEnum,
      login: login == const $CopyWithPlaceholder()
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as String,
      why: why == const $CopyWithPlaceholder()
          ? _value.why
          // ignore: cast_nullable_to_non_nullable
          : why as PullRequestWhyEnum,
      additions: additions == const $CopyWithPlaceholder()
          ? _value.additions
          // ignore: cast_nullable_to_non_nullable
          : additions as int?,
      deletions: deletions == const $CopyWithPlaceholder()
          ? _value.deletions
          // ignore: cast_nullable_to_non_nullable
          : deletions as int?,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      postedSha: postedSha == const $CopyWithPlaceholder()
          ? _value.postedSha
          // ignore: cast_nullable_to_non_nullable
          : postedSha as String?,
      postedAt: postedAt == const $CopyWithPlaceholder()
          ? _value.postedAt
          // ignore: cast_nullable_to_non_nullable
          : postedAt as DateTime?,
    );
  }
}

extension $PullRequestCopyWith on PullRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPullRequest.copyWith(...)` or like so:`instanceOfPullRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PullRequestCWProxy get copyWith => _$PullRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullRequest _$PullRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PullRequest', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'number',
          'url',
          'title',
          'author',
          'headRef',
          'headSha',
          'baseRef',
          'draft',
          'state',
          'login',
          'why',
        ],
      );
      final val = PullRequest(
        number: $checkedConvert('number', (v) => (v as num).toInt()),
        url: $checkedConvert('url', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        author: $checkedConvert('author', (v) => v as String),
        headRef: $checkedConvert('headRef', (v) => v as String),
        headSha: $checkedConvert('headSha', (v) => v as String),
        baseRef: $checkedConvert('baseRef', (v) => v as String),
        draft: $checkedConvert('draft', (v) => v as bool),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$PullRequestStateEnumEnumMap, v),
        ),
        login: $checkedConvert('login', (v) => v as String),
        why: $checkedConvert(
          'why',
          (v) => $enumDecode(_$PullRequestWhyEnumEnumMap, v),
        ),
        additions: $checkedConvert('additions', (v) => (v as num?)?.toInt()),
        deletions: $checkedConvert('deletions', (v) => (v as num?)?.toInt()),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        postedSha: $checkedConvert('postedSha', (v) => v as String?),
        postedAt: $checkedConvert(
          'postedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PullRequestToJson(PullRequest instance) =>
    <String, dynamic>{
      'number': instance.number,
      'url': instance.url,
      'title': instance.title,
      'author': instance.author,
      'headRef': instance.headRef,
      'headSha': instance.headSha,
      'baseRef': instance.baseRef,
      'draft': instance.draft,
      'state': _$PullRequestStateEnumEnumMap[instance.state]!,
      'login': instance.login,
      'why': _$PullRequestWhyEnumEnumMap[instance.why]!,
      'additions': ?instance.additions,
      'deletions': ?instance.deletions,
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
      'postedSha': ?instance.postedSha,
      'postedAt': ?instance.postedAt?.toIso8601String(),
    };

const _$PullRequestStateEnumEnumMap = {
  PullRequestStateEnum.open: 'open',
  PullRequestStateEnum.closed: 'closed',
  PullRequestStateEnum.merged: 'merged',
};

const _$PullRequestWhyEnumEnumMap = {
  PullRequestWhyEnum.assigned: 'assigned',
  PullRequestWhyEnum.reviewRequested: 'review_requested',
  PullRequestWhyEnum.open: 'open',
  PullRequestWhyEnum.own: 'own',
  PullRequestWhyEnum.manual: 'manual',
};
