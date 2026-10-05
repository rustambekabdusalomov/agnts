// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BranchCWProxy {
  Branch name(String name);

  Branch default_(bool default_);

  Branch sha(String sha);

  Branch message(String message);

  Branch author(String author);

  Branch date(DateTime? date);

  Branch ahead(int ahead);

  Branch behind(int behind);

  Branch ci(CI ci);

  Branch ticketKey(String? ticketKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Branch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Branch(...).copyWith(id: 12, name: "My name")
  /// ````
  Branch call({
    String name,
    bool default_,
    String sha,
    String message,
    String author,
    DateTime? date,
    int ahead,
    int behind,
    CI ci,
    String? ticketKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBranch.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBranch.copyWith.fieldName(...)`
class _$BranchCWProxyImpl implements _$BranchCWProxy {
  const _$BranchCWProxyImpl(this._value);

  final Branch _value;

  @override
  Branch name(String name) => this(name: name);

  @override
  Branch default_(bool default_) => this(default_: default_);

  @override
  Branch sha(String sha) => this(sha: sha);

  @override
  Branch message(String message) => this(message: message);

  @override
  Branch author(String author) => this(author: author);

  @override
  Branch date(DateTime? date) => this(date: date);

  @override
  Branch ahead(int ahead) => this(ahead: ahead);

  @override
  Branch behind(int behind) => this(behind: behind);

  @override
  Branch ci(CI ci) => this(ci: ci);

  @override
  Branch ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Branch(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Branch(...).copyWith(id: 12, name: "My name")
  /// ````
  Branch call({
    Object? name = const $CopyWithPlaceholder(),
    Object? default_ = const $CopyWithPlaceholder(),
    Object? sha = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? ahead = const $CopyWithPlaceholder(),
    Object? behind = const $CopyWithPlaceholder(),
    Object? ci = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
  }) {
    return Branch(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      default_: default_ == const $CopyWithPlaceholder()
          ? _value.default_
          // ignore: cast_nullable_to_non_nullable
          : default_ as bool,
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
      ci: ci == const $CopyWithPlaceholder()
          ? _value.ci
          // ignore: cast_nullable_to_non_nullable
          : ci as CI,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
    );
  }
}

extension $BranchCopyWith on Branch {
  /// Returns a callable class that can be used as follows: `instanceOfBranch.copyWith(...)` or like so:`instanceOfBranch.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BranchCWProxy get copyWith => _$BranchCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Branch _$BranchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Branch', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'name',
          'default',
          'sha',
          'message',
          'author',
          'ahead',
          'behind',
          'ci',
        ],
      );
      final val = Branch(
        name: $checkedConvert('name', (v) => v as String),
        default_: $checkedConvert('default', (v) => v as bool),
        sha: $checkedConvert('sha', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        author: $checkedConvert('author', (v) => v as String),
        date: $checkedConvert(
          'date',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        ahead: $checkedConvert('ahead', (v) => (v as num).toInt()),
        behind: $checkedConvert('behind', (v) => (v as num).toInt()),
        ci: $checkedConvert('ci', (v) => $enumDecode(_$CIEnumMap, v)),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'default_': 'default'});

Map<String, dynamic> _$BranchToJson(Branch instance) => <String, dynamic>{
  'name': instance.name,
  'default': instance.default_,
  'sha': instance.sha,
  'message': instance.message,
  'author': instance.author,
  'date': ?instance.date?.toIso8601String(),
  'ahead': instance.ahead,
  'behind': instance.behind,
  'ci': _$CIEnumMap[instance.ci]!,
  'ticketKey': ?instance.ticketKey,
};

const _$CIEnumMap = {
  CI.ok: 'ok',
  CI.fail: 'fail',
  CI.run: 'run',
  CI.pending: 'pending',
  CI.manual: 'manual',
  CI.skip: 'skip',
  CI.canceled: 'canceled',
  CI.none: 'none',
};
