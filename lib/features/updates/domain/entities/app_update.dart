import 'package:equatable/equatable.dart';

/// A newer build published as a GitHub release.
class AppUpdate extends Equatable {
  /// Release version without the tag's leading `v`, e.g. `1.0.42`.
  final String version;

  /// Release notes, in Markdown.
  final String notes;

  /// Where the APK comes from. Only the data layer reads it.
  final String downloadUrl;

  const AppUpdate({
    required this.version,
    required this.notes,
    required this.downloadUrl,
  });

  @override
  List<Object?> get props => [version, notes, downloadUrl];
}
