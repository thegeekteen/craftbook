/// Whether dotted version [candidate] is newer than [current]. Missing or
/// non-numeric parts count as 0, so `1.1` equals `1.1.0`, and anything after
/// a `+` or `-` (build number, pre-release) is ignored.
bool isNewerVersion(String candidate, String current) {
  List<int> parts(String v) => v
      .split(RegExp(r'[+-]'))
      .first
      .split('.')
      .map((p) => int.tryParse(p.trim()) ?? 0)
      .toList();
  final a = parts(candidate);
  final b = parts(current);
  final length = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < length; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}
