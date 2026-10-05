// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_repo.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TicketRepoCWProxy {
  TicketRepo repoId(int repoId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketRepo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketRepo(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketRepo call({int repoId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTicketRepo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTicketRepo.copyWith.fieldName(...)`
class _$TicketRepoCWProxyImpl implements _$TicketRepoCWProxy {
  const _$TicketRepoCWProxyImpl(this._value);

  final TicketRepo _value;

  @override
  TicketRepo repoId(int repoId) => this(repoId: repoId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketRepo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketRepo(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketRepo call({Object? repoId = const $CopyWithPlaceholder()}) {
    return TicketRepo(
      repoId: repoId == const $CopyWithPlaceholder()
          ? _value.repoId
          // ignore: cast_nullable_to_non_nullable
          : repoId as int,
    );
  }
}

extension $TicketRepoCopyWith on TicketRepo {
  /// Returns a callable class that can be used as follows: `instanceOfTicketRepo.copyWith(...)` or like so:`instanceOfTicketRepo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TicketRepoCWProxy get copyWith => _$TicketRepoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketRepo _$TicketRepoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TicketRepo', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['repoId']);
      final val = TicketRepo(
        repoId: $checkedConvert('repoId', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TicketRepoToJson(TicketRepo instance) =>
    <String, dynamic>{'repoId': instance.repoId};
