// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RuleCWProxy {
  Rule id(int id);

  Rule kind(RuleKind kind);

  Rule sourceTicket(String? sourceTicket);

  Rule reason(String? reason);

  Rule repoId(int? repoId);

  Rule repoName(String? repoName);

  Rule title(String title);

  Rule body(String body);

  Rule enabled(bool enabled);

  Rule status(RuleStatus status);

  Rule interpretation(String interpretation);

  Rule clarified(String clarified);

  Rule text(String text);

  Rule questions(List<RuleQuestion> questions);

  Rule rounds(int rounds);

  Rule error(String error);

  Rule enforce(RuleEnforce? enforce);

  Rule delivery(RuleDeliveryEnum? delivery);

  Rule skillDescription(String? skillDescription);

  Rule source_(String? source_);

  Rule confidence(num? confidence);

  Rule evidence(int? evidence);

  Rule lastSeen(DateTime? lastSeen);

  Rule watching(bool? watching);

  Rule analyzedAt(DateTime? analyzedAt);

  Rule createdAt(DateTime createdAt);

  Rule updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Rule(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Rule(...).copyWith(id: 12, name: "My name")
  /// ````
  Rule call({
    int id,
    RuleKind kind,
    String? sourceTicket,
    String? reason,
    int? repoId,
    String? repoName,
    String title,
    String body,
    bool enabled,
    RuleStatus status,
    String interpretation,
    String clarified,
    String text,
    List<RuleQuestion> questions,
    int rounds,
    String error,
    RuleEnforce? enforce,
    RuleDeliveryEnum? delivery,
    String? skillDescription,
    String? source_,
    num? confidence,
    int? evidence,
    DateTime? lastSeen,
    bool? watching,
    DateTime? analyzedAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRule.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRule.copyWith.fieldName(...)`
class _$RuleCWProxyImpl implements _$RuleCWProxy {
  const _$RuleCWProxyImpl(this._value);

  final Rule _value;

  @override
  Rule id(int id) => this(id: id);

  @override
  Rule kind(RuleKind kind) => this(kind: kind);

  @override
  Rule sourceTicket(String? sourceTicket) => this(sourceTicket: sourceTicket);

  @override
  Rule reason(String? reason) => this(reason: reason);

  @override
  Rule repoId(int? repoId) => this(repoId: repoId);

  @override
  Rule repoName(String? repoName) => this(repoName: repoName);

  @override
  Rule title(String title) => this(title: title);

  @override
  Rule body(String body) => this(body: body);

  @override
  Rule enabled(bool enabled) => this(enabled: enabled);

  @override
  Rule status(RuleStatus status) => this(status: status);

  @override
  Rule interpretation(String interpretation) =>
      this(interpretation: interpretation);

  @override
  Rule clarified(String clarified) => this(clarified: clarified);

  @override
  Rule text(String text) => this(text: text);

  @override
  Rule questions(List<RuleQuestion> questions) => this(questions: questions);

  @override
  Rule rounds(int rounds) => this(rounds: rounds);

  @override
  Rule error(String error) => this(error: error);

  @override
  Rule enforce(RuleEnforce? enforce) => this(enforce: enforce);

  @override
  Rule delivery(RuleDeliveryEnum? delivery) => this(delivery: delivery);

  @override
  Rule skillDescription(String? skillDescription) =>
      this(skillDescription: skillDescription);

  @override
  Rule source_(String? source_) => this(source_: source_);

  @override
  Rule confidence(num? confidence) => this(confidence: confidence);

  @override
  Rule evidence(int? evidence) => this(evidence: evidence);

  @override
  Rule lastSeen(DateTime? lastSeen) => this(lastSeen: lastSeen);

  @override
  Rule watching(bool? watching) => this(watching: watching);

  @override
  Rule analyzedAt(DateTime? analyzedAt) => this(analyzedAt: analyzedAt);

  @override
  Rule createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Rule updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Rule(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Rule(...).copyWith(id: 12, name: "My name")
  /// ````
  Rule call({
    Object? id = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? sourceTicket = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
    Object? repoName = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? interpretation = const $CopyWithPlaceholder(),
    Object? clarified = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
    Object? questions = const $CopyWithPlaceholder(),
    Object? rounds = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? enforce = const $CopyWithPlaceholder(),
    Object? delivery = const $CopyWithPlaceholder(),
    Object? skillDescription = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? confidence = const $CopyWithPlaceholder(),
    Object? evidence = const $CopyWithPlaceholder(),
    Object? lastSeen = const $CopyWithPlaceholder(),
    Object? watching = const $CopyWithPlaceholder(),
    Object? analyzedAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Rule(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as RuleKind,
      sourceTicket: sourceTicket == const $CopyWithPlaceholder()
          ? _value.sourceTicket
          // ignore: cast_nullable_to_non_nullable
          : sourceTicket as String?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      repoName: repoName == const $CopyWithPlaceholder()
          ? _value.repoName
          // ignore: cast_nullable_to_non_nullable
          : repoName as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as RuleStatus,
      interpretation: interpretation == const $CopyWithPlaceholder()
          ? _value.interpretation
          // ignore: cast_nullable_to_non_nullable
          : interpretation as String,
      clarified: clarified == const $CopyWithPlaceholder()
          ? _value.clarified
          // ignore: cast_nullable_to_non_nullable
          : clarified as String,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
      questions: questions == const $CopyWithPlaceholder()
          ? _value.questions
          // ignore: cast_nullable_to_non_nullable
          : questions as List<RuleQuestion>,
      rounds: rounds == const $CopyWithPlaceholder()
          ? _value.rounds
          // ignore: cast_nullable_to_non_nullable
          : rounds as int,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String,
      enforce: enforce == const $CopyWithPlaceholder()
          ? _value.enforce
          // ignore: cast_nullable_to_non_nullable
          : enforce as RuleEnforce?,
      delivery: delivery == const $CopyWithPlaceholder()
          ? _value.delivery
          // ignore: cast_nullable_to_non_nullable
          : delivery as RuleDeliveryEnum?,
      skillDescription: skillDescription == const $CopyWithPlaceholder()
          ? _value.skillDescription
          // ignore: cast_nullable_to_non_nullable
          : skillDescription as String?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String?,
      confidence: confidence == const $CopyWithPlaceholder()
          ? _value.confidence
          // ignore: cast_nullable_to_non_nullable
          : confidence as num?,
      evidence: evidence == const $CopyWithPlaceholder()
          ? _value.evidence
          // ignore: cast_nullable_to_non_nullable
          : evidence as int?,
      lastSeen: lastSeen == const $CopyWithPlaceholder()
          ? _value.lastSeen
          // ignore: cast_nullable_to_non_nullable
          : lastSeen as DateTime?,
      watching: watching == const $CopyWithPlaceholder()
          ? _value.watching
          // ignore: cast_nullable_to_non_nullable
          : watching as bool?,
      analyzedAt: analyzedAt == const $CopyWithPlaceholder()
          ? _value.analyzedAt
          // ignore: cast_nullable_to_non_nullable
          : analyzedAt as DateTime?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $RuleCopyWith on Rule {
  /// Returns a callable class that can be used as follows: `instanceOfRule.copyWith(...)` or like so:`instanceOfRule.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RuleCWProxy get copyWith => _$RuleCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rule _$RuleFromJson(Map<String, dynamic> json) => $checkedCreate('Rule', json, (
  $checkedConvert,
) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'kind',
      'title',
      'body',
      'enabled',
      'status',
      'interpretation',
      'clarified',
      'text',
      'questions',
      'rounds',
      'error',
      'createdAt',
      'updatedAt',
    ],
  );
  final val = Rule(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    kind: $checkedConvert('kind', (v) => $enumDecode(_$RuleKindEnumMap, v)),
    sourceTicket: $checkedConvert('sourceTicket', (v) => v as String?),
    reason: $checkedConvert('reason', (v) => v as String?),
    repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
    repoName: $checkedConvert('repoName', (v) => v as String?),
    title: $checkedConvert('title', (v) => v as String),
    body: $checkedConvert('body', (v) => v as String),
    enabled: $checkedConvert('enabled', (v) => v as bool),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$RuleStatusEnumMap, v),
    ),
    interpretation: $checkedConvert('interpretation', (v) => v as String),
    clarified: $checkedConvert('clarified', (v) => v as String),
    text: $checkedConvert('text', (v) => v as String),
    questions: $checkedConvert(
      'questions',
      (v) => (v as List<dynamic>)
          .map((e) => RuleQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    rounds: $checkedConvert('rounds', (v) => (v as num).toInt()),
    error: $checkedConvert('error', (v) => v as String),
    enforce: $checkedConvert(
      'enforce',
      (v) => v == null ? null : RuleEnforce.fromJson(v as Map<String, dynamic>),
    ),
    delivery: $checkedConvert(
      'delivery',
      (v) => $enumDecodeNullable(_$RuleDeliveryEnumEnumMap, v),
    ),
    skillDescription: $checkedConvert('skillDescription', (v) => v as String?),
    source_: $checkedConvert('source', (v) => v as String?),
    confidence: $checkedConvert('confidence', (v) => v as num?),
    evidence: $checkedConvert('evidence', (v) => (v as num?)?.toInt()),
    lastSeen: $checkedConvert(
      'lastSeen',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    watching: $checkedConvert('watching', (v) => v as bool?),
    analyzedAt: $checkedConvert(
      'analyzedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
  'id': instance.id,
  'kind': _$RuleKindEnumMap[instance.kind]!,
  'sourceTicket': ?instance.sourceTicket,
  'reason': ?instance.reason,
  'repoId': ?instance.repoId,
  'repoName': ?instance.repoName,
  'title': instance.title,
  'body': instance.body,
  'enabled': instance.enabled,
  'status': _$RuleStatusEnumMap[instance.status]!,
  'interpretation': instance.interpretation,
  'clarified': instance.clarified,
  'text': instance.text,
  'questions': instance.questions.map((e) => e.toJson()).toList(),
  'rounds': instance.rounds,
  'error': instance.error,
  'enforce': ?instance.enforce?.toJson(),
  'delivery': ?_$RuleDeliveryEnumEnumMap[instance.delivery],
  'skillDescription': ?instance.skillDescription,
  'source': ?instance.source_,
  'confidence': ?instance.confidence,
  'evidence': ?instance.evidence,
  'lastSeen': ?instance.lastSeen?.toIso8601String(),
  'watching': ?instance.watching,
  'analyzedAt': ?instance.analyzedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$RuleKindEnumMap = {
  RuleKind.rule: 'rule',
  RuleKind.context: 'context',
  RuleKind.tip: 'tip',
};

const _$RuleStatusEnumMap = {
  RuleStatus.pending: 'pending',
  RuleStatus.analyzing: 'analyzing',
  RuleStatus.questions: 'questions',
  RuleStatus.ready: 'ready',
  RuleStatus.failed: 'failed',
  RuleStatus.suggested: 'suggested',
};

const _$RuleDeliveryEnumEnumMap = {
  RuleDeliveryEnum.prompt: 'prompt',
  RuleDeliveryEnum.skill: 'skill',
};
