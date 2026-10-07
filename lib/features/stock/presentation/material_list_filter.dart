import '../../../l10n/gen/app_localizations.dart';
import '../domain/entities/material.dart';

/// Where a material's stock stands. Archived swaps the list for the
/// archived materials, which are left out of every other option.
enum MaterialStockFilter {
  any,
  low,
  promised,
  archived;

  String label(AppLocalizations l10n) => switch (this) {
        any => l10n.stockFilterAny,
        low => l10n.stockFilterLow,
        promised => l10n.stockFilterPromised,
        archived => l10n.stockFilterArchived,
      };
}

/// The materials under a search, answering what each filter would show.
/// Shared by the list and its filter sheet so their counts agree.
class MaterialCatalogueView {
  /// Not archived, matching the search.
  final List<Material> listed;

  /// Archived, matching the search.
  final List<Material> archived;

  /// Whether anything is archived at all, search aside. The Archived option
  /// only shows when it is.
  final bool hasArchived;

  MaterialCatalogueView._(this.listed, this.archived, this.hasArchived);

  /// [query] is matched against material names, case-insensitively.
  factory MaterialCatalogueView({
    required List<Material> materials,
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    final matching = q.isEmpty
        ? materials
        : materials.where((m) => m.name.toLowerCase().contains(q)).toList();
    return MaterialCatalogueView._(
      matching.where((m) => !m.isArchived).toList(),
      matching.where((m) => m.isArchived).toList(),
      materials.any((m) => m.isArchived),
    );
  }

  /// [filter], or Any once there's nothing archived left to show.
  MaterialStockFilter effective(MaterialStockFilter filter) =>
      filter == MaterialStockFilter.archived && !hasArchived
          ? MaterialStockFilter.any
          : filter;

  /// The materials [filter] shows, low stock first, then by name.
  List<Material> apply(MaterialStockFilter filter) {
    final base = filter == MaterialStockFilter.archived ? archived : listed;
    bool passes(Material m) => switch (filter) {
          MaterialStockFilter.any || MaterialStockFilter.archived => true,
          MaterialStockFilter.low => m.isLowStock,
          MaterialStockFilter.promised => m.quantityPromised > 0,
        };
    return base.where(passes).toList()
      ..sort((a, b) {
        if (a.isLowStock != b.isLowStock) return a.isLowStock ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
  }

  /// How many materials [filter] shows.
  int count(MaterialStockFilter filter) => apply(filter).length;
}
