import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// A painted stand-in for a product photo, so some cards show a thumbnail and
/// the rest fall back to their initial.
///
/// Like the rest of the factory this is deterministic for a given [seed] and
/// [index], and drawing it needs `dart:ui`: in a widget test, call it inside
/// `tester.runAsync`.
Future<Uint8List> drawFakePhoto({
  required int seed,
  required int index,
  int size = 240,
}) async {
  final random = Random(seed * 31 + index);
  final s = size.toDouble();
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint();

  final backdrops = const [
    0xFFF3E7DA,
    0xFFE8EFE4,
    0xFFF6E9EE,
    0xFFE7ECF3,
    0xFFFFF3D6,
  ];
  final blooms = const [
    [0xFFE58FA6, 0xFFD9667F, 0xFFF0B4C3],
    [0xFF8FB8DE, 0xFF5E8CC4, 0xFFBFD8EF],
    [0xFFF0C24E, 0xFFDFA02B, 0xFFF7DD97],
    [0xFF9BC48A, 0xFF6E9C5C, 0xFFC7DEC0],
    [0xFFC79BE0, 0xFFA36FCC, 0xFFE0C9F0],
  ];
  final palette = blooms[index % blooms.length];

  canvas.drawRect(ui.Rect.fromLTWH(0, 0, s, s),
      paint..color = ui.Color(backdrops[index % backdrops.length]));

  // Stems lean by a few degrees so no two pictures are identical.
  paint
    ..color = const ui.Color(0xFF5E8C4A)
    ..strokeWidth = s * 0.03
    ..style = ui.PaintingStyle.stroke;
  for (var stem = 0; stem < 3; stem++) {
    final lean = (stem - 1) * (0.14 + random.nextDouble() * 0.06);
    canvas.drawLine(
      ui.Offset(s * (0.5 + lean), s * 0.40),
      ui.Offset(s * 0.5, s * 0.86),
      paint,
    );
  }

  paint.style = ui.PaintingStyle.fill;
  for (var bloom = 0; bloom < 3; bloom++) {
    paint.color = ui.Color(palette[bloom]);
    final dx = (bloom - 1) * 0.19;
    final dy = bloom == 1 ? 0.28 : 0.36;
    canvas.drawOval(
      ui.Rect.fromCenter(
        center: ui.Offset(s * (0.5 + dx), s * dy),
        width: s * 0.2,
        height: s * (0.24 + random.nextDouble() * 0.05),
      ),
      paint,
    );
  }

  // The wrap, in kraft or white depending on where it landed in the shop.
  paint.color =
      index.isEven ? const ui.Color(0xFFC49A6C) : const ui.Color(0xFFEFE9E0);
  canvas.drawPath(
    ui.Path()
      ..moveTo(s * 0.28, s * 0.55)
      ..lineTo(s * 0.72, s * 0.55)
      ..lineTo(s * 0.57, s * 0.93)
      ..lineTo(s * 0.43, s * 0.93)
      ..close(),
    paint,
  );

  final image = await recorder.endRecording().toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}
