// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit_pull.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CommitPullCWProxy {
  CommitPull number(int number);

  CommitPull title(String title);

  CommitPull state(CommitPullStateEnum state);

  CommitPull url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitPull(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitPull(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitPull call({
    int number,
    String title,
    CommitPullStateEnum state,
    String url,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCommitPull.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCommitPull.copyWith.fieldName(...)`
class _$CommitPullCWProxyImpl implements _$CommitPullCWProxy {
  const _$CommitPullCWProxyImpl(this._value);

  final CommitPull _value;

  @override
  CommitPull number(int number) => this(number: number);

  @override
  CommitPull title(String title) => this(title: title);

  @override
  CommitPull state(CommitPullStateEnum state) => this(state: state);

  @override
  CommitPull url(String url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CommitPull(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CommitPull(...).copyWith(id: 12, name: "My name")
  /// ````
  CommitPull call({
    Object? number = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return CommitPull(
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as CommitPullStateEnum,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $CommitPullCopyWith on CommitPull {
  /// Returns a callable class that can be used as follows: `instanceOfCommitPull.copyWith(...)` or like so:`instanceOfCommitPull.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CommitPullCWProxy get copyWith => _$CommitPullCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitPull _$CommitPullFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CommitPull', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['number', 'title', 'state', 'url']);
      final val = CommitPull(
        number: $checkedConvert('number', (v) => (v as num).toInt()),
        title: $checkedConvert('title', (v) => v as String),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$CommitPullStateEnumEnumMap, v),
        ),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CommitPullToJson(CommitPull instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'state': _$CommitPullStateEnumEnumMap[instance.state]!,
      'url': instance.url,
    };

const _$CommitPullStateEnumEnumMap = {
  CommitPullStateEnum.open: 'open',
  CommitPullStateEnum.merged: 'merged',
  CommitPullStateEnum.closed: 'closed',
};
