// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommitCWProxy {
  Commit sha(String sha);

  Commit message(String message);

  Commit author(String author);

  Commit date(DateTime? date);

  Commit add(int add);

  Commit del(int del);

  Commit ci(CI ci);

  Commit url(String? url);

  Commit ticketKey(String? ticketKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Commit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Commit(...).copyWith(id: 12, name: "My name")
  /// ````
  Commit call({
    String sha,
    String message,
    String author,
    DateTime? date,
    int add,
    int del,
    CI ci,
    String? url,
    String? ticketKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommit.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommit.copyWith.fieldName(...)`
class _$CommitCWProxyImpl implements _$CommitCWProxy {
  const _$CommitCWProxyImpl(this._value);

  final Commit _value;

  @override
  Commit sha(String sha) => this(sha: sha);

  @override
  Commit message(String message) => this(message: message);

  @override
  Commit author(String author) => this(author: author);

  @override
  Commit date(DateTime? date) => this(date: date);

  @override
  Commit add(int add) => this(add: add);

  @override
  Commit del(int del) => this(del: del);

  @override
  Commit ci(CI ci) => this(ci: ci);

  @override
  Commit url(String? url) => this(url: url);

  @override
  Commit ticketKey(String? ticketKey) => this(ticketKey: ticketKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Commit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Commit(...).copyWith(id: 12, name: "My name")
  /// ````
  Commit call({
    Object? sha = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? add = const $CopyWithPlaceholder(),
    Object? del = const $CopyWithPlaceholder(),
    Object? ci = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? ticketKey = const $CopyWithPlaceholder(),
  }) {
    return Commit(
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
      add: add == const $CopyWithPlaceholder()
          ? _value.add
          // ignore: cast_nullable_to_non_nullable
          : add as int,
      del: del == const $CopyWithPlaceholder()
          ? _value.del
          // ignore: cast_nullable_to_non_nullable
          : del as int,
      ci: ci == const $CopyWithPlaceholder()
          ? _value.ci
          // ignore: cast_nullable_to_non_nullable
          : ci as CI,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      ticketKey: ticketKey == const $CopyWithPlaceholder()
          ? _value.ticketKey
          // ignore: cast_nullable_to_non_nullable
          : ticketKey as String?,
    );
  }
}

extension $CommitCopyWith on Commit {
  /// Returns a callable class that can be used as follows: `instanceOfCommit.copyWith(...)` or like so:`instanceOfCommit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommitCWProxy get copyWith => _$CommitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Commit _$CommitFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Commit', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['sha', 'message', 'author', 'add', 'del', 'ci'],
      );
      final val = Commit(
        sha: $checkedConvert('sha', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        author: $checkedConvert('author', (v) => v as String),
        date: $checkedConvert(
          'date',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        add: $checkedConvert('add', (v) => (v as num).toInt()),
        del: $checkedConvert('del', (v) => (v as num).toInt()),
        ci: $checkedConvert('ci', (v) => $enumDecode(_$CIEnumMap, v)),
        url: $checkedConvert('url', (v) => v as String?),
        ticketKey: $checkedConvert('ticketKey', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CommitToJson(Commit instance) => <String, dynamic>{
  'sha': instance.sha,
  'message': instance.message,
  'author': instance.author,
  'date': ?instance.date?.toIso8601String(),
  'add': instance.add,
  'del': instance.del,
  'ci': _$CIEnumMap[instance.ci]!,
  'url': ?instance.url,
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
