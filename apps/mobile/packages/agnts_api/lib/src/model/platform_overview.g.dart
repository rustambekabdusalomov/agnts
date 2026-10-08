// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_overview.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlatformOverviewCWProxy {
  PlatformOverview capacity(Capacity capacity);

  PlatformOverview runs(List<PlatformOverviewRunsInner> runs);

  PlatformOverview serverQueue(
    List<PlatformOverviewServerQueueInner> serverQueue,
  );

  PlatformOverview workspaces(int workspaces);

  PlatformOverview users(int users);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformOverview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformOverview(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformOverview call({
    Capacity capacity,
    List<PlatformOverviewRunsInner> runs,
    List<PlatformOverviewServerQueueInner> serverQueue,
    int workspaces,
    int users,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlatformOverview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlatformOverview.copyWith.fieldName(...)`
class _$PlatformOverviewCWProxyImpl implements _$PlatformOverviewCWProxy {
  const _$PlatformOverviewCWProxyImpl(this._value);

  final PlatformOverview _value;

  @override
  PlatformOverview capacity(Capacity capacity) => this(capacity: capacity);

  @override
  PlatformOverview runs(List<PlatformOverviewRunsInner> runs) =>
      this(runs: runs);

  @override
  PlatformOverview serverQueue(
    List<PlatformOverviewServerQueueInner> serverQueue,
  ) => this(serverQueue: serverQueue);

  @override
  PlatformOverview workspaces(int workspaces) => this(workspaces: workspaces);

  @override
  PlatformOverview users(int users) => this(users: users);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlatformOverview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlatformOverview(...).copyWith(id: 12, name: "My name")
  /// ````
  PlatformOverview call({
    Object? capacity = const $CopyWithPlaceholder(),
    Object? runs = const $CopyWithPlaceholder(),
    Object? serverQueue = const $CopyWithPlaceholder(),
    Object? workspaces = const $CopyWithPlaceholder(),
    Object? users = const $CopyWithPlaceholder(),
  }) {
    return PlatformOverview(
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as Capacity,
      runs: runs == const $CopyWithPlaceholder()
          ? _value.runs
          // ignore: cast_nullable_to_non_nullable
          : runs as List<PlatformOverviewRunsInner>,
      serverQueue: serverQueue == const $CopyWithPlaceholder()
          ? _value.serverQueue
          // ignore: cast_nullable_to_non_nullable
          : serverQueue as List<PlatformOverviewServerQueueInner>,
      workspaces: workspaces == const $CopyWithPlaceholder()
          ? _value.workspaces
          // ignore: cast_nullable_to_non_nullable
          : workspaces as int,
      users: users == const $CopyWithPlaceholder()
          ? _value.users
          // ignore: cast_nullable_to_non_nullable
          : users as int,
    );
  }
}

extension $PlatformOverviewCopyWith on PlatformOverview {
  /// Returns a callable class that can be used as follows: `instanceOfPlatformOverview.copyWith(...)` or like so:`instanceOfPlatformOverview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlatformOverviewCWProxy get copyWith => _$PlatformOverviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformOverview _$PlatformOverviewFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PlatformOverview', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'capacity',
      'runs',
      'serverQueue',
      'workspaces',
      'users',
    ],
  );
  final val = PlatformOverview(
    capacity: $checkedConvert(
      'capacity',
      (v) => Capacity.fromJson(v as Map<String, dynamic>),
    ),
    runs: $checkedConvert(
      'runs',
      (v) => (v as List<dynamic>)
          .map(
            (e) =>
                PlatformOverviewRunsInner.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    serverQueue: $checkedConvert(
      'serverQueue',
      (v) => (v as List<dynamic>)
          .map(
            (e) => PlatformOverviewServerQueueInner.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
    workspaces: $checkedConvert('workspaces', (v) => (v as num).toInt()),
    users: $checkedConvert('users', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$PlatformOverviewToJson(PlatformOverview instance) =>
    <String, dynamic>{
      'capacity': instance.capacity.toJson(),
      'runs': instance.runs.map((e) => e.toJson()).toList(),
      'serverQueue': instance.serverQueue.map((e) => e.toJson()).toList(),
      'workspaces': instance.workspaces,
      'users': instance.users,
    };
