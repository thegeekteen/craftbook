import 'dart:math';

import '../utils/quantity.dart';
import 'fake_random.dart';
import 'fake_shop.dart';
import 'fake_vocabulary.dart';

/// The shop's shelf and its makeable things, before any stock number is set.
///
/// Products are drawn first and the materials they need come with them, so a
/// recipe can never name a material the shop doesn't stock. A few unloved
/// materials come along too, because that's what a real shelf is.
class CataloguePlan {
  final List<MaterialPlan> materials;
  final List<ProductPlan> products;

  /// Units the shop added itself, which the app hasn't seeded.
  final List<String> extraUnits;

  const CataloguePlan({
    required this.materials,
    required this.products,
    required this.extraUnits,
  });

  MaterialPlan byRef(int ref) => materials.firstWhere((m) => m.ref == ref);
  ProductPlan productByRef(int ref) => products.firstWhere((p) => p.ref == ref);

  /// One line of a product's recipe, for a plan that has to point at a
  /// specific material.
  BomPlan bomMaterial(ProductPlan product, int index) => product.bom[index];

  /// What one piece of [product] costs in materials, on the shelf prices the
  /// fake shop just typed in. The app works the same number out when it saves
  /// the order; if the two ever disagree, the seeded profit is wrong and the
  /// coverage check says so.
  double costOf(ProductPlan product) {
    if (product.isResell) return qty(product.unitCost);
    var total = 0.0;
    for (final line in product.bom) {
      total += line.piecesFor(1) * byRef(line.materialRef).unitCost;
    }
    return qty(total);
  }
}

/// What an order really takes off the shelf: planned pieces, then whatever the
/// Adjust sheet added or subtracted.
Map<int, double> usedPieces(CataloguePlan catalogue, OrderPlan order) {
  final pieces = <int, double>{};
  for (final item in order.items) {
    final product = catalogue.productByRef(item.productRef);
    if (product.isResell) continue;
    for (final line in product.bom) {
      pieces[line.materialRef] =
          qty((pieces[line.materialRef] ?? 0) + line.piecesFor(item.quantity));
    }
  }
  for (final extra in order.usedMore.entries) {
    pieces[extra.key] = qty((pieces[extra.key] ?? 0) + extra.value);
  }
  for (final less in order.usedLess.entries) {
    pieces[less.key] = qty(max(0, (pieces[less.key] ?? 0) - less.value));
  }
  return pieces;
}

/// What an order reserves and never used: the promise on the shelf, which is
/// what the pip strip hatches and the buy list adds up.
Map<int, double> reservedPieces(CataloguePlan catalogue, OrderPlan order) {
  final pieces = <int, double>{};
  for (final item in order.items) {
    final product = catalogue.productByRef(item.productRef);
    if (product.isResell) continue;
    for (final line in product.bom) {
      pieces[line.materialRef] =
          qty((pieces[line.materialRef] ?? 0) + line.piecesFor(item.quantity));
    }
  }
  return pieces;
}

/// Resell pieces an order holds, by product ref.
Map<int, double> reservedProducts(CataloguePlan catalogue, OrderPlan order) {
  final pieces = <int, double>{};
  for (final item in order.items) {
    final product = catalogue.productByRef(item.productRef);
    if (!product.isResell) continue;
    pieces[product.ref] = qty((pieces[product.ref] ?? 0) + item.quantity);
  }
  return pieces;
}

/// Material refs with a recipe use them; the rest sit on the shelf alone.
Set<int> usedMaterialRefs(CataloguePlan catalogue) => {
      for (final product in catalogue.products)
        for (final line in product.bom) line.materialRef,
    };

CataloguePlan buildCatalogue(Random random) {
  final handmade = _pickHandmade(random);
  final resell = _pickResell(random);

  // Every slug the recipes name, plus a few materials nothing uses.
  final slugs = <String>{
    for (final template in handmade)
      for (final line in template.bom) line.slug,
    ...mustHaveMaterials,
  };
  final extras = takeSome(
    random,
    [for (final m in materialTemplates) m.slug]
        .where((s) => !slugs.contains(s))
        .toList(),
    3,
    5,
  );
  slugs.addAll(extras);

  final templates = {for (final m in materialTemplates) m.slug: m};
  final refBySlug = <String, int>{};
  final materials = <MaterialPlan>[];
  final usedSlugs = slugs.toList()..sort();

  for (final (index, slug) in usedSlugs.indexed) {
    final template = templates[slug];
    if (template == null) {
      throw StateError('Recipe names "$slug", which is not a known material');
    }
    refBySlug[slug] = index + 1;
    final packSize = _packSize(random, template.packSize);
    final packPrice =
        qty(template.packPrice * random.intBetween(85, 120) / 100);
    materials.add(MaterialPlan(
      ref: index + 1,
      name: random.oneIn(3)
          ? '${template.name} (${random.oneOf(nameTints)})'
          : template.name,
      unit: template.unit,
      packSize: packSize,
      packPrice: packPrice,
      alertLevel: qty(template.alertLevel * random.intBetween(80, 130) / 100),
      role: StockRole.healthy,
      supplier: random.oneOfOrNull(supplierNames, blankOutOf: 3),
    ));
  }

  final products = <ProductPlan>[];
  for (final (index, template) in handmade.indexed) {
    products.add(ProductPlan(
      ref: index + 1,
      name: template.name,
      unit: template.unit,
      sellPrice: qty(template.sellPrice * random.intBetween(90, 115) / 100),
      bom: [
        for (final line in template.bom)
          BomPlan(
            materialRef: refBySlug[line.slug]!,
            uses: line.uses,
            makes: line.makes,
          ),
      ],
      role: StockRole.healthy,
      wantPhoto: index == 0 || index == 3,
      // A thing the shop stopped making that still shows on old orders.
      archiveLater: index == handmade.length - 1,
    ));
  }

  final resellStart = handmade.length;
  for (final (offset, template) in resell.indexed) {
    products.add(ProductPlan(
      ref: resellStart + offset + 1,
      name: template.name,
      unit: template.unit,
      sellPrice: qty(template.sellPrice * random.intBetween(90, 115) / 100),
      isResell: true,
      unitCost: qty(template.unitCost * random.intBetween(90, 110) / 100),
      alertLevel: random.intBetween(3, 12).toDouble(),
      role: StockRole.healthy,
      archiveLater: offset == resell.length - 1 && resell.length > 2,
    ));
  }

  final wantedUnits = {
    for (final m in materials) m.unit,
    for (final p in products) p.unit,
  };
  final seeded = {'pc', 'sheet', 'm', 'cm', 'g', 'kg', 'ml', 'pack'};

  return CataloguePlan(
    materials: materials,
    products: products,
    extraUnits: [
      ...wantedUnits.where((u) => !seeded.contains(u)),
      // A unit nobody has, so the unit list shows an entry that only exists
      // because the shop typed it in.
      'dozen',
    ],
  );
}

/// A pack size a shop would actually buy: whole, and never a float hair off.
double _packSize(Random random, double base) => base <= 5
    ? qty(base * random.intBetween(1, 3))
    : qty(base * random.intBetween(8, 16) / 10);

List<ProductTemplate> _pickHandmade(Random random) {
  final required =
      productTemplates.where((p) => mustHaveProducts.contains(p.name)).toList();
  final others = takeSome(
    random,
    [...productTemplates.where((p) => !mustHaveProducts.contains(p.name))],
    3,
    6,
  );
  return [...required, ...others];
}

List<ResellTemplate> _pickResell(Random random) {
  final required =
      resellTemplates.where((p) => p.name == mustHaveResell).toList();
  final others = takeSome(
    random,
    resellTemplates.where((p) => p.name != mustHaveResell).toList(),
    2,
    4,
  );
  return [...required, ...others];
}
