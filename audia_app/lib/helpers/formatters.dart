String formatCount(int count) {
  if (count >= 1000000) {
    final m = (count / 100000).floor() / 10.0;
    if (m == m.roundToDouble()) return '${m.toInt()}M';
    return '${m.toStringAsFixed(1)}M';
  }
  if (count >= 1000) {
    final k = (count / 100).floor() / 10.0;
    if (k == k.roundToDouble()) return '${k.toInt()}K';
    return '${k.toStringAsFixed(1)}K';
  }
  return count.toString();
}
