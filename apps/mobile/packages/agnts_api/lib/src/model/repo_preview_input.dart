//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repo_preview_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RepoPreviewInput {
  /// Returns a new [RepoPreviewInput] instance.
  RepoPreviewInput({

     this.command,

     this.port,

     this.readyPath,

     this.routes,

     this.uiPaths,

     this.login,

     this.env,
  });

  @JsonKey(
    
    name: r'command',
    required: false,
    includeIfNull: false,
  )


  final String? command;



          // minimum: 0
          // maximum: 65535
  @JsonKey(
    
    name: r'port',
    required: false,
    includeIfNull: false,
  )


  final int? port;



  @JsonKey(
    
    name: r'readyPath',
    required: false,
    includeIfNull: false,
  )


  final String? readyPath;



  @JsonKey(
    
    name: r'routes',
    required: false,
    includeIfNull: false,
  )


  final List<String>? routes;



  @JsonKey(
    
    name: r'uiPaths',
    required: false,
    includeIfNull: false,
  )


  final List<String>? uiPaths;



  @JsonKey(
    
    name: r'login',
    required: false,
    includeIfNull: false,
  )


  final String? login;



      /// KEY=value lines; replaces the stored environment, \"\" clears it, absent keeps it
  @JsonKey(
    
    name: r'env',
    required: false,
    includeIfNull: false,
  )


  final String? env;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RepoPreviewInput &&
      other.command == command &&
      other.port == port &&
      other.readyPath == readyPath &&
      other.routes == routes &&
      other.uiPaths == uiPaths &&
      other.login == login &&
      other.env == env;

    @override
    int get hashCode =>
        command.hashCode +
        port.hashCode +
        readyPath.hashCode +
        routes.hashCode +
        uiPaths.hashCode +
        login.hashCode +
        env.hashCode;

  factory RepoPreviewInput.fromJson(Map<String, dynamic> json) => _$RepoPreviewInputFromJson(json);

  Map<String, dynamic> toJson() => _$RepoPreviewInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

