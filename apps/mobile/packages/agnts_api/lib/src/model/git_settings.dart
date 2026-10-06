//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'git_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GitSettings {
  /// Returns a new [GitSettings] instance.
  GitSettings({

    required  this.authorName,

    required  this.authorEmail,

    required  this.coAuthor,

    required  this.prTitle,

    required  this.draft,
  });

  @JsonKey(
    
    name: r'authorName',
    required: true,
    includeIfNull: false,
  )


  final String authorName;



  @JsonKey(
    
    name: r'authorEmail',
    required: true,
    includeIfNull: false,
  )


  final String authorEmail;



      /// Add a Co-authored-by agnts line
  @JsonKey(
    
    name: r'coAuthor',
    required: true,
    includeIfNull: false,
  )


  final bool coAuthor;



      /// {key} and {title} are replaced
  @JsonKey(
    
    name: r'prTitle',
    required: true,
    includeIfNull: false,
  )


  final String prTitle;



  @JsonKey(
    
    name: r'draft',
    required: true,
    includeIfNull: false,
  )


  final bool draft;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GitSettings &&
      other.authorName == authorName &&
      other.authorEmail == authorEmail &&
      other.coAuthor == coAuthor &&
      other.prTitle == prTitle &&
      other.draft == draft;

    @override
    int get hashCode =>
        authorName.hashCode +
        authorEmail.hashCode +
        coAuthor.hashCode +
        prTitle.hashCode +
        draft.hashCode;

  factory GitSettings.fromJson(Map<String, dynamic> json) => _$GitSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GitSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

