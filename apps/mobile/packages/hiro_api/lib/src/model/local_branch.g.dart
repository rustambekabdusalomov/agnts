// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_branch.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LocalBranchCWProxy {
  LocalBranch name(String name);

  LocalBranch sha(String sha);

  LocalBranch message(String message);

  LocalBranch author(String author);

  LocalBranch date(DateTime? date);

  LocalBranch ahead(int ahead);

  LocalBranch behind(int behind);

  LocalBranch status(LocalBranchStatusEnum status);

  LocalBranch unpushed(int unpushed);

  LocalBranch ticketKey(String? ticketKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LocalBranch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LocalBranch(...).copyWith(id: 12, name: "My name")
  /// ````
  LocalBranch call({
    String name,
    String sha,
    String message,
    String author,
    DateTime? date,
    int ahead,
    int behind,
    LocalBranchStatusEnum status,
    int unpushed,
    String? ticketKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLocalBranch.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLocalBranch.copyWith.fieldName(...)`
class _$LocalBranchCWProxyImpl implements _$LocalBranchCWProxy {
  const _$LocalBranchCWProxyImpl(this._value);

  final LocalBranch _value;

  @override
  LocalBranch name(String name) => this(name: name);

  @override
  LocalBranch sha(String sha) => this(sha: sha);

  @override
  LocalBranch message(String message) => this(message: message);

  @override
  LocalBranch author(String author) => this(author: author);

  @override
  LocalBranch date(DateTime? date) => this(date: date);

  @override
  LocalBranch ahead(int ahead) => this(ahead: ahead);

  @override
  LocalBranch behind(int behind) => this(behind: behind);

  @override
  LocalBranch status(LocalBranchStatusEnum status) => this(status: status);

  @override
  LocalBranch unpushed(int unpushed) => this(unpushed: unpushed);

  @override
  LocalBranch ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LocalBranch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LocalBranch(...).copyWith(id: 12, name: "My name")
  /// ````
  LocalBranch call({
    Object? name = const $CopyWithPlaceholder(),
    Object? sha = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? ahead = const $CopyWithPlaceholder(),
    Object? behind = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? unpushed = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
  }) {
    return LocalBranch(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      sha: sha == const $CopyWithPlaceholder()
          ? _value.sha
          // ignore: cast_nullable_to_non_nullable
          : sha as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      author: author == const $CopyWithPlaceholder()
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime?,
      ahead: ahead == const $CopyWithPlaceholder()
          ? _value.ahead
          // ignore: cast_nullable_to_non_nullable
          : ahead as int,
      behind: behind == const $CopyWithPlaceholder()
          ? _value.behind
          // ignore: cast_nullable_to_non_nullable
          : behind as int,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as LocalBranchStatusEnum,
      unpushed: unpushed == const $CopyWithPlaceholder()
          ? _value.unpushed
          // ignore: cast_nullable_to_non_nullable
          : unpushed as int,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
    );
  }
}

extension $LocalBranchCopyWith on LocalBranch {
  /// Returns a callable class that can be used as follows: `instanceOfLocalBranch.copyWith(...)` or like so:`instanceOfLocalBranch.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LocalBranchCWProxy get copyWith => _$LocalBranchCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalBranch _$LocalBranchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LocalBranch', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'name',
          'sha',
          'message',
          'author',
          'ahead',
          'behind',
          'status',
          'unpushed',
        ],
      );
      final val = LocalBranch(
        name: $checkedConvert('name', (v) => v as String),
        sha: $checkedConvert('sha', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        author: $checkedConvert('author', (v) => v as String),
        date: $checkedConvert(
          'date',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        ahead: $checkedConvert('ahead', (v) => (v as num).toInt()),
        behind: $checkedConvert('behind', (v) => (v as num).toInt()),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$LocalBranchStatusEnumEnumMap, v),
        ),
        unpushed: $checkedConvert('unpushed', (v) => (v as num).toInt()),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LocalBranchToJson(LocalBranch instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sha': instance.sha,
      'message': instance.message,
      'author': instance.author,
      'date': ?instance.date?.toIso8601String(),
      'ahead': instance.ahead,
      'behind': instance.behind,
      'status': _$LocalBranchStatusEnumEnumMap[instance.status]!,
      'unpushed': instance.unpushed,
      'ticketKey': ?instance.ticketKey,
    };

const _$LocalBranchStatusEnumEnumMap = {
  LocalBranchStatusEnum.local: 'local',
  LocalBranchStatusEnum.pushed: 'pushed',
  LocalBranchStatusEnum.unpushed: 'unpushed',
  LocalBranchStatusEnum.differs: 'differs',
};
