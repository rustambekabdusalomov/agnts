import 'dart:async';
import 'dart:typed_data';

import 'package:agnts_api/agnts_api.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'ui.dart';

// Files and photos on a task, an answer or a retry note. A file uploads as
// soon as it is picked; the action that follows (create, answer, retry)
// sends the ids, which attaches them to the ticket.

/// Most files one task, answer or retry note may carry (the API's limit).
const maxAttachments = 10;

/// The largest file the server takes.
const maxAttachmentBytes = 10 << 20;

/// "312 KB", "2.4 MB".
String fileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// One picked file: uploading until [uploaded] is set.
class PendingUpload {
  PendingUpload._(this.name, this.size, this.bytes);
  final String name;
  final int size;
  // Kept only for pictures, to show the thumbnail without a download.
  Uint8List? bytes;
  Attachment? uploaded;
  double? progress;
  final _cancel = CancelToken();
}

/// The files picked for one action, shared between the [AttachmentPicker]
/// and the screen that submits them.
class AttachmentsController extends ChangeNotifier {
  final List<PendingUpload> _files = [];

  List<PendingUpload> get files => List.unmodifiable(_files);

  /// Ids of the finished uploads, in the order they were picked.
  List<int> get ids => [for (final f in _files) if (f.uploaded != null) f.uploaded!.id];

  /// Whether a file is still uploading: submitting now would leave it out.
  bool get uploading => _files.any((f) => f.uploaded == null);

  /// Forgets the files after the action that used them succeeded.
  void clear() {
    if (_files.isEmpty) return;
    _files.clear();
    notifyListeners();
  }

  void _add(PendingUpload f) {
    _files.add(f);
    notifyListeners();
  }

  void _changed() => notifyListeners();

  bool _remove(PendingUpload f) {
    final had = _files.remove(f);
    if (had) notifyListeners();
    return had;
  }
}

/// The "Attach files" control: Photo, Camera or File, the picked files as
/// removable thumbnails and chips, and the limits' messages.
class AttachmentPicker extends ConsumerStatefulWidget {
  const AttachmentPicker({super.key, required this.controller, this.enabled = true});
  final AttachmentsController controller;
  final bool enabled;

  @override
  ConsumerState<AttachmentPicker> createState() => _AttachmentPickerState();
}

enum _Source { gallery, camera, file }

class _AttachmentPickerState extends ConsumerState<AttachmentPicker> {
  String? _error;

  AttachmentsController get _ctrl => widget.controller;

  Future<void> _choose() async {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final source = await showModalBottomSheet<_Source>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final (s, icon, label) in [
            (_Source.gallery, 'image', l.filesAddPhoto),
            (_Source.camera, 'camera', l.filesCamera),
            (_Source.file, 'file', l.filesAddFile),
          ])
            ListTile(
              leading: HIcon(icon, size: 22, color: c.ink2),
              title: Text(label, style: const TextStyle(fontSize: 16)),
              onTap: () => Navigator.pop(ctx, s),
            ),
        ]),
      ),
    );
    if (source == null || !mounted) return;
    final left = maxAttachments - _ctrl.files.length;
    final picked = <(String, XFile)>[];
    try {
      switch (source) {
        case _Source.gallery:
          // A quality makes the picker hand back JPEG (not HEIC), which the
          // server shows as a picture. pickMultiImage wants a limit of 2+.
          final xs = left >= 2
              ? await ImagePicker().pickMultiImage(imageQuality: 90, limit: left)
              : [?await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90)];
          picked.addAll([for (final x in xs) (x.name, x)]);
        case _Source.camera:
          final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
          if (x != null) picked.add((x.name, x));
        case _Source.file:
          final fs = await FilePicker.pickFiles();
          picked.addAll([for (final f in fs) (f.name, f.xFile)]);
      }
    } catch (_) {
      if (mounted) setState(() => _error = l.commonError);
      return;
    }
    await _take(picked);
  }

  /// Checks the limits, then starts uploading each file.
  Future<void> _take(List<(String, XFile)> picked) async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    if (api == null || picked.isEmpty) return;
    String? error;
    for (final (name, x) in picked) {
      if (_ctrl.files.length >= maxAttachments) {
        error = l.filesTooMany('$maxAttachments');
        break;
      }
      try {
        final size = await x.length();
        if (size > maxAttachmentBytes) {
          error = l.filesTooLarge(name);
          continue;
        }
        final f = PendingUpload._(name, size, await x.readAsBytes());
        _ctrl._add(f);
        unawaited(_upload(api.getAttachmentsApi(), f, l));
      } catch (_) {
        error = l.filesFailed(name);
      }
    }
    if (mounted) setState(() => _error = error);
  }

  Future<void> _upload(AttachmentsApi api, PendingUpload f, AppLocalizations l) async {
    try {
      final res = await api.uploadAttachment(
        file: MultipartFile.fromBytes(f.bytes!, filename: f.name),
        cancelToken: f._cancel,
        onSendProgress: (sent, total) {
          f.progress = total > 0 ? sent / total : null;
          _ctrl._changed();
        },
      );
      final a = res.data!;
      if (!_ctrl.files.contains(f)) {
        // Removed while it uploaded.
        unawaited(api.deleteAttachment(id: a.id).then((_) {}, onError: (_) {}));
        return;
      }
      f.uploaded = a;
      if (a.image != true) f.bytes = null;
      _ctrl._changed();
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      _ctrl._remove(f);
      final tooLarge = e is DioException && e.response?.statusCode == 413;
      if (mounted) setState(() => _error = tooLarge ? l.filesTooLarge(f.name) : errorMessage(e, l.filesFailed(f.name)));
    }
  }

  void _removeFile(PendingUpload f) {
    _ctrl._remove(f);
    final a = f.uploaded;
    if (a == null) {
      f._cancel.cancel();
    } else {
      // A pending upload nobody will use; the server drops it later anyway.
      ref.read(apiProvider)?.getAttachmentsApi().deleteAttachment(id: a.id).then((_) {}, onError: (_) {});
    }
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final files = _ctrl.files;
        final busy = files.where((f) => f.uploaded == null).firstOrNull;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (files.isNotEmpty) ...[
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final f in files) _PendingTile(file: f, onRemove: widget.enabled ? () => _removeFile(f) : null),
            ]),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            onPressed: widget.enabled && files.length < maxAttachments ? _choose : null,
            icon: HIcon('attach', size: 18, stroke: 2, color: widget.enabled ? c.ink : c.line3),
            label: Text(l.filesAttach),
          ),
          const SizedBox(height: 6),
          Text(
            busy != null ? l.filesUploading(busy.name) : l.filesHint,
            style: TextStyle(fontSize: 13, height: 1.35, color: c.ink3),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_error!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.badInk)),
            ),
        ]);
      },
    );
  }
}

/// A picked file: its thumbnail or a chip, a progress ring while it uploads,
/// and a remove button.
class _PendingTile extends StatelessWidget {
  const _PendingTile({required this.file, required this.onRemove});
  final PendingUpload file;
  final VoidCallback? onRemove;

  static bool _looksLikePicture(String name) => RegExp(r'\.(png|jpe?g|gif|webp)$', caseSensitive: false).hasMatch(name);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final f = file;
    final picture = f.bytes != null && (f.uploaded?.image ?? _looksLikePicture(f.name));
    final progress = f.uploaded != null
        ? null
        : SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, value: f.progress, color: c.primary));
    final remove = onRemove == null
        ? null
        : Semantics(
            button: true,
            label: l.filesRemove(f.name),
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c.ink.withValues(alpha: 0.75), shape: BoxShape.circle),
                child: HIcon('close', size: 12, stroke: 2.6, color: c.surface),
              ),
            ),
          );
    if (picture) {
      return SizedBox(
        width: 72,
        height: 72,
        child: Stack(children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(f.bytes!, fit: BoxFit.cover, cacheWidth: 216),
            ),
          ),
          if (progress != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: c.surface.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: progress,
              ),
            ),
          if (remove != null) Positioned(top: 4, right: 4, child: remove),
        ]),
      );
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line4), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        progress ?? HIcon('file', size: 18, color: c.ink3),
        const SizedBox(width: 8),
        Flexible(child: _NameSize(name: f.name, size: f.size)),
        if (remove != null) ...[const SizedBox(width: 8), remove],
      ]),
    );
  }
}

class _NameSize extends StatelessWidget {
  const _NameSize({required this.name, required this.size});
  final String name;
  final int size;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
      Text(fileSize(size), style: TextStyle(fontSize: 12, color: c.ink3)),
    ]);
  }
}

/// A ticket's attached files: pictures as thumbnails (tap for full screen),
/// other files as chips with name and size. Nothing when [files] is empty.
class AttachmentList extends StatelessWidget {
  const AttachmentList(this.files, {super.key, this.label});
  final List<Attachment> files;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    if (files.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (label != null) ...[
          Text(label!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
          const SizedBox(height: 6),
        ],
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final a in files)
            if (a.image == true)
              Semantics(
                button: true,
                label: l.filesOpen(a.name),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _FullAttachment(a))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: c.field,
                      child: AttachmentImage(a, fit: BoxFit.cover, cacheWidth: 216),
                    ),
                  ),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxWidth: 260),
                padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line4), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  HIcon('file', size: 18, color: c.ink3),
                  const SizedBox(width: 8),
                  Flexible(child: _NameSize(name: a.name, size: a.size)),
                ]),
              ),
        ]),
      ]),
    );
  }
}

/// An attached picture, loaded with the session's bearer token.
class AttachmentImage extends ConsumerWidget {
  const AttachmentImage(this.file, {super.key, this.fit, this.cacheWidth});
  final Attachment file;
  final BoxFit? fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Agnts.of(context);
    final s = ref.watch(sessionProvider).value;
    if (s == null) return const SizedBox.shrink();
    final url = file.url.startsWith('http') ? file.url : '${s.server}/api${file.url}';
    return Image.network(
      url,
      headers: {'Authorization': 'Bearer ${s.token}'},
      fit: fit,
      cacheWidth: cacheWidth,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))),
      errorBuilder: (context, _, _) => Center(child: HIcon('image', size: 22, color: c.ink3)),
    );
  }
}

/// One picture on its own, with pinch zoom.
class _FullAttachment extends StatelessWidget {
  const _FullAttachment(this.file);
  final Attachment file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(file.name, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(child: AttachmentImage(file, fit: BoxFit.contain)),
      ),
    );
  }
}
