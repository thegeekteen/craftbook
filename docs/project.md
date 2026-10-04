# Craftbook - Business Context & Current State

## What is Craftbook?

Craftbook is an offline-first Android application designed for small craft businesses to manage orders, track materials (BOM - Bill of Materials), and calculate real profit. The app treats every order as a material consumer — when you save an order, it reserves pieces; when you pack, it deducts them.

### Core Value Proposition
- **Offline-first**: No accounts, no sync. All data lives on-device. The only network call is the user-triggered update check against GitHub releases
- **BOM-aware orders**: Orders are created with products, but the app expands them into materials behind the scenes
- **Real profit tracking**: Profit = Sales − Materials (actual, including waste) − Channel fees − Shipping
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
- **Auto-calculation**: Materials cost, channel fees, and profit calculated automatically

### Flow 3: Pack & Ship
- **Order details**: Full view with dates, channel, items (with names), materials (with names), financial summary
- **Status stepper**: Visual progress with icons (🧾 Placed → 📦 Packed → 🚚 Shipped)
- **Material adjustment**: Record actual materials used vs. planned (waste tracking)
- **Profit recalculation**: Profit recalculated from components after material adjustment
- **Pack/Ship actions**: Updates status, deducts stock, recalculates profit

### Flow 4: Stock Management
- **Materials list**: Opened from More. Tabbed (All, Low, Promised, Archived) with search by material name
- **Material detail**: Stock overview with pip strip, receive/adjust actions, movements, products using it
- **Receive stock**: Packs received + price per pack with live weighted average cost preview. Pack size shown read-only
- **Delete material**: Blocked if used in a BOM or an order; its stock history goes with it. Archive it otherwise

### Flow 5: Products & BOM
- **Products list**: With search by product name, shows margin and buildable quantity
- **BOM editor**: Define what materials go into each product with stepper inputs
- **Channel management**: Configure fee rates for each sales channel
- **Delete product**: Blocked if referenced by orders or has BOM items

### Flow 6: Earnings (Money)
- **Period selector**: Week / Month / Year tabs with prev/next navigation and date range labels
- **Summary card**: Net profit, sales, material cost, channel fees, shipping
- **Per-product breakdown**: Product name, quantity sold, sales, profit (allocated by sales proportion)
- **Waste section**: Per-material breakdown showing name, pcs wasted, cost
- **Scope**: Includes packed + shipped orders. Profit always recalculated from components

### Settings
- **Export backup**: Raw SQLite file export via file picker (Android SAF compatible)
- **Import backup**: Pick a SQLite file, copy over current DB, prompt restart (with confirmation dialog)
- **Navigation hub**: Links to Products, Channels, Order fields, Buy List, Notes, Social shortcuts

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
| Cancel orders | ✅ | Pending or packed orders, from the detail menu or a long press. Reservations are released, packed stock goes back on the shelf (logged as "Restored from cancelled order"), and the order stays in the list as Cancelled, out of earnings. The Orders tab's All leaves cancelled orders out; they show under the Cancelled chip. A cancelled order can be restored (back to To pack, reserving its materials again) or deleted |
| Long-press menus | ✅ | Long press any product, material, order (list, Today, calendar), channel, social shortcut, order field or note for its actions: edit, delete, plus shortcuts such as Archive, Receive stock, Mark shipped, Cancel, Restore order, Turn off, Restore |
| Materials list | ✅ | Tabbed, search, pip visualization |
| Material detail | ✅ | Stock overview, movements, receive, adjust, delete |
| Archive products & materials | ✅ | Long press → Archive. Archived items leave the lists (an Archived chip shows them), pickers, low-stock alerts and the buy list, but stay on past orders and earnings. Replaced the product's "Show in new orders" switch; hidden products were migrated to archived in schema v8. Delete still works when nothing blocks it: a material is blocked only by a BOM or an order, not by its stock history |
| Receive stock | ✅ | Packs + price, weighted avg cost preview, read-only pack size |
| Products list | ✅ | Search, margin display |
| Product/BOM editor | ✅ | Material stepper inputs, BOM management |
| Channels & fees | ✅ | CRUD with edit dialog, delete with confirmation |
| Delete materials | ✅ | Blocked if in BOM or has stock movements |
| Delete products | ✅ | Blocked if in orders or has BOM items |
| Delete channels | ✅ | Blocked if orders reference them |
| Order fields | ✅ | Text, number, date and choice fields; drag to reorder; used fields archive instead of deleting. Replaced the built-in address (migrated in schema v4) |
| Notes | ✅ | Shop notebook with title and rich-text body (headings, checklists, lists, quote, code, links, highlight, alignment); pin to Today; search; delete with Undo. Added in schema v5 |
| Social shortcuts | ✅ | Configurable links to Facebook, TikTok, Shopee, Lazada and more (presets with brand colours, or a custom name and colour); tap to open in the browser or app; drag to reorder. Opens through the phone's own browser, so the app still makes no network calls. Added in schema v6 |
| Product photos | ✅ | One photo per product, from the camera or gallery, resized to 800px JPEG and stored in the database so backups carry it. Shown in the product list, product page, the order wizard's picker and items, and order details (tap to enlarge). Added in schema v7 |
| Earnings report | ✅ | Period navigation, summary, per-product, waste |
| Waste breakdown | ✅ | Per-material: name, pcs wasted, cost |
| Settings | ✅ | SQLite export/import, navigation hub |
| Backup/Restore | ✅ | Raw SQLite file copy (Android SAF compatible) |
| In-app updates | ✅ | More → Check for updates installs the latest GitHub release APK. A workflow publishes a signed release on every push to `main` |

### ✅ Infrastructure

- **Database**: 14 tables, 7 DAOs, Drift ORM with code generation
- **DI**: get_it with manual registration for all repos, use cases, BLoCs
- **Navigation**: go_router with ShellRoute bottom nav + push detail pages + auto-refresh on return
- **Theme**: Light and dark themes built from one token set (`CraftColors`), bundled fonts, three radii; follows the system setting
- **Reusable widgets**: AppCard/CardList/CardRow, SectionLabel, AppTag, StatusPill + OrderStatusPill, MoneyBreakdown(Bar), SummaryBoard, StatTile, EmptyState/ErrorState, BottomActionBar, ChoiceChipRow, StatusFilterChips, PipStrip v2, StepperInput, DateField, AppSearchField, InlineBanner, showAppSheet
- **Test suite**: use cases, BLoCs, widgets, utilities, and repository tests against in-memory SQLite
- **Screenshots**: `flutter test --run-skipped --tags screenshots --update-goldens` renders every screen (light + dark) against a seeded sample shop into `test/screenshots/goldens/`

---

## Key Design Decisions

### Profit is always recalculated on display
Stored `order.profit` can become stale after material adjustments. All displays (order detail, order cards, earnings report) compute `profit = sales - materials - fees - shipping` at render time.

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
Products has its own tab, since products are what orders are made of; it also carries the Buy list shortcut. Materials and the Buy list open from More and live inside the ShellRoute too. Editors and receive pages are full-screen with their own bottom action bar.

### Overcommitted stock is shown, not hidden
When promised exceeds on hand, pips only draw pieces that exist and the shortfall is stated ("8 short").

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

*Last updated: 2026-10-04*
