// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_message.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantMessageCWProxy {
  AssistantMessage id(int id);

  AssistantMessage role(AssistantMessageRoleEnum role);

  AssistantMessage text(String text);

  AssistantMessage speech(String speech);

  AssistantMessage links(List<AssistantLink> links);

  AssistantMessage status(AssistantMessageStatusEnum status);

  AssistantMessage error(String? error);

  AssistantMessage lang(AssistantLanguage lang);

  AssistantMessage durationMs(int? durationMs);

  AssistantMessage files(List<String>? files);

  AssistantMessage rating(AssistantMessageRatingEnum rating);

  AssistantMessage ratingComment(String? ratingComment);

  AssistantMessage shared(bool shared);

  AssistantMessage actions(List<AssistantAction>? actions);

  AssistantMessage actionErrors(List<String>? actionErrors);

  AssistantMessage handoff(CodeHandoff? handoff);

  AssistantMessage ticketKey(String? ticketKey);

  AssistantMessage routed(CodeRouted? routed);

  AssistantMessage attachments(List<int>? attachments);

  AssistantMessage createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantMessage call({
    int id,
    AssistantMessageRoleEnum role,
    String text,
    String speech,
    List<AssistantLink> links,
    AssistantMessageStatusEnum status,
    String? error,
    AssistantLanguage lang,
    int? durationMs,
    List<String>? files,
    AssistantMessageRatingEnum rating,
    String? ratingComment,
    bool shared,
    List<AssistantAction>? actions,
    List<String>? actionErrors,
    CodeHandoff? handoff,
    String? ticketKey,
    CodeRouted? routed,
    List<int>? attachments,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantMessage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantMessage.copyWith.fieldName(...)`
class _$AssistantMessageCWProxyImpl implements _$AssistantMessageCWProxy {
  const _$AssistantMessageCWProxyImpl(this._value);

  final AssistantMessage _value;

  @override
  AssistantMessage id(int id) => this(id: id);

  @override
  AssistantMessage role(AssistantMessageRoleEnum role) => this(role: role);

  @override
  AssistantMessage text(String text) => this(text: text);

  @override
  AssistantMessage speech(String speech) => this(speech: speech);

  @override
  AssistantMessage links(List<AssistantLink> links) => this(links: links);

  @override
  AssistantMessage status(AssistantMessageStatusEnum status) =>
      this(status: status);

  @override
  AssistantMessage error(String? error) => this(error: error);

  @override
  AssistantMessage lang(AssistantLanguage lang) => this(lang: lang);

  @override
  AssistantMessage durationMs(int? durationMs) => this(durationMs: durationMs);

  @override
  AssistantMessage files(List<String>? files) => this(files: files);

  @override
  AssistantMessage rating(AssistantMessageRatingEnum rating) =>
      this(rating: rating);

  @override
  AssistantMessage ratingComment(String? ratingComment) =>
      this(ratingComment: ratingComment);

  @override
  AssistantMessage shared(bool shared) => this(shared: shared);

  @override
  AssistantMessage actions(List<AssistantAction>? actions) =>
      this(actions: actions);

  @override
  AssistantMessage actionErrors(List<String>? actionErrors) =>
      this(actionErrors: actionErrors);

  @override
  AssistantMessage handoff(CodeHandoff? handoff) => this(handoff: handoff);

  @override
  AssistantMessage ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  AssistantMessage routed(CodeRouted? routed) => this(routed: routed);

  @override
  AssistantMessage attachments(List<int>? attachments) =>
      this(attachments: attachments);

  @override
  AssistantMessage createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantMessage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
    Object? speech = const $CopyWithPlaceholder(),
    Object? links = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? lang = const $CopyWithPlaceholder(),
    Object? durationMs = const $CopyWithPlaceholder(),
    Object? files = const $CopyWithPlaceholder(),
    Object? rating = const $CopyWithPlaceholder(),
    Object? ratingComment = const $CopyWithPlaceholder(),
    Object? shared = const $CopyWithPlaceholder(),
    Object? actions = const $CopyWithPlaceholder(),
    Object? actionErrors = const $CopyWithPlaceholder(),
    Object? handoff = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
    Object? routed = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return AssistantMessage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as AssistantMessageRoleEnum,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
      speech: speech == const $CopyWithPlaceholder()
          ? _value.speech
          // ignore: cast_nullable_to_non_nullable
          : speech as String,
      links: links == const $CopyWithPlaceholder()
          ? _value.links
          // ignore: cast_nullable_to_non_nullable
          : links as List<AssistantLink>,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AssistantMessageStatusEnum,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      lang: lang == const $CopyWithPlaceholder()
          ? _value.lang
          // ignore: cast_nullable_to_non_nullable
          : lang as AssistantLanguage,
      durationMs: durationMs == const $CopyWithPlaceholder()
          ? _value.durationMs
          // ignore: cast_nullable_to_non_nullable
          : durationMs as int?,
      files: files == const $CopyWithPlaceholder()
          ? _value.files
          // ignore: cast_nullable_to_non_nullable
          : files as List<String>?,
      rating: rating == const $CopyWithPlaceholder()
          ? _value.rating
          // ignore: cast_nullable_to_non_nullable
          : rating as AssistantMessageRatingEnum,
      ratingComment: ratingComment == const $CopyWithPlaceholder()
          ? _value.ratingComment
          // ignore: cast_nullable_to_non_nullable
          : ratingComment as String?,
      shared: shared == const $CopyWithPlaceholder()
          ? _value.shared
          // ignore: cast_nullable_to_non_nullable
          : shared as bool,
      actions: actions == const $CopyWithPlaceholder()
          ? _value.actions
          // ignore: cast_nullable_to_non_nullable
          : actions as List<AssistantAction>?,
      actionErrors: actionErrors == const $CopyWithPlaceholder()
          ? _value.actionErrors
          // ignore: cast_nullable_to_non_nullable
          : actionErrors as List<String>?,
      handoff: handoff == const $CopyWithPlaceholder()
          ? _value.handoff
          // ignore: cast_nullable_to_non_nullable
          : handoff as CodeHandoff?,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
      routed: routed == const $CopyWithPlaceholder()
          ? _value.routed
          // ignore: cast_nullable_to_non_nullable
          : routed as CodeRouted?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<int>?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $AssistantMessageCopyWith on AssistantMessage {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantMessage.copyWith(...)` or like so:`instanceOfAssistantMessage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantMessageCWProxy get copyWith => _$AssistantMessageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantMessage _$AssistantMessageFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantMessage', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'role',
      'text',
      'speech',
      'links',
      'status',
      'lang',
      'rating',
      'shared',
      'createdAt',
    ],
  );
  final val = AssistantMessage(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    role: $checkedConvert(
      'role',
      (v) => $enumDecode(_$AssistantMessageRoleEnumEnumMap, v),
    ),
    text: $checkedConvert('text', (v) => v as String),
    speech: $checkedConvert('speech', (v) => v as String),
    links: $checkedConvert(
      'links',
      (v) => (v as List<dynamic>)
          .map((e) => AssistantLink.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$AssistantMessageStatusEnumEnumMap, v),
    ),
    error: $checkedConvert('error', (v) => v as String?),
    lang: $checkedConvert(
      'lang',
      (v) => $enumDecode(_$AssistantLanguageEnumMap, v),
    ),
    durationMs: $checkedConvert('durationMs', (v) => (v as num?)?.toInt()),
    files: $checkedConvert(
      'files',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    rating: $checkedConvert(
      'rating',
      (v) => $enumDecode(_$AssistantMessageRatingEnumEnumMap, v),
    ),
    ratingComment: $checkedConvert('ratingComment', (v) => v as String?),
    shared: $checkedConvert('shared', (v) => v as bool),
    actions: $checkedConvert(
      'actions',
      (v) => (v as List<dynamic>?)
          ?.map((e) => AssistantAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    actionErrors: $checkedConvert(
      'actionErrors',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    handoff: $checkedConvert(
      'handoff',
      (v) => v == null ? null : CodeHandoff.fromJson(v as Map<String, dynamic>),
    ),
    ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
    routed: $checkedConvert(
      'routed',
      (v) => $enumDecodeNullable(_$CodeRoutedEnumMap, v),
    ),
    attachments: $checkedConvert(
      'attachments',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$AssistantMessageToJson(AssistantMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$AssistantMessageRoleEnumEnumMap[instance.role]!,
      'text': instance.text,
      'speech': instance.speech,
      'links': instance.links.map((e) => e.toJson()).toList(),
      'status': _$AssistantMessageStatusEnumEnumMap[instance.status]!,
      'error': ?instance.error,
      'lang': _$AssistantLanguageEnumMap[instance.lang]!,
      'durationMs': ?instance.durationMs,
      'files': ?instance.files,
      'rating': _$AssistantMessageRatingEnumEnumMap[instance.rating]!,
      'ratingComment': ?instance.ratingComment,
      'shared': instance.shared,
      'actions': ?instance.actions?.map((e) => e.toJson()).toList(),
      'actionErrors': ?instance.actionErrors,
      'handoff': ?instance.handoff?.toJson(),
      'ticketKey': ?instance.ticketKey,
      'routed': ?_$CodeRoutedEnumMap[instance.routed],
      'attachments': ?instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AssistantMessageRoleEnumEnumMap = {
  AssistantMessageRoleEnum.user: 'user',
  AssistantMessageRoleEnum.assistant: 'assistant',
};

const _$AssistantMessageStatusEnumEnumMap = {
  AssistantMessageStatusEnum.pending: 'pending',
  AssistantMessageStatusEnum.answering: 'answering',
  AssistantMessageStatusEnum.done: 'done',
  AssistantMessageStatusEnum.failed: 'failed',
};

const _$AssistantLanguageEnumMap = {
  AssistantLanguage.en: 'en',
  AssistantLanguage.ru: 'ru',
  AssistantLanguage.uz: 'uz',
};

const _$AssistantMessageRatingEnumEnumMap = {
  AssistantMessageRatingEnum.numberNegative1: -1,
  AssistantMessageRatingEnum.number0: 0,
  AssistantMessageRatingEnum.number1: 1,
};

const _$CodeRoutedEnumMap = {
  CodeRouted.created: 'created',
  CodeRouted.answered: 'answered',
  CodeRouted.changes: 'changes',
  CodeRouted.continued: 'continued',
  CodeRouted.retried: 'retried',
  CodeRouted.queued: 'queued',
  CodeRouted.sent: 'sent',
  CodeRouted.failed: 'failed',
  CodeRouted.steered: 'steered',
};
