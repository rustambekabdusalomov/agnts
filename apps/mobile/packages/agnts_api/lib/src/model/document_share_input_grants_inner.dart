//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_share_input_grants_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentShareInputGrantsInner {
  /// Returns a new [DocumentShareInputGrantsInner] instance.
  DocumentShareInputGrantsInner({

    required  this.userId,

    required  this.level,
  });

  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final int userId;



  @JsonKey(
    
    name: r'level',
    required: true,
    includeIfNull: false,
  )


  final DocumentShareInputGrantsInnerLevelEnum level;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentShareInputGrantsInner &&
      other.userId == userId &&
      other.level == level;

    @override
    int get hashCode =>
        userId.hashCode +
        level.hashCode;

  factory DocumentShareInputGrantsInner.fromJson(Map<String, dynamic> json) => _$DocumentShareInputGrantsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentShareInputGrantsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentShareInputGrantsInnerLevelEnum {
@JsonValue(r'view')
view(r'view'),
@JsonValue(r'edit')
edit(r'edit');

const DocumentShareInputGrantsInnerLevelEnum(this.value);

final String value;

@override
String toString() => value;
}


