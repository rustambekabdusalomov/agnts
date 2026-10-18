// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reapply_commit_format200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReapplyCommitFormat200ResponseCWProxy {
  ReapplyCommitFormat200Response changes(
    List<ReapplyCommitFormat200ResponseChangesInner> changes,
  );

  ReapplyCommitFormat200Response ticket(Ticket ticket);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReapplyCommitFormat200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReapplyCommitFormat200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  ReapplyCommitFormat200Response call({
    List<ReapplyCommitFormat200ResponseChangesInner> changes,
    Ticket ticket,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReapplyCommitFormat200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReapplyCommitFormat200Response.copyWith.fieldName(...)`
class _$ReapplyCommitFormat200ResponseCWProxyImpl
    implements _$ReapplyCommitFormat200ResponseCWProxy {
  const _$ReapplyCommitFormat200ResponseCWProxyImpl(this._value);

  final ReapplyCommitFormat200Response _value;

  @override
  ReapplyCommitFormat200Response changes(
    List<ReapplyCommitFormat200ResponseChangesInner> changes,
  ) => this(changes: changes);

  @override
  ReapplyCommitFormat200Response ticket(Ticket ticket) => this(ticket: ticket);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReapplyCommitFormat200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReapplyCommitFormat200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  ReapplyCommitFormat200Response call({
    Object? changes = const $CopyWithPlaceholder(),
    Object? ticket = const $CopyWithPlaceholder(),
  }) {
    return ReapplyCommitFormat200Response(
      changes: changes == const $CopyWithPlaceholder()
          ? _value.changes
          // ignore: cast_nullable_to_non_nullable
          : changes as List<ReapplyCommitFormat200ResponseChangesInner>,
      ticket: ticket == const $CopyWithPlaceholder()
          ? _value.ticket
          // ignore: cast_nullable_to_non_nullable
          : ticket as Ticket,
    );
  }
}

extension $ReapplyCommitFormat200ResponseCopyWith
    on ReapplyCommitFormat200Response {
  /// Returns a callable class that can be used as follows: `instanceOfReapplyCommitFormat200Response.copyWith(...)` or like so:`instanceOfReapplyCommitFormat200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReapplyCommitFormat200ResponseCWProxy get copyWith =>
      _$ReapplyCommitFormat200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReapplyCommitFormat200Response _$ReapplyCommitFormat200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReapplyCommitFormat200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['changes', 'ticket']);
  final val = ReapplyCommitFormat200Response(
    changes: $checkedConvert(
      'changes',
      (v) => (v as List<dynamic>)
          .map(
            (e) => ReapplyCommitFormat200ResponseChangesInner.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
    ticket: $checkedConvert(
      'ticket',
      (v) => Ticket.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReapplyCommitFormat200ResponseToJson(
  ReapplyCommitFormat200Response instance,
) => <String, dynamic>{
  'changes': instance.changes.map((e) => e.toJson()).toList(),
  'ticket': instance.ticket.toJson(),
};
