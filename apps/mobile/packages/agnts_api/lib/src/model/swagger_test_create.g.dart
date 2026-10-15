// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_test_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwaggerTestCreateCWProxy {
  SwaggerTestCreate title(String? title);

  SwaggerTestCreate specUrl(String? specUrl);

  SwaggerTestCreate specRef(String? specRef);

  SwaggerTestCreate baseUrl(String baseUrl);

  SwaggerTestCreate operations(List<String>? operations);

  SwaggerTestCreate writeEnabled(bool? writeEnabled);

  SwaggerTestCreate notProduction(bool? notProduction);

  SwaggerTestCreate auth(SwaggerAuthInput? auth);

  SwaggerTestCreate repoId(int? repoId);

  SwaggerTestCreate notes(String? notes);

  SwaggerTestCreate rateLimit(int? rateLimit);

  SwaggerTestCreate maxRequests(int? maxRequests);

  SwaggerTestCreate priority(SwaggerTestCreatePriorityEnum? priority);

  SwaggerTestCreate start(SwaggerTestCreateStartEnum? start);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerTestCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerTestCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerTestCreate call({
    String? title,
    String? specUrl,
    String? specRef,
    String baseUrl,
    List<String>? operations,
    bool? writeEnabled,
    bool? notProduction,
    SwaggerAuthInput? auth,
    int? repoId,
    String? notes,
    int? rateLimit,
    int? maxRequests,
    SwaggerTestCreatePriorityEnum? priority,
    SwaggerTestCreateStartEnum? start,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwaggerTestCreate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwaggerTestCreate.copyWith.fieldName(...)`
class _$SwaggerTestCreateCWProxyImpl implements _$SwaggerTestCreateCWProxy {
  const _$SwaggerTestCreateCWProxyImpl(this._value);

  final SwaggerTestCreate _value;

  @override
  SwaggerTestCreate title(String? title) => this(title: title);

  @override
  SwaggerTestCreate specUrl(String? specUrl) => this(specUrl: specUrl);

  @override
  SwaggerTestCreate specRef(String? specRef) => this(specRef: specRef);

  @override
  SwaggerTestCreate baseUrl(String baseUrl) => this(baseUrl: baseUrl);

  @override
  SwaggerTestCreate operations(List<String>? operations) =>
      this(operations: operations);

  @override
  SwaggerTestCreate writeEnabled(bool? writeEnabled) =>
      this(writeEnabled: writeEnabled);

  @override
  SwaggerTestCreate notProduction(bool? notProduction) =>
      this(notProduction: notProduction);

  @override
  SwaggerTestCreate auth(SwaggerAuthInput? auth) => this(auth: auth);

  @override
  SwaggerTestCreate repoId(int? repoId) => this(repoId: repoId);

  @override
  SwaggerTestCreate notes(String? notes) => this(notes: notes);

  @override
  SwaggerTestCreate rateLimit(int? rateLimit) => this(rateLimit: rateLimit);

  @override
  SwaggerTestCreate maxRequests(int? maxRequests) =>
      this(maxRequests: maxRequests);

  @override
  SwaggerTestCreate priority(SwaggerTestCreatePriorityEnum? priority) =>
      this(priority: priority);

  @override
  SwaggerTestCreate start(SwaggerTestCreateStartEnum? start) =>
      this(start: start);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwaggerTestCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwaggerTestCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  SwaggerTestCreate call({
    Object? title = const $CopyWithPlaceholder(),
    Object? specUrl = const $CopyWithPlaceholder(),
    Object? specRef = const $CopyWithPlaceholder(),
    Object? baseUrl = const $CopyWithPlaceholder(),
    Object? operations = const $CopyWithPlaceholder(),
    Object? writeEnabled = const $CopyWithPlaceholder(),
    Object? notProduction = const $CopyWithPlaceholder(),
    Object? auth = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? rateLimit = const $CopyWithPlaceholder(),
    Object? maxRequests = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? start = const $CopyWithPlaceholder(),
  }) {
    return SwaggerTestCreate(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      specUrl: specUrl == const $CopyWithPlaceholder()
          ? _value.specUrl
          // ignore: cast_nullable_to_non_nullable
          : specUrl as String?,
      specRef: specRef == const $CopyWithPlaceholder()
          ? _value.specRef
          // ignore: cast_nullable_to_non_nullable
          : specRef as String?,
      baseUrl: baseUrl == const $CopyWithPlaceholder()
          ? _value.baseUrl
          // ignore: cast_nullable_to_non_nullable
          : baseUrl as String,
      operations: operations == const $CopyWithPlaceholder()
          ? _value.operations
          // ignore: cast_nullable_to_non_nullable
          : operations as List<String>?,
      writeEnabled: writeEnabled == const $CopyWithPlaceholder()
          ? _value.writeEnabled
          // ignore: cast_nullable_to_non_nullable
          : writeEnabled as bool?,
      notProduction: notProduction == const $CopyWithPlaceholder()
          ? _value.notProduction
          // ignore: cast_nullable_to_non_nullable
          : notProduction as bool?,
      auth: auth == const $CopyWithPlaceholder()
          ? _value.auth
          // ignore: cast_nullable_to_non_nullable
          : auth as SwaggerAuthInput?,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      rateLimit: rateLimit == const $CopyWithPlaceholder()
          ? _value.rateLimit
          // ignore: cast_nullable_to_non_nullable
          : rateLimit as int?,
      maxRequests: maxRequests == const $CopyWithPlaceholder()
          ? _value.maxRequests
          // ignore: cast_nullable_to_non_nullable
          : maxRequests as int?,
      priority: priority == const $CopyWithPlaceholder()
          ? _value.priority
          // ignore: cast_nullable_to_non_nullable
          : priority as SwaggerTestCreatePriorityEnum?,
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as SwaggerTestCreateStartEnum?,
    );
  }
}

extension $SwaggerTestCreateCopyWith on SwaggerTestCreate {
  /// Returns a callable class that can be used as follows: `instanceOfSwaggerTestCreate.copyWith(...)` or like so:`instanceOfSwaggerTestCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwaggerTestCreateCWProxy get copyWith =>
      _$SwaggerTestCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwaggerTestCreate _$SwaggerTestCreateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwaggerTestCreate', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['baseUrl']);
      final val = SwaggerTestCreate(
        title: $checkedConvert('title', (v) => v as String?),
        specUrl: $checkedConvert('specUrl', (v) => v as String?),
        specRef: $checkedConvert('specRef', (v) => v as String?),
        baseUrl: $checkedConvert('baseUrl', (v) => v as String),
        operations: $checkedConvert(
          'operations',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        writeEnabled: $checkedConvert('writeEnabled', (v) => v as bool?),
        notProduction: $checkedConvert('notProduction', (v) => v as bool?),
        auth: $checkedConvert(
          'auth',
          (v) => v == null
              ? null
              : SwaggerAuthInput.fromJson(v as Map<String, dynamic>),
        ),
        repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
        notes: $checkedConvert('notes', (v) => v as String?),
        rateLimit: $checkedConvert('rateLimit', (v) => (v as num?)?.toInt()),
        maxRequests: $checkedConvert(
          'maxRequests',
          (v) => (v as num?)?.toInt(),
        ),
        priority: $checkedConvert(
          'priority',
          (v) => $enumDecodeNullable(_$SwaggerTestCreatePriorityEnumEnumMap, v),
        ),
        start: $checkedConvert(
          'start',
          (v) => $enumDecodeNullable(_$SwaggerTestCreateStartEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SwaggerTestCreateToJson(SwaggerTestCreate instance) =>
    <String, dynamic>{
      'title': ?instance.title,
      'specUrl': ?instance.specUrl,
      'specRef': ?instance.specRef,
      'baseUrl': instance.baseUrl,
      'operations': ?instance.operations,
      'writeEnabled': ?instance.writeEnabled,
      'notProduction': ?instance.notProduction,
      'auth': ?instance.auth?.toJson(),
      'repoId': ?instance.repoId,
      'notes': ?instance.notes,
      'rateLimit': ?instance.rateLimit,
      'maxRequests': ?instance.maxRequests,
      'priority': ?_$SwaggerTestCreatePriorityEnumEnumMap[instance.priority],
      'start': ?_$SwaggerTestCreateStartEnumEnumMap[instance.start],
    };

const _$SwaggerTestCreatePriorityEnumEnumMap = {
  SwaggerTestCreatePriorityEnum.low: 'low',
  SwaggerTestCreatePriorityEnum.medium: 'medium',
  SwaggerTestCreatePriorityEnum.high: 'high',
};

const _$SwaggerTestCreateStartEnumEnumMap = {
  SwaggerTestCreateStartEnum.code: 'code',
  SwaggerTestCreateStartEnum.queue: 'queue',
};
