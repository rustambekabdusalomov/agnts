//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_link.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantLink {
  /// Returns a new [AssistantLink] instance.
  AssistantLink({

    required  this.kind,

     this.key,

     this.id,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final AssistantLinkKindEnum kind;



      /// The ticket key (kind ticket)
  @JsonKey(
    
    name: r'key',
    required: false,
    includeIfNull: false,
  )


  final String? key;



      /// The CI failure or lesson id
  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantLink &&
      other.kind == kind &&
      other.key == key &&
      other.id == id;

    @override
    int get hashCode =>
        kind.hashCode +
        key.hashCode +
        id.hashCode;

  factory AssistantLink.fromJson(Map<String, dynamic> json) => _$AssistantLinkFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantLinkToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AssistantLinkKindEnum {
@JsonValue(r'ticket')
ticket(r'ticket'),
@JsonValue(r'ci')
ci(r'ci'),
@JsonValue(r'lesson')
lesson(r'lesson');

const AssistantLinkKindEnum(this.value);

final String value;

@override
String toString() => value;
}


