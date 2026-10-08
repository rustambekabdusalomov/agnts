// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_report.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReplayReportCWProxy {
  ReplayReport versions(List<ReplayVersion> versions);

  ReplayReport replays(List<ReplayResult> replays);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplayReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplayReport(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplayReport call({List<ReplayVersion> versions, List<ReplayResult> replays});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReplayReport.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReplayReport.copyWith.fieldName(...)`
class _$ReplayReportCWProxyImpl implements _$ReplayReportCWProxy {
  const _$ReplayReportCWProxyImpl(this._value);

  final ReplayReport _value;

  @override
  ReplayReport versions(List<ReplayVersion> versions) =>
      this(versions: versions);

  @override
  ReplayReport replays(List<ReplayResult> replays) => this(replays: replays);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplayReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplayReport(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplayReport call({
    Object? versions = const $CopyWithPlaceholder(),
    Object? replays = const $CopyWithPlaceholder(),
  }) {
    return ReplayReport(
      versions: versions == const $CopyWithPlaceholder()
          ? _value.versions
          // ignore: cast_nullable_to_non_nullable
          : versions as List<ReplayVersion>,
      replays: replays == const $CopyWithPlaceholder()
          ? _value.replays
          // ignore: cast_nullable_to_non_nullable
          : replays as List<ReplayResult>,
    );
  }
}

extension $ReplayReportCopyWith on ReplayReport {
  /// Returns a callable class that can be used as follows: `instanceOfReplayReport.copyWith(...)` or like so:`instanceOfReplayReport.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReplayReportCWProxy get copyWith => _$ReplayReportCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplayReport _$ReplayReportFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReplayReport', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['versions', 'replays']);
      final val = ReplayReport(
        versions: $checkedConvert(
          'versions',
          (v) => (v as List<dynamic>)
              .map((e) => ReplayVersion.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        replays: $checkedConvert(
          'replays',
          (v) => (v as List<dynamic>)
              .map((e) => ReplayResult.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReplayReportToJson(ReplayReport instance) =>
    <String, dynamic>{
      'versions': instance.versions.map((e) => e.toJson()).toList(),
      'replays': instance.replays.map((e) => e.toJson()).toList(),
    };
