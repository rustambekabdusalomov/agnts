// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_source_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentSourceInputCWProxy {
  DocumentSourceInput kind(DocumentSourceInputKindEnum kind);

  DocumentSourceInput template(DocumentSourceInputTemplateEnum? template);

  DocumentSourceInput instruction(String? instruction);

  DocumentSourceInput tickets(List<String>? tickets);

  DocumentSourceInput filter(DocumentSourceInputFilter? filter);

  DocumentSourceInput repoIds(List<int>? repoIds);

  DocumentSourceInput branch(String? branch);

  DocumentSourceInput author(String? author);

  DocumentSourceInput prState(DocumentSourceInputPrStateEnum? prState);

  DocumentSourceInput prNumbers(List<int>? prNumbers);

  DocumentSourceInput from(DateTime? from);

  DocumentSourceInput to(DateTime? to);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSourceInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSourceInput(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSourceInput call({
    DocumentSourceInputKindEnum kind,
    DocumentSourceInputTemplateEnum? template,
    String? instruction,
    List<String>? tickets,
    DocumentSourceInputFilter? filter,
    List<int>? repoIds,
    String? branch,
    String? author,
    DocumentSourceInputPrStateEnum? prState,
    List<int>? prNumbers,
    DateTime? from,
    DateTime? to,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentSourceInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentSourceInput.copyWith.fieldName(...)`
class _$DocumentSourceInputCWProxyImpl implements _$DocumentSourceInputCWProxy {
  const _$DocumentSourceInputCWProxyImpl(this._value);

  final DocumentSourceInput _value;

  @override
  DocumentSourceInput kind(DocumentSourceInputKindEnum kind) =>
      this(kind: kind);

  @override
  DocumentSourceInput template(DocumentSourceInputTemplateEnum? template) =>
      this(template: template);

  @override
  DocumentSourceInput instruction(String? instruction) =>
      this(instruction: instruction);

  @override
  DocumentSourceInput tickets(List<String>? tickets) => this(tickets: tickets);

  @override
  DocumentSourceInput filter(DocumentSourceInputFilter? filter) =>
      this(filter: filter);

  @override
  DocumentSourceInput repoIds(List<int>? repoIds) => this(repoIds: repoIds);

  @override
  DocumentSourceInput branch(String? branch) => this(branch: branch);

  @override
  DocumentSourceInput author(String? author) => this(author: author);

  @override
  DocumentSourceInput prState(DocumentSourceInputPrStateEnum? prState) =>
      this(prState: prState);

  @override
  DocumentSourceInput prNumbers(List<int>? prNumbers) =>
      this(prNumbers: prNumbers);

  @override
  DocumentSourceInput from(DateTime? from) => this(from: from);

  @override
  DocumentSourceInput to(DateTime? to) => this(to: to);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSourceInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSourceInput(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSourceInput call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? template = const $CopyWithPlaceholder(),
    Object? instruction = const $CopyWithPlaceholder(),
    Object? tickets = const $CopyWithPlaceholder(),
    Object? filter = const $CopyWithPlaceholder(),
    Object? repoIds = const $CopyWithPlaceholder(),
    Object? branch = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? prState = const $CopyWithPlaceholder(),
    Object? prNumbers = const $CopyWithPlaceholder(),
    Object? from = const $CopyWithPlaceholder(),
    Object? to = const $CopyWithPlaceholder(),
  }) {
    return DocumentSourceInput(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as DocumentSourceInputKindEnum,
      template: template == const $CopyWithPlaceholder()
          ? _value.template
          // ignore: cast_nullable_to_non_nullable
          : template as DocumentSourceInputTemplateEnum?,
      instruction: instruction == const $CopyWithPlaceholder()
          ? _value.instruction
          // ignore: cast_nullable_to_non_nullable
          : instruction as String?,
      tickets: tickets == const $CopyWithPlaceholder()
          ? _value.tickets
          // ignore: cast_nullable_to_non_nullable
          : tickets as List<String>?,
      filter: filter == const $CopyWithPlaceholder()
          ? _value.filter
          // ignore: cast_nullable_to_non_nullable
          : filter as DocumentSourceInputFilter?,
      repoIds: repoIds == const $CopyWithPlaceholder()
          ? _value.repoIds
          // ignore: cast_nullable_to_non_nullable
          : repoIds as List<int>?,
      branch: branch == const $CopyWithPlaceholder()
          ? _value.branch
          // ignore: cast_nullable_to_non_nullable
          : branch as String?,
      author: author == const $CopyWithPlaceholder()
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String?,
      prState: prState == const $CopyWithPlaceholder()
          ? _value.prState
          // ignore: cast_nullable_to_non_nullable
          : prState as DocumentSourceInputPrStateEnum?,
      prNumbers: prNumbers == const $CopyWithPlaceholder()
          ? _value.prNumbers
          // ignore: cast_nullable_to_non_nullable
          : prNumbers as List<int>?,
      from: from == const $CopyWithPlaceholder()
          ? _value.from
          // ignore: cast_nullable_to_non_nullable
          : from as DateTime?,
      to: to == const $CopyWithPlaceholder()
          ? _value.to
          // ignore: cast_nullable_to_non_nullable
          : to as DateTime?,
    );
  }
}

extension $DocumentSourceInputCopyWith on DocumentSourceInput {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentSourceInput.copyWith(...)` or like so:`instanceOfDocumentSourceInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentSourceInputCWProxy get copyWith =>
      _$DocumentSourceInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentSourceInput _$DocumentSourceInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentSourceInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind']);
      final val = DocumentSourceInput(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$DocumentSourceInputKindEnumEnumMap, v),
        ),
        template: $checkedConvert(
          'template',
          (v) =>
              $enumDecodeNullable(_$DocumentSourceInputTemplateEnumEnumMap, v),
        ),
        instruction: $checkedConvert('instruction', (v) => v as String?),
        tickets: $checkedConvert(
          'tickets',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        filter: $checkedConvert(
          'filter',
          (v) => v == null
              ? null
              : DocumentSourceInputFilter.fromJson(v as Map<String, dynamic>),
        ),
        repoIds: $checkedConvert(
          'repoIds',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        branch: $checkedConvert('branch', (v) => v as String?),
        author: $checkedConvert('author', (v) => v as String?),
        prState: $checkedConvert(
          'prState',
          (v) =>
              $enumDecodeNullable(_$DocumentSourceInputPrStateEnumEnumMap, v),
        ),
        prNumbers: $checkedConvert(
          'prNumbers',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        from: $checkedConvert(
          'from',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        to: $checkedConvert(
          'to',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DocumentSourceInputToJson(
  DocumentSourceInput instance,
) => <String, dynamic>{
  'kind': _$DocumentSourceInputKindEnumEnumMap[instance.kind]!,
  'template': ?_$DocumentSourceInputTemplateEnumEnumMap[instance.template],
  'instruction': ?instance.instruction,
  'tickets': ?instance.tickets,
  'filter': ?instance.filter?.toJson(),
  'repoIds': ?instance.repoIds,
  'branch': ?instance.branch,
  'author': ?instance.author,
  'prState': ?_$DocumentSourceInputPrStateEnumEnumMap[instance.prState],
  'prNumbers': ?instance.prNumbers,
  'from': ?instance.from?.toIso8601String(),
  'to': ?instance.to?.toIso8601String(),
};

const _$DocumentSourceInputKindEnumEnumMap = {
  DocumentSourceInputKindEnum.report: 'report',
  DocumentSourceInputKindEnum.tickets: 'tickets',
  DocumentSourceInputKindEnum.commits: 'commits',
  DocumentSourceInputKindEnum.pulls: 'pulls',
  DocumentSourceInputKindEnum.repo: 'repo',
};

const _$DocumentSourceInputTemplateEnumEnumMap = {
  DocumentSourceInputTemplateEnum.status: 'status',
  DocumentSourceInputTemplateEnum.releaseNotes: 'release_notes',
  DocumentSourceInputTemplateEnum.prReview: 'pr_review',
  DocumentSourceInputTemplateEnum.repoReview: 'repo_review',
  DocumentSourceInputTemplateEnum.ticketSummary: 'ticket_summary',
  DocumentSourceInputTemplateEnum.blank: 'blank',
};

const _$DocumentSourceInputPrStateEnumEnumMap = {
  DocumentSourceInputPrStateEnum.open: 'open',
  DocumentSourceInputPrStateEnum.merged: 'merged',
  DocumentSourceInputPrStateEnum.all: 'all',
};
