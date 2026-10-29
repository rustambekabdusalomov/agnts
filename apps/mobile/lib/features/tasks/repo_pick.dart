import 'package:agnts_api/agnts_api.dart';

/// The repositories a new task works in, as the new-task sheet holds them:
/// the picked ids in order (the first is the main one), and the group they
/// came from. A group stays the source until its members are edited; then
/// the task sends the ids instead.
class RepoPick {
  const RepoPick({this.ids = const [], this.group, this.edited = false});

  /// One repository, or none (0).
  factory RepoPick.single(int id) => RepoPick(ids: id == 0 ? const [] : [id]);

  final List<int> ids;

  /// The group the ids came from (kept after editing, to say so).
  final RepoGroup? group;

  /// Whether the group's members were changed after picking it.
  final bool edited;

  bool get isEmpty => ids.isEmpty;
  bool contains(int id) => ids.contains(id);

  /// The group's active members, in the group's order.
  static List<int> members(RepoGroup g) => [
    for (final m in g.members)
      if (!m.archived) m.repoId,
  ];

  RepoPick pickGroup(RepoGroup g) => RepoPick(ids: members(g), group: g);

  /// Adds a repository at the end, or drops it when picked.
  RepoPick toggle(int id) => ids.contains(id) ? remove(id) : _edit([...ids, id]);

  RepoPick remove(int id) => _edit([
    for (final x in ids)
      if (x != id) x,
  ]);

  RepoPick _edit(List<int> next) => next.isEmpty ? const RepoPick() : RepoPick(ids: next, group: group, edited: group != null);

  /// The untouched group, when the task should be created from it.
  RepoGroup? get wholeGroup => edited || ids.isEmpty ? null : group;

  /// What TaskCreate gets: exactly one of repoId, repoIds or groupId, or
  /// none for a task without a repository.
  ({int? repoId, List<int>? repoIds, int? groupId}) get payload {
    final g = wholeGroup;
    if (g != null) return (repoId: null, repoIds: null, groupId: g.id);
    if (ids.isEmpty) return (repoId: null, repoIds: null, groupId: null);
    if (ids.length == 1) return (repoId: ids.first, repoIds: null, groupId: null);
    return (repoId: null, repoIds: ids, groupId: null);
  }
}
