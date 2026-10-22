import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import 'documents_logic.dart';

/// Downloads the current version of a document as `md` or `pdf` and opens
/// the system share sheet with it. The first PDF of a version is made on
/// the server: it answers 202 until then, and this asks again for up to a
/// minute.
Future<void> downloadDocument(BuildContext context, WidgetRef ref, int id, String format) async {
  final l = AppLocalizations.of(context);
  final api = ref.read(apiProvider);
  if (api == null) return;
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  final deadline = DateTime.now().add(const Duration(seconds: 60));
  var told = false;
  try {
    while (true) {
      final res = await api.dio.get<List<int>>(
        '/documents/$id/download',
        queryParameters: {'format': format},
        options: Options(responseType: ResponseType.bytes, receiveTimeout: const Duration(seconds: 60)),
      );
      if (res.statusCode == 202) {
        if (!told && context.mounted) {
          told = true;
          showSnack(context, l.mdocumentsPreparingPdf);
        }
        if (DateTime.now().isAfter(deadline)) {
          if (context.mounted) showSnack(context, l.mdocumentsPdfSlow);
          return;
        }
        await Future<void>.delayed(retryAfter(res.headers.value('retry-after')));
        if (!context.mounted) return;
        continue;
      }
      final name = fileNameFromDisposition(res.headers.value('content-disposition')) ?? 'document-$id.$format';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(res.data ?? const [], flush: true);
      final mime = format == 'pdf' ? 'application/pdf' : 'text/markdown';
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: mime, name: name)], sharePositionOrigin: origin));
      return;
    }
  } on DioException catch (e) {
    if (context.mounted) showSnack(context, messageFromBody(e.response?.data) ?? l.mdocumentsDownloadFailed);
  } catch (_) {
    if (context.mounted) showSnack(context, l.mdocumentsDownloadFailed);
  }
}
