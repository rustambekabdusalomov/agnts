// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_ticket.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentTicketCWProxy {
  DocumentTicket key(String key);

  DocumentTicket number(String number);

  DocumentTicket title(String title);

  DocumentTicket state(String state);

  DocumentTicket kind(String kind);

  DocumentTicket linkedBy(int? linkedBy);

  DocumentTicket linkedAt(DateTime linkedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTicket call({
    String key,
    String number,
    String title,
    String state,
    String kind,
    int? linkedBy,
    DateTime linkedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentTicket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentTicket.copyWith.fieldName(...)`
class _$DocumentTicketCWProxyImpl implements _$DocumentTicketCWProxy {
  const _$DocumentTicketCWProxyImpl(this._value);

  final DocumentTicket _value;

  @override
  DocumentTicket key(String key) => this(key: key);

  @override
  DocumentTicket number(String number) => this(number: number);

  @override
  DocumentTicket title(String title) => this(title: title);

  @override
  DocumentTicket state(String state) => this(state: state);

  @override
  DocumentTicket kind(String kind) => this(kind: kind);

  @override
  DocumentTicket linkedBy(int? linkedBy) => this(linkedBy: linkedBy);

  @override
  DocumentTicket linkedAt(DateTime linkedAt) => this(linkedAt: linkedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTicket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTicket(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTicket call({
    Object? key = const $CopyWithPlaceholder(),
    Object? number = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? linkedBy = const $CopyWithPlaceholder(),
    Object? linkedAt = const $CopyWithPlaceholder(),
  }) {
    return DocumentTicket(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as String,
      linkedBy: linkedBy == const $CopyWithPlaceholder()
          ? _value.linkedBy
          // ignore: cast_nullable_to_non_nullable
          : linkedBy as int?,
      linkedAt: linkedAt == const $CopyWithPlaceholder()
          ? _value.linkedAt
          // ignore: cast_nullable_to_non_nullable
          : linkedAt as DateTime,
    );
  }
}

extension $DocumentTicketCopyWith on DocumentTicket {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentTicket.copyWith(...)` or like so:`instanceOfDocumentTicket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentTicketCWProxy get copyWith => _$DocumentTicketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentTicket _$DocumentTicketFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentTicket', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['key', 'number', 'title', 'state', 'kind', 'linkedAt'],
  );
  final val = DocumentTicket(
    key: $checkedConvert('key', (v) => v as String),
    number: $checkedConvert('number', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    state: $checkedConvert('state', (v) => v as String),
    kind: $checkedConvert('kind', (v) => v as String),
    linkedBy: $checkedConvert('linkedBy', (v) => (v as num?)?.toInt()),
    linkedAt: $checkedConvert('linkedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$DocumentTicketToJson(DocumentTicket instance) =>
    <String, dynamic>{
      'key': instance.key,
      'number': instance.number,
      'title': instance.title,
      'state': instance.state,
      'kind': instance.kind,
      'linkedBy': ?instance.linkedBy,
      'linkedAt': instance.linkedAt.toIso8601String(),
    };
