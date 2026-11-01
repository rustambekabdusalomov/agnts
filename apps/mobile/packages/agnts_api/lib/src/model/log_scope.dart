//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_scope.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LogScope {
  /// Returns a new [LogScope] instance.
  LogScope({

     this.selector,

     this.index,

     this.streams,
  });

  @JsonKey(
    
    name: r'selector',
    required: false,
    includeIfNull: false,
  )


  final String? selector;



  @JsonKey(
    
    name: r'index',
    required: false,
    includeIfNull: false,
  )


  final String? index;



  @JsonKey(
    
    name: r'streams',
    required: false,
    includeIfNull: false,
  )


  final List<String>? streams;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LogScope &&
      other.selector == selector &&
      other.index == index &&
      other.streams == streams;

    @override
    int get hashCode =>
        selector.hashCode +
        index.hashCode +
        streams.hashCode;

  factory LogScope.fromJson(Map<String, dynamic> json) => _$LogScopeFromJson(json);

  Map<String, dynamic> toJson() => _$LogScopeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

