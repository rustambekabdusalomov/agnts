// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_repos_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TicketReposInputCWProxy {
  TicketReposInput repoIds(List<int>? repoIds);

  TicketReposInput groupId(int? groupId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketReposInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketReposInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketReposInput call({List<int>? repoIds, int? groupId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTicketReposInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTicketReposInput.copyWith.fieldName(...)`
class _$TicketReposInputCWProxyImpl implements _$TicketReposInputCWProxy {
  const _$TicketReposInputCWProxyImpl(this._value);

  final TicketReposInput _value;

  @override
  TicketReposInput repoIds(List<int>? repoIds) => this(repoIds: repoIds);

  @override
  TicketReposInput groupId(int? groupId) => this(groupId: groupId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TicketReposInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TicketReposInput(...).copyWith(id: 12, name: "My name")
  /// ````
  TicketReposInput call({
    Object? repoIds = const $CopyWithPlaceholder(),
    Object? groupId = const $CopyWithPlaceholder(),
  }) {
    return TicketReposInput(
      repoIds: repoIds == const $CopyWithPlaceholder()
          ? _value.repoIds
          // ignore: cast_nullable_to_non_nullable
          : repoIds as List<int>?,
      groupId: groupId == const $CopyWithPlaceholder()
          ? _value.groupId
          // ignore: cast_nullable_to_non_nullable
          : groupId as int?,
    );
  }
}

extension $TicketReposInputCopyWith on TicketReposInput {
  /// Returns a callable class that can be used as follows: `instanceOfTicketReposInput.copyWith(...)` or like so:`instanceOfTicketReposInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TicketReposInputCWProxy get copyWith => _$TicketReposInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketReposInput _$TicketReposInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TicketReposInput', json, ($checkedConvert) {
      final val = TicketReposInput(
        repoIds: $checkedConvert(
          'repoIds',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        groupId: $checkedConvert('groupId', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TicketReposInputToJson(TicketReposInput instance) =>
    <String, dynamic>{
      'repoIds': ?instance.repoIds,
      'groupId': ?instance.groupId,
    };
