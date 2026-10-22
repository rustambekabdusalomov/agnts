//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_conflict.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentConflict {
  /// Returns a new [DocumentConflict] instance.
  DocumentConflict({

    required  this.code,

    required  this.message,

     this.current,
  });

  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'current',
    required: false,
    includeIfNull: false,
  )


  final Document? current;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentConflict &&
      other.code == code &&
      other.message == message &&
      other.current == current;

    @override
    int get hashCode =>
        code.hashCode +
        message.hashCode +
        current.hashCode;

  factory DocumentConflict.fromJson(Map<String, dynamic> json) => _$DocumentConflictFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentConflictToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

