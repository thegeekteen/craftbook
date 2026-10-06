import 'dart:math';

/// The shop's own vocabulary, so a seeded shop reads like a real craft stall
/// rather than `Material 1`, `Product 2`.
///
/// Material and recipe names are keyed by a slug: a product template names the
/// parts it needs. [FakeShopGenerator] asserts every slug resolves, so a typo
/// here fails loudly during development instead of writing an orphan row.
class MaterialTemplate {
  final String slug;
  final String name;

  /// The unit the shop counts it in. Resolved against the shop's unit list,
  /// which is why 'roll' is added by the generator rather than assumed.
  final String unit;
  final double packSize;
  final double packPrice;
  final double alertLevel;

  const MaterialTemplate(
    this.slug,
    this.name,
    this.unit,
    this.packSize,
    this.packPrice, {
    this.alertLevel = 10,
  });
}

/// One BOM line of a recipe: [uses] of the material makes [makes] products.
class BomTemplate {
  final String slug;
  final double uses;
  final double makes;

  const BomTemplate(this.slug, this.uses, [this.makes = 1]);
}

class ProductTemplate {
  final String name;
  final double sellPrice;
  final String unit;
  final List<BomTemplate> bom;

  const ProductTemplate(
    this.name,
    this.sellPrice,
    this.bom, {
    this.unit = 'pc',
  });
}

/// A bought-in product: no recipe, its own shelf, bought by the piece.
class ResellTemplate {
  final String name;
  final double sellPrice;
  final double unitCost;
  final String unit;

  const ResellTemplate(this.name, this.sellPrice, this.unitCost,
      [this.unit = 'pc']);
}

const materialTemplates = [
  MaterialTemplate('yarn', 'Milk cotton yarn', 'pc', 10, 180, alertLevel: 8),
  MaterialTemplate('wire', 'Floral wire 18g', 'pc', 20, 80, alertLevel: 15),
  MaterialTemplate('wrap', 'Cellophane wrap', 'm', 10, 260, alertLevel: 5),
  MaterialTemplate('beads', 'Glass seed beads 2mm', 'g', 50, 120,
      alertLevel: 10),
  MaterialTemplate('rings', 'Jump rings 6mm', 'pc', 100, 80, alertLevel: 20),
  MaterialTemplate('clasp', 'Lobster clasp', 'pc', 50, 150, alertLevel: 10),
  MaterialTemplate('cord', 'Phone strap cord', 'pc', 20, 100, alertLevel: 10),
  MaterialTemplate('resin', 'Resin keychain kit', 'pc', 5, 350, alertLevel: 3),
  MaterialTemplate('jute', 'Jute cord 4mm', 'm', 10, 220, alertLevel: 5),
  MaterialTemplate('felt', 'A4 felt sheet', 'sheet', 20, 150, alertLevel: 6),
  MaterialTemplate('card', 'Kraft card stock A4', 'sheet', 50, 300,
      alertLevel: 10),
  MaterialTemplate('ribbon', 'Satin ribbon', 'm', 20, 140, alertLevel: 8),
  MaterialTemplate('glue', 'Tacky glue', 'ml', 100, 900, alertLevel: 40),
  MaterialTemplate('dowel', 'Botanical dowel 30cm', 'pc', 25, 110,
      alertLevel: 10),
  MaterialTemplate('pearls', 'Faux pearl pins', 'pc', 100, 95, alertLevel: 25),
  MaterialTemplate('washi', 'Washi tape 15mm', 'pc', 12, 160, alertLevel: 4),
  MaterialTemplate('tags', 'Hang tags', 'pc', 100, 60, alertLevel: 20),
  MaterialTemplate('stuffing', 'Polyester stuffing', 'g', 200, 180,
      alertLevel: 30),
  MaterialTemplate('hooks', 'Keyring hooks', 'pc', 100, 70, alertLevel: 20),
  MaterialTemplate('wax', 'Soy wax', 'kg', 5, 2200, alertLevel: 2),
  MaterialTemplate('wicks', 'Candle wicks', 'pc', 50, 90, alertLevel: 12),
  MaterialTemplate('tulle', 'Tulle netting', 'm', 15, 190, alertLevel: 6),
];

/// Handmade products, each naming the materials it eats. `card` shows up with
/// `makes` above 1, so a sheet that yields nine bookmarks reserves a ninth of a
/// sheet — the arithmetic the pip strip has to survive.
const productTemplates = [
  ProductTemplate('Crochet tulip bouquet', 450, [
    BomTemplate('yarn', 3),
    BomTemplate('wire', 7),
    BomTemplate('wrap', 0.5),
    BomTemplate('stuffing', 25),
  ]),
  ProductTemplate('Beaded phone strap', 180, [
    BomTemplate('beads', 3),
    BomTemplate('rings', 2),
    BomTemplate('clasp', 1),
    BomTemplate('cord', 1),
  ]),
  ProductTemplate('Resin keychain', 120, [
    BomTemplate('resin', 1),
    BomTemplate('hooks', 1),
  ]),
  ProductTemplate('Pressed flower bookmark', 90, [
    BomTemplate('card', 1, 9),
    BomTemplate('ribbon', 0.4),
    BomTemplate('wrap', 0.2),
  ]),
  ProductTemplate('Kraft hang tags, set of 6', 60, [
    BomTemplate('tags', 6),
    BomTemplate('jute', 1.2),
  ]),
  ProductTemplate('Scented candle tumbler', 250, [
    BomTemplate('wax', 0.2),
    BomTemplate('wicks', 1),
    BomTemplate('ribbon', 0.5),
    BomTemplate('tags', 1),
  ]),
  ProductTemplate('Felt keyring', 95, [
    BomTemplate('felt', 0.25),
    BomTemplate('rings', 2),
    BomTemplate('hooks', 1),
  ]),
  ProductTemplate('Mini photo album', 380, [
    BomTemplate('card', 4),
    BomTemplate('ribbon', 1.5),
    BomTemplate('glue', 20),
    BomTemplate('dowel', 2),
  ]),
  ProductTemplate('Beaded coaster set', 220, [
    BomTemplate('beads', 40),
    BomTemplate('felt', 1),
    BomTemplate('glue', 15),
  ]),
  ProductTemplate('Paper flower bouquet', 350, [
    BomTemplate('card', 2),
    BomTemplate('wire', 6),
    BomTemplate('tulle', 1.5),
    BomTemplate('washi', 1),
  ]),
  ProductTemplate('Embroidered hoop art', 500, [
    BomTemplate('felt', 2),
    BomTemplate('dowel', 1),
    BomTemplate('cord', 4),
    BomTemplate('tags', 1),
  ]),
  ProductTemplate('Boutonniere set of 3', 150, [
    BomTemplate('yarn', 1),
    BomTemplate('wire', 3),
    BomTemplate('pearls', 4),
    BomTemplate('wrap', 0.3),
  ]),
  ProductTemplate('Gift wrap bundle', 130, [
    BomTemplate('wrap', 3),
    BomTemplate('ribbon', 2),
    BomTemplate('tags', 2),
  ]),
  ProductTemplate('Resin bookmark', 150, [
    BomTemplate('resin', 1),
    BomTemplate('card', 1, 4),
    BomTemplate('hooks', 1),
  ]),
  ProductTemplate('Wedding centrepiece, tall', 1800, [
    BomTemplate('yarn', 12),
    BomTemplate('wire', 24),
    BomTemplate('dowel', 4),
    BomTemplate('tulle', 6),
    BomTemplate('pearls', 30),
    BomTemplate('wrap', 4),
  ]),
  ProductTemplate('Custom gift hamper', 12500, [
    BomTemplate('card', 8),
    BomTemplate('ribbon', 12),
    BomTemplate('tags', 6),
    BomTemplate('wrap', 6),
    BomTemplate('glue', 60),
  ]),
];

const resellTemplates = [
  ResellTemplate('Kraft gift box', 35, 28),
  ResellTemplate('Satin ribbon roll', 45, 22, 'roll'),
  ResellTemplate('Greeting card pack', 120, 80, 'pack'),
  ResellTemplate('Candle refill jar', 90, 55),
  ResellTemplate('Yarn sample pack', 75, 40, 'pack'),
  ResellTemplate('Empty tumbler with lid', 60, 38),
];

/// Slugs every seeded shop must have a material for, because a role or a hard
/// case leans on them: `card` for the many-products-per-piece line, `wrap` and
/// `ribbon` for fractional metres.
const mustHaveMaterials = ['card', 'wrap', 'ribbon', 'yarn', 'beads'];

/// Products every seeded shop must sell: one handmade with a
/// many-products-per-piece BOM, the hamper that makes a headline number wide,
/// the bouquet that eats a fractional metre of wrap, and the coaster set whose
/// beads are bought by the fifty — a bulk order of those is what puts a line
/// needing several packs on the buy list.
const mustHaveProducts = [
  'Pressed flower bookmark',
  'Custom gift hamper',
  'Crochet tulip bouquet',
  'Beaded coaster set',
];
const mustHaveResell = 'Satin ribbon roll';

const customerNames = [
  'Maria Santos',
  'Jun Reyes',
  'Ana Cruz',
  'Lea Bautista',
  'Paolo Lim',
  'Bea Garcia',
  'Carlo Diaz',
  'Dana Uy',
  'Eli Ramos',
  'Faye Lim',
  'Gio Tan',
  'Hana Cruz',
  'Ines Marasigan',
  'Jomar Pascual',
  'Kaye Villanueva',
  'Lorna Dizon',
  'Miko Aquino',
  'Nina Ocampo',
  'Odilon Reyes Jr.',
  'Pia Servio',
];

/// Names that test how far a card will stretch before it ellipsizes. A fixed
/// shop only sees each one once, so they're part of the contract instead of
/// something the dice might happen to produce.
const awkwardCustomerNames = [
  'Maria Cristina del Socorro Santos-de Guzman',
  'San Offay',
  'Ñeno Marasigan-Quiog',
  'J.R. Magsaysay',
];

const addresses = [
  '22 Rizal Ave, Pasig City',
  '9 Kalayaan St, Makati',
  '41 Aguinaldo Hwy, Imus',
  '14 Mabini St, Cubao, Quezon City',
  'Blk 7 Lot 3, Golden Mile, Parañaque',
  'Unit 1204, Vivaldi Residences, BGC Taguig',
  'Purok 4, San Isidro, Imus Cavite, Philippines 4103',
];

const orderNotes = [
  'Gift wrap please, birthday on the 5th',
  'Deliver before noon, the maid will receive it',
  'Invoice for the office, TIN 123-456-789',
  'No pink, she hates pink',
  'Rush — anniversary dinner tonight',
  'Text before leaving the courier',
];

/// One note with no line breaks at all, which is how a paragraph behaves in a
/// card that only ever showed two lines.
const longSingleLineNote =
    'The bride asked for the same palette as her bouquet which she sent a '
    'photo of, so cream tulips with sage ribbon and the dried leaves from '
    'the March order, and her sister is paying so invoice her instead, and '
    'everything has to be ready two days early because the venue will not '
    'accept deliveries after four in the afternoon.';

const wasteReasons = [
  'Cutting',
  'Defect',
  'Dropped it',
  'Colour wrong, redone',
  'Sampled first',
];

const discountLabels = [
  'Loyal customer',
  'Bundle',
  'Advance booking',
  'Bulk order',
  'Market day promo',
  'Sorry for the wait',
  'Student discount',
  'Referral',
];

/// Field name, type, and whether a long answer is expected.
const fieldTemplates = [
  ('Address', 'text', true),
  ('Wrap style', 'choice', false),
  ('Event date', 'date', false),
  ('Card message', 'text', false),
  ('Pieces in set', 'number', false),
  ('Colour', 'text', false),
  ('Delivery note', 'text', true),
];

const choiceOptions = {
  'Wrap style': wrapOptions,
  'Colour': colourOptions,
};

const wrapOptions = ['Kraft', 'Floral', 'None'];
const colourOptions = ['Cream', 'Blush', 'Sage', 'Ivory'];

const supplierNames = [
  'YarnPH',
  'Divisoria Beads',
  'Cebu Resin Supply',
  'National Paper Mall',
  'Tuyo Craft Online',
  'Nassa Craft',
];

const noteTitles = [
  'Packing checklist',
  'Suppliers',
  'Christmas collection ideas',
  'Price list for wholesale',
  'Courier schedules',
  'Studio to-do',
  'Wedding client notes',
  'Bloom order recap',
];

/// How far back the ordinary trading orders reach. Past a year on purpose: the
/// Reports year view can step back to last year, and an empty one there looks
/// exactly like a broken query.
const pastOrderDays = [
  3,
  5,
  8,
  11,
  15,
  19,
  24,
  29,
  34,
  41,
  48,
  55,
  70,
  120,
  200,
  380,
];

/// A short adjective so a different seed names the shelf differently.
const nameTints = [
  'cream',
  'blush',
  'sage',
  'ivory',
  'terracotta',
  'dusty blue',
  'sand',
  'mauve',
];

/// A shop-sized draw from a list: at least [min] and at most [max] entries,
/// never repeating one.
List<T> takeSome<T>(Random random, List<T> options, int min, int max) {
  final count = min + random.nextInt(max - min + 1);
  final pool = [...options]..shuffle(random);
  return pool.take(count > pool.length ? pool.length : count).toList();
}
