class Formatters {
  /// Formats a number into a compact "K" format (e.g., 1200 -> 1.2K).
  static String formatNumber(num? value) {
    if (value == null) return "0";
    return value < 1000
        ? value.toStringAsFixed(0)
        : "${(value / 1000).toStringAsFixed(1)}K";
  }
}