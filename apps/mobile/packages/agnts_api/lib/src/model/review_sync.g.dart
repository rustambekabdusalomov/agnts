// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_sync.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReviewSyncCWProxy {
  ReviewSync repos(int repos);

  ReviewSync open(int open);

  ReviewSync created(int created);

  ReviewSync rereview(int rereview);

  ReviewSync closed(int closed);

  ReviewSync errors(List<String> errors);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewSync(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewSync(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewSync call({
    int repos,
    int open,
    int created,
    int rereview,
    int closed,
    List<String> errors,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReviewSync.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReviewSync.copyWith.fieldName(...)`
class _$ReviewSyncCWProxyImpl implements _$ReviewSyncCWProxy {
  const _$ReviewSyncCWProxyImpl(this._value);

  final ReviewSync _value;

  @override
  ReviewSync repos(int repos) => this(repos: repos);

  @override
  ReviewSync open(int open) => this(open: open);

  @override
  ReviewSync created(int created) => this(created: created);

  @override
  ReviewSync rereview(int rereview) => this(rereview: rereview);

  @override
  ReviewSync closed(int closed) => this(closed: closed);

  @override
  ReviewSync errors(List<String> errors) => this(errors: errors);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReviewSync(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReviewSync(...).copyWith(id: 12, name: "My name")
  /// ````
  ReviewSync call({
    Object? repos = const $CopyWithPlaceholder(),
    Object? open = const $CopyWithPlaceholder(),
    Object? created = const $CopyWithPlaceholder(),
    Object? rereview = const $CopyWithPlaceholder(),
    Object? closed = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
  }) {
    return ReviewSync(
      repos: repos == const $CopyWithPlaceholder()
          ? _value.repos
          // ignore: cast_nullable_to_non_nullable
          : repos as int,
      open: open == const $CopyWithPlaceholder()
          ? _value.open
          // ignore: cast_nullable_to_non_nullable
          : open as int,
      created: created == const $CopyWithPlaceholder()
          ? _value.created
          // ignore: cast_nullable_to_non_nullable
          : created as int,
      rereview: rereview == const $CopyWithPlaceholder()
          ? _value.rereview
          // ignore: cast_nullable_to_non_nullable
          : rereview as int,
      closed: closed == const $CopyWithPlaceholder()
          ? _value.closed
          // ignore: cast_nullable_to_non_nullable
          : closed as int,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as List<String>,
    );
  }
}

extension $ReviewSyncCopyWith on ReviewSync {
  /// Returns a callable class that can be used as follows: `instanceOfReviewSync.copyWith(...)` or like so:`instanceOfReviewSync.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReviewSyncCWProxy get copyWith => _$ReviewSyncCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewSync _$ReviewSyncFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReviewSync', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'repos',
          'open',
          'created',
          'rereview',
          'closed',
          'errors',
        ],
      );
      final val = ReviewSync(
        repos: $checkedConvert('repos', (v) => (v as num).toInt()),
        open: $checkedConvert('open', (v) => (v as num).toInt()),
        created: $checkedConvert('created', (v) => (v as num).toInt()),
        rereview: $checkedConvert('rereview', (v) => (v as num).toInt()),
        closed: $checkedConvert('closed', (v) => (v as num).toInt()),
        errors: $checkedConvert(
          'errors',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReviewSyncToJson(ReviewSync instance) =>
    <String, dynamic>{
      'repos': instance.repos,
      'open': instance.open,
      'created': instance.created,
      'rereview': instance.rereview,
      'closed': instance.closed,
      'errors': instance.errors,
    };
