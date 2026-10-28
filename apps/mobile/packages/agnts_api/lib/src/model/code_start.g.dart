// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_start.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CodeStartCWProxy {
  CodeStart text(String? text);

  CodeStart attachments(List<int>? attachments);

  CodeStart repos(RepoChoice? repos);

  CodeStart kind(TicketKindChoice? kind);

  CodeStart quick(bool? quick);

  CodeStart ticketKey(String? ticketKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeStart(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeStart(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeStart call({
    String? text,
    List<int>? attachments,
    RepoChoice? repos,
    TicketKindChoice? kind,
    bool? quick,
    String? ticketKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCodeStart.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCodeStart.copyWith.fieldName(...)`
class _$CodeStartCWProxyImpl implements _$CodeStartCWProxy {
  const _$CodeStartCWProxyImpl(this._value);

  final CodeStart _value;

  @override
  CodeStart text(String? text) => this(text: text);

  @override
  CodeStart attachments(List<int>? attachments) =>
      this(attachments: attachments);

  @override
  CodeStart repos(RepoChoice? repos) => this(repos: repos);

  @override
  CodeStart kind(TicketKindChoice? kind) => this(kind: kind);

  @override
  CodeStart quick(bool? quick) => this(quick: quick);

  @override
  CodeStart ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CodeStart(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CodeStart(...).copyWith(id: 12, name: "My name")
  /// ````
  CodeStart call({
    Object? text = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
    Object? repos = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? quick = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
  }) {
    return CodeStart(
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<int>?,
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as RepoChoice?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as TicketKindChoice?,
      quick: quick == const $CopyWithPlaceholder()
          ? _value.quick
          // ignore: cast_nullable_to_non_nullable
          : quick as bool?,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
    );
  }
}

extension $CodeStartCopyWith on CodeStart {
  /// Returns a callable class that can be used as follows: `instanceOfCodeStart.copyWith(...)` or like so:`instanceOfCodeStart.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CodeStartCWProxy get copyWith => _$CodeStartCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeStart _$CodeStartFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CodeStart', json, ($checkedConvert) {
      final val = CodeStart(
        text: $checkedConvert('text', (v) => v as String?),
        attachments: $checkedConvert(
          'attachments',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        repos: $checkedConvert(
          'repos',
          (v) =>
              v == null ? null : RepoChoice.fromJson(v as Map<String, dynamic>),
        ),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecodeNullable(_$TicketKindChoiceEnumMap, v),
        ),
        quick: $checkedConvert('quick', (v) => v as bool?),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CodeStartToJson(CodeStart instance) => <String, dynamic>{
  'text': ?instance.text,
  'attachments': ?instance.attachments,
  'repos': ?instance.repos?.toJson(),
  'kind': ?_$TicketKindChoiceEnumMap[instance.kind],
  'quick': ?instance.quick,
  'ticketKey': ?instance.ticketKey,
};

const _$TicketKindChoiceEnumMap = {
  TicketKindChoice.auto: 'auto',
  TicketKindChoice.code: 'code',
  TicketKindChoice.test: 'test',
  TicketKindChoice.plan: 'plan',
  TicketKindChoice.analysis: 'analysis',
  TicketKindChoice.bug: 'bug',
};
