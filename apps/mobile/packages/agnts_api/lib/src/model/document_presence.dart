//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/document_viewer.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_presence.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentPresence {
  /// Returns a new [DocumentPresence] instance.
  DocumentPresence({

    required  this.viewers,

    required  this.commentsStamp,
  });

  @JsonKey(
    
    name: r'viewers',
    required: true,
    includeIfNull: false,
  )


  final List<DocumentViewer> viewers;



      /// Changes whenever the comments do; fetch them again when it moves
  @JsonKey(
    
    name: r'commentsStamp',
    required: true,
    includeIfNull: false,
  )


  final String commentsStamp;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentPresence &&
      other.viewers == viewers &&
      other.commentsStamp == commentsStamp;

    @override
    int get hashCode =>
        viewers.hashCode +
        commentsStamp.hashCode;

  factory DocumentPresence.fromJson(Map<String, dynamic> json) => _$DocumentPresenceFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentPresenceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

