// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_preview_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RepoPreviewInputCWProxy {
  RepoPreviewInput command(String? command);

  RepoPreviewInput port(int? port);

  RepoPreviewInput readyPath(String? readyPath);

  RepoPreviewInput routes(List<String>? routes);

  RepoPreviewInput uiPaths(List<String>? uiPaths);

  RepoPreviewInput login(String? login);

  RepoPreviewInput env(String? env);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoPreviewInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoPreviewInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoPreviewInput call({
    String? command,
    int? port,
    String? readyPath,
    List<String>? routes,
    List<String>? uiPaths,
    String? login,
    String? env,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRepoPreviewInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRepoPreviewInput.copyWith.fieldName(...)`
class _$RepoPreviewInputCWProxyImpl implements _$RepoPreviewInputCWProxy {
  const _$RepoPreviewInputCWProxyImpl(this._value);

  final RepoPreviewInput _value;

  @override
  RepoPreviewInput command(String? command) => this(command: command);

  @override
  RepoPreviewInput port(int? port) => this(port: port);

  @override
  RepoPreviewInput readyPath(String? readyPath) => this(readyPath: readyPath);

  @override
  RepoPreviewInput routes(List<String>? routes) => this(routes: routes);

  @override
  RepoPreviewInput uiPaths(List<String>? uiPaths) => this(uiPaths: uiPaths);

  @override
  RepoPreviewInput login(String? login) => this(login: login);

  @override
  RepoPreviewInput env(String? env) => this(env: env);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RepoPreviewInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RepoPreviewInput(...).copyWith(id: 12, name: "My name")
  /// ````
  RepoPreviewInput call({
    Object? command = const $CopyWithPlaceholder(),
    Object? port = const $CopyWithPlaceholder(),
    Object? readyPath = const $CopyWithPlaceholder(),
    Object? routes = const $CopyWithPlaceholder(),
    Object? uiPaths = const $CopyWithPlaceholder(),
    Object? login = const $CopyWithPlaceholder(),
    Object? env = const $CopyWithPlaceholder(),
  }) {
    return RepoPreviewInput(
      command: command == const $CopyWithPlaceholder()
          ? _value.command
          // ignore: cast_nullable_to_non_nullable
          : command as String?,
      port: port == const $CopyWithPlaceholder()
          ? _value.port
          // ignore: cast_nullable_to_non_nullable
          : port as int?,
      readyPath: readyPath == const $CopyWithPlaceholder()
          ? _value.readyPath
          // ignore: cast_nullable_to_non_nullable
          : readyPath as String?,
      routes: routes == const $CopyWithPlaceholder()
          ? _value.routes
          // ignore: cast_nullable_to_non_nullable
          : routes as List<String>?,
      uiPaths: uiPaths == const $CopyWithPlaceholder()
          ? _value.uiPaths
          // ignore: cast_nullable_to_non_nullable
          : uiPaths as List<String>?,
      login: login == const $CopyWithPlaceholder()
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as String?,
      env: env == const $CopyWithPlaceholder()
          ? _value.env
          // ignore: cast_nullable_to_non_nullable
          : env as String?,
    );
  }
}

extension $RepoPreviewInputCopyWith on RepoPreviewInput {
  /// Returns a callable class that can be used as follows: `instanceOfRepoPreviewInput.copyWith(...)` or like so:`instanceOfRepoPreviewInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RepoPreviewInputCWProxy get copyWith => _$RepoPreviewInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepoPreviewInput _$RepoPreviewInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RepoPreviewInput', json, ($checkedConvert) {
      final val = RepoPreviewInput(
        command: $checkedConvert('command', (v) => v as String?),
        port: $checkedConvert('port', (v) => (v as num?)?.toInt()),
        readyPath: $checkedConvert('readyPath', (v) => v as String?),
        routes: $checkedConvert(
          'routes',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        uiPaths: $checkedConvert(
          'uiPaths',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        login: $checkedConvert('login', (v) => v as String?),
        env: $checkedConvert('env', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$RepoPreviewInputToJson(RepoPreviewInput instance) =>
    <String, dynamic>{
      'command': ?instance.command,
      'port': ?instance.port,
      'readyPath': ?instance.readyPath,
      'routes': ?instance.routes,
      'uiPaths': ?instance.uiPaths,
      'login': ?instance.login,
      'env': ?instance.env,
    };
