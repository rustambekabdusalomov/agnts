//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_source_input_filter.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentSourceInputFilter {
  /// Returns a new [DocumentSourceInputFilter] instance.
  DocumentSourceInputFilter({

     this.states,

     this.kinds,

     this.repoId,
  });

  @JsonKey(
    
    name: r'states',
    required: false,
    includeIfNull: false,
  )


  final List<String>? states;



  @JsonKey(
    
    name: r'kinds',
    required: false,
    includeIfNull: false,
  )


  final List<String>? kinds;



  @JsonKey(
    
    name: r'repoId',
    required: false,
    includeIfNull: false,
  )


  final int? repoId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentSourceInputFilter &&
      other.states == states &&
      other.kinds == kinds &&
      other.repoId == repoId;

    @override
    int get hashCode =>
        states.hashCode +
        kinds.hashCode +
        repoId.hashCode;

  factory DocumentSourceInputFilter.fromJson(Map<String, dynamic> json) => _$DocumentSourceInputFilterFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentSourceInputFilterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

