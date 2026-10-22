// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_source_input_filter.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentSourceInputFilterCWProxy {
  DocumentSourceInputFilter states(List<String>? states);

  DocumentSourceInputFilter kinds(List<String>? kinds);

  DocumentSourceInputFilter repoId(int? repoId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSourceInputFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSourceInputFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSourceInputFilter call({
    List<String>? states,
    List<String>? kinds,
    int? repoId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentSourceInputFilter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentSourceInputFilter.copyWith.fieldName(...)`
class _$DocumentSourceInputFilterCWProxyImpl
    implements _$DocumentSourceInputFilterCWProxy {
  const _$DocumentSourceInputFilterCWProxyImpl(this._value);

  final DocumentSourceInputFilter _value;

  @override
  DocumentSourceInputFilter states(List<String>? states) =>
      this(states: states);

  @override
  DocumentSourceInputFilter kinds(List<String>? kinds) => this(kinds: kinds);

  @override
  DocumentSourceInputFilter repoId(int? repoId) => this(repoId: repoId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentSourceInputFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentSourceInputFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentSourceInputFilter call({
    Object? states = const $CopyWithPlaceholder(),
    Object? kinds = const $CopyWithPlaceholder(),
    Object? repoId = const $CopyWithPlaceholder(),
  }) {
    return DocumentSourceInputFilter(
      states: states == const $CopyWithPlaceholder()
          ? _value.states
          // ignore: cast_nullable_to_non_nullable
          : states as List<String>?,
      kinds: kinds == const $CopyWithPlaceholder()
          ? _value.kinds
          // ignore: cast_nullable_to_non_nullable
          : kinds as List<String>?,
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int?,
    );
  }
}

extension $DocumentSourceInputFilterCopyWith on DocumentSourceInputFilter {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentSourceInputFilter.copyWith(...)` or like so:`instanceOfDocumentSourceInputFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentSourceInputFilterCWProxy get copyWith =>
      _$DocumentSourceInputFilterCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentSourceInputFilter _$DocumentSourceInputFilterFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentSourceInputFilter', json, ($checkedConvert) {
  final val = DocumentSourceInputFilter(
    states: $checkedConvert(
      'states',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    kinds: $checkedConvert(
      'kinds',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    repoId: $checkedConvert('repoId', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$DocumentSourceInputFilterToJson(
  DocumentSourceInputFilter instance,
) => <String, dynamic>{
  'states': ?instance.states,
  'kinds': ?instance.kinds,
  'repoId': ?instance.repoId,
};
