//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commit_pull.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommitPull {
  /// Returns a new [CommitPull] instance.
  CommitPull({

    required  this.number,

    required  this.title,

    required  this.state,

    required  this.url,
  });

  @JsonKey(
    
    name: r'number',
    required: true,
    includeIfNull: false,
  )


  final int number;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final CommitPullStateEnum state;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommitPull &&
      other.number == number &&
      other.title == title &&
      other.state == state &&
      other.url == url;

    @override
    int get hashCode =>
        number.hashCode +
        title.hashCode +
        state.hashCode +
        url.hashCode;

  factory CommitPull.fromJson(Map<String, dynamic> json) => _$CommitPullFromJson(json);

  Map<String, dynamic> toJson() => _$CommitPullToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum CommitPullStateEnum {
@JsonValue(r'open')
open(r'open'),
@JsonValue(r'merged')
merged(r'merged'),
@JsonValue(r'closed')
closed(r'closed');

const CommitPullStateEnum(this.value);

final String value;

@override
String toString() => value;
}


