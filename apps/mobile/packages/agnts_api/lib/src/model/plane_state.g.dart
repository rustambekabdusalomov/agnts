// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plane_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlaneStateCWProxy {
  PlaneState name(String name);

  PlaneState group(PlaneStateGroupEnum group);

  PlaneState projects(List<String> projects);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlaneState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlaneState(...).copyWith(id: 12, name: "My name")
  /// ````
  PlaneState call({
    String name,
    PlaneStateGroupEnum group,
    List<String> projects,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlaneState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlaneState.copyWith.fieldName(...)`
class _$PlaneStateCWProxyImpl implements _$PlaneStateCWProxy {
  const _$PlaneStateCWProxyImpl(this._value);

  final PlaneState _value;

  @override
  PlaneState name(String name) => this(name: name);

  @override
  PlaneState group(PlaneStateGroupEnum group) => this(group: group);

  @override
  PlaneState projects(List<String> projects) => this(projects: projects);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlaneState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlaneState(...).copyWith(id: 12, name: "My name")
  /// ````
  PlaneState call({
    Object? name = const $CopyWithPlaceholder(),
    Object? group = const $CopyWithPlaceholder(),
    Object? projects = const $CopyWithPlaceholder(),
  }) {
    return PlaneState(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      group: group == const $CopyWithPlaceholder()
          ? _value.group
          // ignore: cast_nullable_to_non_nullable
          : group as PlaneStateGroupEnum,
      projects: projects == const $CopyWithPlaceholder()
          ? _value.projects
          // ignore: cast_nullable_to_non_nullable
          : projects as List<String>,
    );
  }
}

extension $PlaneStateCopyWith on PlaneState {
  /// Returns a callable class that can be used as follows: `instanceOfPlaneState.copyWith(...)` or like so:`instanceOfPlaneState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlaneStateCWProxy get copyWith => _$PlaneStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaneState _$PlaneStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlaneState', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'group', 'projects']);
      final val = PlaneState(
        name: $checkedConvert('name', (v) => v as String),
        group: $checkedConvert(
          'group',
          (v) => $enumDecode(_$PlaneStateGroupEnumEnumMap, v),
        ),
        projects: $checkedConvert(
          'projects',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PlaneStateToJson(PlaneState instance) =>
    <String, dynamic>{
      'name': instance.name,
      'group': _$PlaneStateGroupEnumEnumMap[instance.group]!,
      'projects': instance.projects,
    };

const _$PlaneStateGroupEnumEnumMap = {
  PlaneStateGroupEnum.backlog: 'backlog',
  PlaneStateGroupEnum.unstarted: 'unstarted',
  PlaneStateGroupEnum.started: 'started',
  PlaneStateGroupEnum.completed: 'completed',
  PlaneStateGroupEnum.cancelled: 'cancelled',
  PlaneStateGroupEnum.triage: 'triage',
};
