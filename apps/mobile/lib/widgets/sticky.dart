import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Keeps a header in view at the top of the page while the content under
/// it scrolls past, as far as the content goes; the next one's header then
/// takes over. Pages here are plain lists, not slivers, so the header is
/// laid out above the content once and painted after it, moved down by how
/// far the page scrolled past it (see _StickyLayout).
///
/// Inside another sticky header's content (a file of the Diff section) the
/// header sticks just under the outer one instead of over it.
class StickyHeader extends StatefulWidget {
  const StickyHeader({super.key, required this.header, required this.content});

  /// The header; [stuck] while it is held at the top, to set it apart.
  final Widget Function(bool stuck) header;
  final Widget content;

  @override
  State<StickyHeader> createState() => _StickyHeaderState();
}

/// How far down the page's top the stuck headers around a widget reach.
class _StickyInset extends InheritedWidget {
  const _StickyInset({required this.inset, required super.child});
  final double inset;

  static double of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_StickyInset>()?.inset ?? 0;

  @override
  bool updateShouldNotify(_StickyInset old) => old.inset != inset;
}

class _StickyHeaderState extends State<StickyHeader> {
  final _layoutKey = GlobalKey();
  ScrollPosition? _position;
  double _inset = 0; // the stuck headers around this one
  double _headerHeight = 0;
  bool _stuck = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _inset = _StickyInset.of(context);
    final p = Scrollable.maybeOf(context, axis: Axis.vertical)?.position;
    if (p != _position) {
      _position?.removeListener(_scrolled);
      _position = p?..addListener(_scrolled);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_scrolled);
    super.dispose();
  }

  _RenderStickyLayout? get _render => _layoutKey.currentContext?.findRenderObject() as _RenderStickyLayout?;

  // The header moves in this frame's paint (no rebuild, so no lag behind
  // the scroll); a rebuild only when it gets or loses its "stuck" line.
  void _scrolled() {
    _render?.markNeedsPaint();
    _sync();
  }

  void _sync() {
    final r = _render;
    if (!mounted || r == null || !r.hasSize) return;
    final stuck = r.shiftNow() > 0;
    final h = r.headerHeight;
    if (stuck != _stuck || h != _headerHeight) {
      setState(() {
        _stuck = stuck;
        _headerHeight = h;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    return _StickyLayout(
      key: _layoutKey,
      inset: _inset,
      children: [
        widget.header(_stuck),
        _StickyInset(inset: _inset + _headerHeight, child: widget.content),
      ],
    );
  }
}

/// The header (first child) laid out at the top and the content (second)
/// under it, as a column. The header is painted after the content, moved
/// down to stay [inset] below the top of the page's visible part for as
/// long as the content goes on under it.
class _StickyLayout extends MultiChildRenderObjectWidget {
  const _StickyLayout({super.key, required this.inset, required super.children});
  final double inset;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderStickyLayout(inset);

  @override
  void updateRenderObject(BuildContext context, _RenderStickyLayout render) => render.inset = inset;
}

class _StickyParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderStickyLayout extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _StickyParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _StickyParentData> {
  _RenderStickyLayout(this._inset);

  double _inset;
  set inset(double v) {
    if (v == _inset) return;
    _inset = v;
    markNeedsPaint();
  }

  double get headerHeight => firstChild?.hasSize ?? false ? firstChild!.size.height : 0;

  /// How far down the header goes now: as far as the top of the page's
  /// visible part (plus the inset) is below this box's top, but no further
  /// than the content's end.
  double shiftNow() {
    final header = firstChild;
    final viewport = RenderAbstractViewport.maybeOf(this);
    if (header == null || !hasSize || !header.hasSize || viewport is! RenderBox || !attached) return 0;
    final top = localToGlobal(Offset.zero, ancestor: viewport as RenderObject).dy;
    return (_inset - top).clamp(0.0, math.max(0.0, size.height - header.size.height)).toDouble();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _StickyParentData) child.parentData = _StickyParentData();
  }

  @override
  void performLayout() {
    final header = firstChild!;
    final content = childAfter(header)!;
    final inner = BoxConstraints(maxWidth: constraints.maxWidth, minWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 0);
    header.layout(inner, parentUsesSize: true);
    content.layout(inner, parentUsesSize: true);
    (header.parentData! as _StickyParentData).offset = Offset.zero;
    (content.parentData! as _StickyParentData).offset = Offset(0, header.size.height);
    size = constraints.constrain(Size(math.max(header.size.width, content.size.width), header.size.height + content.size.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final header = firstChild!;
    final content = childAfter(header)!;
    // Where the header goes is worked out now, with the scroll as it is in
    // this frame; hit testing uses the same place.
    (header.parentData! as _StickyParentData).offset = Offset(0, shiftNow());
    context.paintChild(content, offset + (content.parentData! as _StickyParentData).offset);
    context.paintChild(header, offset + (header.parentData! as _StickyParentData).offset);
  }

  // The header is on top: it takes a tap before the content under it.
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final child in [firstChild!, childAfter(firstChild!)!]) {
      final offset = (child.parentData! as _StickyParentData).offset;
      final hit = result.addWithPaintOffset(
        offset: offset,
        position: position,
        hitTest: (r, p) => child.hitTest(r, position: p),
      );
      if (hit) return true;
    }
    return false;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      (firstChild?.getMinIntrinsicHeight(width) ?? 0) + (lastChild?.getMinIntrinsicHeight(width) ?? 0);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      (firstChild?.getMaxIntrinsicHeight(width) ?? 0) + (lastChild?.getMaxIntrinsicHeight(width) ?? 0);

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(firstChild?.getMinIntrinsicWidth(height) ?? 0, lastChild?.getMinIntrinsicWidth(height) ?? 0);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(firstChild?.getMaxIntrinsicWidth(height) ?? 0, lastChild?.getMaxIntrinsicWidth(height) ?? 0);
}
