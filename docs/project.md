# Craftbook - Business Context & Current State

## What is Craftbook?

Craftbook is an offline-first Android application designed for small craft businesses to manage orders, track materials (BOM - Bill of Materials), and calculate real profit. The app treats every order as a material consumer — when you save an order, it reserves pieces; when you pack, it deducts them.

### Core Value Proposition
- **Offline-first**: No accounts, no sync. All data lives on-device. The only network call is the user-triggered update check against GitHub releases
- **BOM-aware orders**: Orders are created with products, but the app expands them into materials behind the scenes
- **Real profit tracking**: Profit = What the customer paid − Tax − Materials (actual, including waste) − Channel fees − Shipping
- **Getting paid**: Orders are paid or unpaid, and Reports shows who still owes money
- **Stock as pips**: Visual representation of stock levels showing free vs. promised pieces

### Target Platform
- Android only (Flutter)
- Minimum SDK: API 21 (Android 5.0)
- Target/Compile SDK: API 36 (Android 16)

---

## Feature Flows

The app is built around 6 main user flows:

### Flow 1: Day View (Today)
- **Today screen**: Shows orders due today ("Ships today") and orders placed today ("New today")
- **Status filter chips**: Filter by To pack, Packed, Shipped (persistent while mounted). Cancelled orders don't show on day views
- **Calendar views**: Week and month views with period navigation, also with status filters
- **Alert banners**: Visual warnings for materials below alert level
- **Order cards**: Show customer name, status, ship-by date, channel, and recalculated profit
- **Search**: Search orders by customer name or order ID

### Flow 2: Order Creation
- **3-step wizard**: Customer details → Add products → Review & save
- **Back navigation**: Users can go back to previous steps without losing data
- **Product picker**: Shows buildable quantity from current stock
- **Channel selection**: Shopee, TikTok, Lazada, Facebook, Walk-in with fee rates
- **Order fields**: The shop's own extra details (address, size, wrap, event date…) asked for after the customer name
- **Discounts, tax, paid**: The review step adds discount lines (one-tap presets or typed in), switches the shop's tax on or off for this order, and sets paid (defaulting from the channel). Packed orders edit these on their details form
- **Auto-calculation**: Materials cost, channel fees (after discount), tax and profit calculated automatically

### Flow 3: Pack & Ship
- **Order details**: Full view with dates, channel, items (with names), materials (with names), financial summary
- **Status stepper**: Visual progress with icons (🧾 Placed → 📦 Packed → 🚚 Shipped)
- **Material adjustment**: Record actual materials used vs. planned (waste tracking)
- **Profit recalculation**: Profit recalculated from components after material adjustment
- **Pack/Ship actions**: Updates status, deducts stock, recalculates profit

### Flow 4: Stock Management
- **Materials list**: The Materials tab of the Inventory page (`/materials` redirects there). Search by material name; the app-bar Filter sheet picks Low, Promised or Archived, with counts, shown as a removable chip
- **Material detail**: Stock overview with pip strip, receive/adjust actions, movements, products using it
- **Receive stock**: Packs received + price per pack with live weighted average cost preview. Pack size shown read-only
- **Delete material**: Blocked if used in a BOM or an order; its stock history goes with it. Archive it otherwise

### Flow 5: Products & BOM
- **Products list**: The Products tab of the Inventory page. Search by product name, shows margin and buildable quantity. The app-bar Filter sheet combines a Type (Handmade/Resell) with a Stock level (Low/Short/Archived), each option counted; active filters show as removable chips
- **BOM editor**: Define what materials go into each product with stepper inputs (Uses, and Makes for one piece that yields several products)
- **Channel management**: Configure fee rates for each sales channel
- **Delete product**: Blocked if referenced by orders or has BOM items

### Flow 6: Reports
- **Period selector**: Week / Month / Year / Custom tabs. Prev/next for the first three; Custom opens a date range picker
- **Filters**: Channel, products contained, packed/shipped, paid/unpaid, with/without discount, with/without tax, order total range. Active filters show as removable chips and narrow every number on the page
- **Summary card**: Net profit, sales, discounts, tax (in prices, or added on top and passed on), material cost, channel fees, shipping, and how much is still unpaid
- **Waiting for payment**: All-time unpaid orders grouped by customer (also under More)
- **Per-product breakdown**: Product name, quantity sold, sales, profit (allocated by sales proportion)
- **Waste section**: Per-material breakdown showing name, pcs wasted, cost
- **Scope**: Includes packed + shipped orders. Profit always recalculated from components

### Settings
- **Export backup**: Raw SQLite file export via file picker (Android SAF compatible)
- **Import backup**: Pick a SQLite file, copy over current DB, prompt restart (with confirmation dialog)
- **Navigation hub**: Links to Channels, Order fields, Units, Buy List, Waiting for payment, Discounts, Notes, Social shortcuts
- **Currency**: Pick from common currencies or type a symbol; only the display changes
- **Tax**: Use tax on/off, new orders start on or off, rate, name, prices include tax or tax added on top

---

## What Has Been Built

### ✅ Complete Features

| Feature | Status | Notes |
|---------|--------|-------|
| Today dashboard | ✅ | Order cards, summary, alerts, status filter chips |
| Week calendar | ✅ | Orders by ship-by date, status filters, day detail |
| Month calendar | ✅ | Calendar grid with dots, day selection, status filters |
| Order list | ✅ | Tabbed (All, To Pack, Packed, Shipped), search |
| Order creation | ✅ | 3-step wizard with back navigation |
| Order detail | ✅ | Full info: dates, channel, items, materials, financial summary |
| Material adjustment | ✅ | Actual vs planned, waste tracking, profit recalculation |
| Pack & Ship | ✅ | Stock deduction, status updates |
| Delete orders | ✅ | Blocked when shipped, stock reversal for pending/packed |
| Cancel orders | ✅ | Any order not already cancelled, from the detail menu or a long press. Shipped ones are for parcels that came back or never went, and must be cancelled before they can be deleted. Reservations are released, packed or shipped stock goes back on the shelf (logged as "Restored from cancelled order"), and the order stays in the list as Cancelled, out of earnings. The Orders tab's All leaves cancelled orders out; they show under the Cancelled chip. A cancelled order can be restored (back to To pack, reserving its materials again) or deleted |
| Long-press menus | ✅ | Long press any product, material, order (list, Today, calendar), channel, social shortcut, order field or note for its actions: edit, delete, plus shortcuts such as Archive, Receive stock, Mark shipped, Cancel, Restore order, Turn off, Restore |
| Materials list | ✅ | Tab on Inventory, search, filter sheet, pip visualization |
| Material detail | ✅ | Stock overview, movements, receive, adjust, delete |
| Archive products & materials | ✅ | Long press → Archive. Archived items leave the lists (the Archived filter shows them), pickers, low-stock alerts and the buy list, but stay on past orders and earnings. Replaced the product's "Show in new orders" switch; hidden products were migrated to archived in schema v8. Delete still works when nothing blocks it: a material is blocked only by a BOM or an order, not by its stock history |
| Receive stock | ✅ | Packs + price, weighted avg cost preview, read-only pack size |
| Products list | ✅ | Search, combinable filter sheet (type + stock), margin display |
| Product/BOM editor | ✅ | Material stepper inputs, BOM management. Each line has **Uses** and **Makes** (schema v10), so 1 sheet can make 9 cards: cost per product is uses × cost ÷ makes. Uses and Makes accept fractions (schema v12) |
| Fractional quantities | ✅ | Stock, alert levels, pack sizes, BOM uses/makes, order lines, reservations, waste and history are REAL rounded to 3 decimals on write (`qty()`/`sameQty()` in `core/utils/quantity.dart`). Orders reserve the exact fraction a line needs; buildable is unrounded for the low/short checks and floored for display. Added in schema v12 |
| Channels & fees | ✅ | CRUD with edit dialog, delete with confirmation |
| Delete materials | ✅ | Blocked if in BOM or has stock movements |
| Delete products | ✅ | Blocked if in orders or has BOM items |
| Delete channels | ✅ | Blocked if orders reference them |
| Order fields | ✅ | Text, number, date and choice fields; drag to reorder; used fields archive instead of deleting. Replaced the built-in address (migrated in schema v4) |
| Notes | ✅ | Shop notebook with title and rich-text body (headings, checklists, lists, quote, code, links, highlight, alignment); pin to Today; search; delete with Undo. Added in schema v5 |
| Social shortcuts | ✅ | Configurable links to Facebook, TikTok, Shopee, Lazada and more (presets with brand colours, or a custom name and colour); tap to open in the browser or app; drag to reorder. Opens through the phone's own browser, so the app still makes no network calls. Added in schema v6 |
| Product photos | ✅ | One photo per product, from the camera or gallery, resized to 800px JPEG and stored in the database so backups carry it. Shown in the product list, product page, the order wizard's picker and items, and order details (tap to enlarge). Added in schema v7 |
| Reports | ✅ | Renamed from Money. Week/month/year/custom periods, filters, summary with discounts and tax, per-product, waste |
| Currency | ✅ | More → Currency. Presets (₱, $, €, £, ¥, Rp, RM, ฿, ₫, ₹…) or a custom symbol, with or without cents. Display only |
| Discounts | ✅ | Percent or fixed lines on any order, presets under More → Discounts. Fees and tax are on the amount after discount. Added in schema v9 |
| Units of measure | ✅ | More → Units of measure: the shop's own vocabulary (seeded with pc, sheet, m, cm, g, kg, ml, pack), add/rename/reorder, one flagged as the default for new items. Materials and products hold a `unit_id`, so a rename reaches past orders; delete is blocked while anything is counted in it and the last unit can't go. Every quantity on screen is written with it, verbatim — never pluralised. Added in schema v11 |
| Tax / VAT | ✅ | More → Tax: use tax on/off, whether new orders start with it on or off, rate, name, included in prices or added on top. Each order keeps its own rate and has its own switch. Added in schema v9 |
| Paid / unpaid | ✅ | Per order, default from the channel's "paid when placed". Unpaid tag and a payment filter (top-right Filter button) on Orders, Mark paid on the order page and long press, Waiting for payment list. Existing orders were migrated as paid in schema v9 |
| Waste breakdown | ✅ | Per-material: name, pcs wasted, cost |
| Settings | ✅ | SQLite export/import, navigation hub |
| Backup/Restore | ✅ | Raw SQLite file copy (Android SAF compatible) |
| In-app updates | ✅ | More → Check for updates installs the latest GitHub release APK. A workflow publishes a signed release on every push to `main` |
| Fake data for debugging | ✅ | Debug builds only. **More → Debug** seeds a whole sample shop, clears it, and shows a Database & coverage page. Seeding writes through the app's own use cases, so the shop has open orders holding stock, packed orders that spent it, waste, every order status and date position, tax on and off and both ways round, discounts capped at what the order is worth, a break-even sale and a loss-making one, fractional quantities, archived items still on past orders, a buy list to restock, notes, social links for every brand and a photo or two. Long-press **Seed fake data** to build a different shop, or to rebuild one by its seed number |

### ✅ Infrastructure

- **Database**: 17 tables, 9 DAOs, schema v9, Drift ORM with code generation
- **DI**: get_it with manual registration for all repos, use cases, BLoCs
- **Navigation**: go_router with ShellRoute bottom nav + push detail pages + auto-refresh on return
- **Theme**: Light and dark themes built from one token set (`CraftColors`), bundled fonts, three radii; follows the system setting
- **Reusable widgets**: AppCard/CardList/CardRow, SectionLabel, AppTag, StatusPill + OrderStatusPill, MoneyBreakdown(Bar), SummaryBoard, StatTile, EmptyState/ErrorState, BottomActionBar, ChoiceChipRow, StatusFilterChips, PipStrip v2, StepperInput, DateField, AppSearchField, InlineBanner, showAppSheet
- **Test suite**: use cases, BLoCs, widgets, utilities, and repository tests against in-memory SQLite
- **Fake shop factory**: `lib/core/factory/` — pure generators (no database, no get_it) for every entity, plus `coverage.dart`, the contract of which options the app offers. `SeedFakeShop` writes their output through the app's own use cases and refuses to commit unless the result covers every one of them
- **Screenshots**: `flutter test --run-skipped --tags screenshots --update-goldens` renders every screen (light + dark) against a seeded sample shop into `test/screenshots/goldens/`

---

## Key Design Decisions

### Profit is always recalculated on display
Stored `order.profit` can become stale after material adjustments. All displays (order detail, order cards, reports) recompute profit from its parts through `OrderMoney`, the single place the formula lives: what the customer paid − tax − materials − fees − shipping.

### Orders keep their own tax and discounts
The tax rate and whether it's included are copied onto each order, and discount presets are copied as lines, so changing Settings or a preset never rewrites past orders.

### Paid defaults come from the channel
Every order has a channel, so the channel's "paid when placed" is the default. A global setting would always be overridden.

### Unpaid orders still count as profit
A sale is a sale once packed. Reports counts unpaid orders and shows how much of the profit is still owed; the filter can leave them out.

### Earnings include packed + shipped orders
Not just shipped. Waste also scoped to packed/shipped only.

### Safe deletion with referential integrity
Deletes blocked when entities are referenced. No cascade data loss. Stock reversal on order deletion.

### Cancelling returns stock once
Cancelling and deleting share `ReturnOrderStock`. A cancelled order already gave its stock back, so deleting it later returns nothing; doing it again would double-count.

### Search fields use TextEditingController
Required for clear (X) button to work — clearing just the state variable doesn't reset the TextField.

### Auto-refresh after operations
Child pages pop with `true` after successful create/edit/delete. Parent pages await the result and reload.

### Order fields replace the built-in address
An address made sense for some shops and not others, so it became one of the shop's own fields. Values live in `order_field_values` (TEXT, one row per filled field) and are loaded per order, not on the `Order` entity, so lists and earnings don't pay for them. A field orders use can't be deleted or change type; it is archived and keeps showing on those orders.

### One calendar page
Week and month are one screen with a toggle and prev/next navigation, so there is no back-stack juggling between them.

### Catalogue pages keep the bottom nav
The Inventory bottom-nav tab (`InventoryPage`) holds Products, since products are what orders are made of, and Materials beside it, so stock is one tap away. Each tab label counts what that tab shows under its search and filter. The page carries the Buy list shortcut and a Filter button for whichever tab is showing. The Buy list lives inside the ShellRoute too and highlights the Inventory tab. Editors and receive pages are full-screen with their own bottom action bar.

### Overcommitted stock is shown, not hidden
When promised exceeds on hand, pips only draw pieces that exist and the shortfall is stated ("8 short").

### Seeding the fake shop goes through the app's own use cases
`SeedFakeShop` calls `CreateOrder`, `PackOrder`, `ShipOrder`, `CancelOrder`, `RestoreOrder`, `AdjustMaterialsUsed` and the repositories rather than inserting rows, so a successful seed is evidence the app's rules work and a rule that trips over fractional pieces or a cancelled shipment fails there instead of appearing later as a screen that looks subtly wrong. The only hand-written rows are the timestamps the app can't be told to backdate.

### A seeded shop is a coverage contract, not a fixture
`coverage.dart` lists every option the app offers, read from the enums themselves, and the seed fails and rolls back if any of them is missing from what it wrote. The states worth looking at are arranged by construction: `StockRole` sets each shelf to be empty, exactly at its reorder level, over-promised, or critical-but-absent-from-the-buy-list, and `OrderLifecycle` plus the scenario table in `order_factory.dart` put every status in every date position. The same seed always builds the same shop, so two builds can be compared piece for piece and a number that moved is a finding rather than noise; a different seed is one long-press away when variety is wanted.

### Debug tools cannot reach a shop owner
The Debug group on More is behind `kDebugMode`, not a setting, and it wipes the database, so a release build has no way to show it or to route to its page.

---

## Technical Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.x |
| State Management | flutter_bloc (BLoC pattern) |
| Local Database | SQLite via Drift ORM |
| Dependency Injection | get_it (manual registration) |
| Navigation | go_router |
| Date/Time | intl |
| Charts | fl_chart |
| File Picker | file_picker (backup/restore) |
| Testing | mocktail + bloc_test |

---

## Design System

The app uses a custom design system in `lib/core/theme/`:
- **Colors**: `CraftColors` ThemeExtension (light + dark). Fixed meanings: green = profit/free/primary, red = cost/low/destructive, amber = fees/to pack, indigo = money totals/shipped. Read via `context.colors`.
- **Typography**: Bricolage Grotesque (numbers, titles), IBM Plex Sans (body), IBM Plex Mono (labels, 10px minimum). Bundled in `assets/fonts/`.
- **Shape**: radii 4 (tags), 10 (controls), 16 (cards), pills for chips and status.
- **Signature components**: Pip strip (free, hatched promised, empty up to the reorder tick, outlined incoming/removed) and the money breakdown bar (materials / fees / shipping / profit).

---

*Last updated: 2026-10-05*
