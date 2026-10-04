import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// A valid 1×1 PNG, for tests that only need decodable photo bytes.
final tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// Paints a simple tulip bouquet as PNG bytes, so screenshots show a real
/// product photo without a binary fixture in the repo. Must run inside
/// `tester.runAsync` (image encoding is truly async).
Future<Uint8List> drawSamplePhoto({int size = 240}) async {
  final s = size.toDouble();
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint();

  canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, s, s), paint..color = const ui.Color(0xFFF3E7DA));

  // Stems.
  paint
    ..color = const ui.Color(0xFF5E8C4A)
    ..strokeWidth = s * 0.03
    ..style = ui.PaintingStyle.stroke;
  for (final dx in [-0.18, 0.0, 0.18]) {
    canvas.drawLine(ui.Offset(s * (0.5 + dx), s * 0.42),
        ui.Offset(s * 0.5, s * 0.85), paint);
  }

  // Blooms.
  paint.style = ui.PaintingStyle.fill;
  const blooms = [
    (-0.18, 0.36, 0xFFE58FA6),
    (0.0, 0.28, 0xFFD9667F),
    (0.18, 0.36, 0xFFF0B4C3),
  ];
  for (final (dx, dy, color) in blooms) {
    paint.color = ui.Color(color);
    canvas.drawOval(
      ui.Rect.fromCenter(
          center: ui.Offset(s * (0.5 + dx), s * dy),
          width: s * 0.2,
          height: s * 0.26),
      paint,
    );
  }

  // Kraft wrap.
  paint.color = const ui.Color(0xFFC49A6C);
  canvas.drawPath(
    ui.Path()
      ..moveTo(s * 0.28, s * 0.55)
      ..lineTo(s * 0.72, s * 0.55)
      ..lineTo(s * 0.56, s * 0.92)
      ..lineTo(s * 0.44, s * 0.92)
      ..close(),
    paint,
  );

  final image = await recorder.endRecording().toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}
