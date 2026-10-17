//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/run_transcript.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'run_history_page.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RunHistoryPage {
  /// Returns a new [RunHistoryPage] instance.
  RunHistoryPage({

    required  this.items,

     this.nextCursor,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<RunTranscript> items;



      /// Absent on the last page
  @JsonKey(
    
    name: r'nextCursor',
    required: false,
    includeIfNull: false,
  )


  final String? nextCursor;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RunHistoryPage &&
      other.items == items &&
      other.nextCursor == nextCursor;

    @override
    int get hashCode =>
        items.hashCode +
        nextCursor.hashCode;

  factory RunHistoryPage.fromJson(Map<String, dynamic> json) => _$RunHistoryPageFromJson(json);

  Map<String, dynamic> toJson() => _$RunHistoryPageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

