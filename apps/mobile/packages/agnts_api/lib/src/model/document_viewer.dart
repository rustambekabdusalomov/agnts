//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_viewer.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentViewer {
  /// Returns a new [DocumentViewer] instance.
  DocumentViewer({

    required  this.kind,

    required  this.id,

    required  this.name,

     this.via,

    required  this.you,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final DocumentViewerKindEnum kind;



  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// How a guest said who they are
  @JsonKey(
    
    name: r'via',
    required: false,
    includeIfNull: false,
  )


  final DocumentViewerViaEnum? via;



  @JsonKey(
    
    name: r'you',
    required: true,
    includeIfNull: false,
  )


  final bool you;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentViewer &&
      other.kind == kind &&
      other.id == id &&
      other.name == name &&
      other.via == via &&
      other.you == you;

    @override
    int get hashCode =>
        kind.hashCode +
        id.hashCode +
        name.hashCode +
        via.hashCode +
        you.hashCode;

  factory DocumentViewer.fromJson(Map<String, dynamic> json) => _$DocumentViewerFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentViewerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DocumentViewerKindEnum {
@JsonValue(r'member')
member(r'member'),
@JsonValue(r'guest')
guest(r'guest');

const DocumentViewerKindEnum(this.value);

final String value;

@override
String toString() => value;
}


/// How a guest said who they are
enum DocumentViewerViaEnum {
@JsonValue(r'name')
name(r'name'),
@JsonValue(r'google')
google(r'google'),
@JsonValue(r'account')
account(r'account');

const DocumentViewerViaEnum(this.value);

final String value;

@override
String toString() => value;
}


