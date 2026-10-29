import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import 'slides.dart';

/// One slide on a 16:9 frame. It is laid out at a fixed 960 × 540 and
/// scaled to fit, so a slide reads the same small in a list and full
/// screen, with the proportions of the web and the PDF. Slides are paper
/// in both themes, as they print.
class SlideCard extends StatelessWidget {
  const SlideCard(this.slide, {super.key, this.number, this.total, this.radius = 10});
  final Slide slide;
  final int? number;
  final int? total;
  final double radius;

  static const _ink = Color(0xFF1D1D1F);
  static const _dim = Color(0xFF4A4A4F);

  @override
  Widget build(BuildContext context) {
    final size = switch (slide.layout) {
      SlideLayout.dense => 18.6,
      SlideLayout.denser => 15.4,
      _ => 22.7,
    };
    final lead = slide.layout == SlideLayout.lead;
    final base = TextStyle(
      fontSize: lead ? size * 1.15 : size,
      height: slide.layout == SlideLayout.denser ? 1.32 : 1.4,
      color: lead ? _dim : _ink,
    );
    final align = lead ? WrapAlignment.center : WrapAlignment.start;
    TextStyle head(double em) => TextStyle(fontSize: size * em, fontWeight: FontWeight.w700, height: 1.18, color: _ink);
    final body = MarkdownBody(
      data: slide.body,
      styleSheet: MarkdownStyleSheet(
        p: base,
        listBullet: base,
        h1: head(lead ? 2.5 : 2),
        h2: head(1.55),
        h3: head(1.2),
        h1Align: align,
        h2Align: align,
        h3Align: align,
        textAlign: align,
        a: base.copyWith(color: const Color(0xFF1A5FB4)),
        code: TextStyle(fontFamily: AgntsFonts.mono, fontSize: size * 0.8, color: _ink, backgroundColor: const Color(0xFFF3F3F5)),
        codeblockDecoration: BoxDecoration(color: const Color(0xFFF6F6F8), borderRadius: BorderRadius.circular(4)),
        tableBody: base.copyWith(fontSize: size * 0.8),
        tableHead: base.copyWith(fontSize: size * 0.8, fontWeight: FontWeight.w700),
        tableBorder: TableBorder.all(color: const Color(0xFFD5D5D8)),
        blockquoteDecoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFFD5D5D8), width: 3)),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12),
      ),
    );
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: Colors.white,
          child: FittedBox(
            child: SizedBox(
              width: 960,
              height: 540,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(68, 49, 68, 53),
                      // Too much text is cut at the frame, as on the web.
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: lead ? SizedBox(height: 438, child: Center(child: body)) : body,
                      ),
                    ),
                  ),
                  if (number != null)
                    Positioned(
                      right: 34,
                      bottom: 23,
                      child: Text('$number / $total', style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A90))),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A deck read on the phone: its slides one under the other, each with its
/// speaker notes. Tapping a slide presents from it.
class SlideDeck extends StatelessWidget {
  const SlideDeck(this.markdown, {super.key});
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final slides = splitSlides(markdown);
    if (slides.isEmpty) return Text(l.mdocumentsNoSlides, style: TextStyle(color: c.ink3));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, s) in slides.indexed) ...[
          if (i > 0) const SizedBox(height: 14),
          GestureDetector(
            onTap: () => presentSlides(context, markdown, start: i),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.line),
              ),
              child: SlideCard(s, number: i + 1, total: slides.length),
            ),
          ),
          if (s.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: c.line3, width: 3)),
                ),
                child: Text(s.notes, style: TextStyle(fontSize: 13.5, color: c.ink2)),
              ),
            ),
        ],
      ],
    );
  }
}

/// Shows a deck full screen, one slide at a time, from slide start.
Future<void> presentSlides(BuildContext context, String markdown, {int start = 0}) => Navigator.of(context, rootNavigator: true).push(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => PresentScreen(markdown: markdown, start: start),
  ),
);

/// A deck full screen: swipe or tap the sides to move, the notes under
/// the slide on demand.
class PresentScreen extends StatefulWidget {
  const PresentScreen({super.key, required this.markdown, this.start = 0});
  final String markdown;
  final int start;

  @override
  State<PresentScreen> createState() => _PresentScreenState();
}

class _PresentScreenState extends State<PresentScreen> {
  late final List<Slide> _slides = splitSlides(widget.markdown);
  late final PageController _pages = PageController(initialPage: widget.start.clamp(0, _slides.isEmpty ? 0 : _slides.length - 1));
  late int _i = _pages.initialPage;
  bool _notes = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pages.dispose();
    super.dispose();
  }

  void _go(int to) {
    if (to < 0 || to >= _slides.length) return;
    _pages.animateToPage(to, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final notes = _slides.isEmpty ? '' : _slides[_i].notes;
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _i = i),
                itemBuilder: (_, i) => LayoutBuilder(
                  builder: (context, box) => GestureDetector(
                    onTapUp: (e) => _go(_i + (e.localPosition.dx < box.maxWidth / 3 ? -1 : 1)),
                    child: Center(child: SlideCard(_slides[i], radius: 0)),
                  ),
                ),
              ),
            ),
            if (_notes)
              Container(
                height: 140,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                child: SingleChildScrollView(
                  child: Text(
                    notes.isEmpty ? l.mdocumentsNoNotes : notes,
                    style: TextStyle(fontSize: 16, height: 1.45, color: notes.isEmpty ? const Color(0xFF888888) : const Color(0xFFEEEEEE)),
                  ),
                ),
              ),
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _i > 0 ? () => _go(_i - 1) : null,
                    tooltip: l.mdocumentsPrevSlide,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: Colors.white,
                  ),
                  Text('${_i + 1} / ${_slides.length}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  IconButton(
                    onPressed: _i < _slides.length - 1 ? () => _go(_i + 1) : null,
                    tooltip: l.mdocumentsNextSlide,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: Colors.white,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _notes = !_notes),
                    child: Text(l.mdocumentsNotes, style: TextStyle(color: _notes ? Colors.white : const Color(0xFF999999))),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: l.mdocumentsStopPresenting,
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
