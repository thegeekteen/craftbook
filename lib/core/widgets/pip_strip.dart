import 'package:flutter/material.dart';

import '../theme/colors.dart';

enum PipSize { small, large }

/// Stock drawn as pieces, the app's signature visual.
///
/// Order left to right: free (green, or red when [isLow]), promised
/// (hatched red), incoming (outlined green, for receive previews),
/// removed (outlined grey, for pack previews), then empty pips up to
/// [alertLevel] so you can see the gap to the reorder line. A thin tick
/// marks the alert level itself.
///
/// Large counts are scaled so the strip never exceeds [maxPips]; one pip
/// then stands for several pieces.
class PipStrip extends StatelessWidget {
  /// Strip length in pieces; anything beyond the filled pips is drawn
  /// empty. Usually pieces on hand.
  final int total;
  final int free;
  final int promised;
  final int incoming;
  final int removed;
  final int alertLevel;
  final bool isLow;
  final bool isWarning;
  final PipSize size;
  final int maxPips;

  const PipStrip({
    super.key,
    required this.total,
    required this.free,
    required this.promised,
    this.incoming = 0,
    this.removed = 0,
    this.alertLevel = 0,
    this.isLow = false,
    this.isWarning = false,
    this.size = PipSize.small,
    this.maxPips = 60,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final freeCount = free.clamp(0, 1 << 30);
    // Only pieces that physically exist get a pip; an overcommitted
    // material shows its shortfall in text, not as extra pips.
    final room = total - freeCount - incoming - removed;
    final promisedCount = promised.clamp(0, room < 0 ? 0 : room);
    final filled = freeCount + promisedCount + incoming + removed;
    // Pad with empty pips up to the reorder level (or [total], if larger).
    final empty = ((alertLevel > total ? alertLevel : total) - filled).clamp(0, 1 << 30);
    final pieces = filled + empty;
    final perPip = pieces <= maxPips ? 1 : (pieces / maxPips).ceil();

    int scaled(int n) => n <= 0 ? 0 : (n / perPip).ceil();

    final kinds = <_Pip>[
      ...List.filled(scaled(freeCount), _Pip.free),
      ...List.filled(scaled(promisedCount), _Pip.promised),
      ...List.filled(scaled(incoming), _Pip.incoming),
      ...List.filled(scaled(removed), _Pip.removed),
      ...List.filled(scaled(empty), _Pip.empty),
    ];
    final markerAt = alertLevel > 0 ? scaled(alertLevel) : -1;

    final w = size == PipSize.large ? 8.0 : 6.0;
    final h = size == PipSize.large ? 16.0 : 11.0;
    final freeColor = isLow ? c.alert : (isWarning ? c.warn : c.go);

    Widget pip(_Pip kind) {
      final radius = BorderRadius.circular(1.5);
      return switch (kind) {
        _Pip.free => _box(w, h, BoxDecoration(color: freeColor, borderRadius: radius)),
        _Pip.promised => _box(
            w,
            h,
            BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: const Alignment(-0.2, -0.6),
                colors: [c.alert, c.alert, c.alertSoft, c.alertSoft],
                stops: const [0, 0.5, 0.5, 1],
                tileMode: TileMode.repeated,
              ),
            ),
          ),
        _Pip.incoming => _box(
            w,
            h,
            BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: c.go, width: 1.5),
            ),
          ),
        _Pip.removed => _box(
            w,
            h,
            BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: c.hair, width: 1),
            ),
          ),
        _Pip.empty => _box(w, h, BoxDecoration(color: c.pipEmpty, borderRadius: radius)),
      };
    }

    final children = <Widget>[];
    for (var i = 0; i < kinds.length; i++) {
      if (i == markerAt) children.add(_marker(h, c.ink));
      children.add(pip(kinds[i]));
    }
    if (markerAt == kinds.length && markerAt > 0) children.add(_marker(h, c.ink));

    return Semantics(
      label: '$freeCount free, $promisedCount promised'
          '${alertLevel > 0 ? ', reorder at $alertLevel' : ''}',
      child: Wrap(spacing: 2, runSpacing: 3, children: children),
    );
  }

  static Widget _box(double w, double h, BoxDecoration d) =>
      Container(width: w, height: h, decoration: d);

  static Widget _marker(double h, Color color) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          width: 2,
          height: h + 4,
          margin: const EdgeInsets.only(top: 0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      );
}

enum _Pip { free, promised, incoming, removed, empty }

/// Key under a [PipStrip] explaining the pip styles.
class PipLegend extends StatelessWidget {
  final bool showPromised;
  final bool showAlert;

  const PipLegend({super.key, this.showPromised = true, this.showAlert = true});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = Theme.of(context).textTheme.bodySmall;
    Widget item(Widget swatch, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [swatch, const SizedBox(width: 5), Text(text, style: style)],
        );
    Widget sw(Color color) => Container(
          width: 7,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        item(sw(c.go), 'free'),
        if (showPromised) item(sw(c.alert), 'promised'),
        if (showAlert)
          item(
            Container(width: 2, height: 13, color: c.ink),
            'reorder level',
          ),
      ],
    );
  }
}
