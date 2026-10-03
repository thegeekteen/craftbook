# Craftbook - Business Context & Current State

## What is Craftbook?

Craftbook is an offline-first Android application designed for small craft businesses to manage orders, track materials (BOM - Bill of Materials), and calculate real profit. The app treats every order as a material consumer — when you save an order, it reserves pieces; when you pack, it deducts them.

### Core Value Proposition
- **Offline-first**: No accounts, no sync, no network calls. All data lives on-device
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
- **Status filter chips**: Filter by Pending, Packed, Shipped, Cancelled (persistent while mounted)
- **Calendar views**: Week and month views with period navigation, also with status filters
- **Alert banners**: Visual warnings for materials below alert level
- **Order cards**: Show customer name, status, ship-by date, channel, and recalculated profit
- **Search**: Search orders by customer name or order ID

### Flow 2: Order Creation
- **3-step wizard**: Customer details → Add products → Review & save
- **Back navigation**: Users can go back to previous steps without losing data
- **Product picker**: Shows buildable quantity from current stock
- **Channel selection**: Shopee, TikTok, Lazada, Facebook, Walk-in with fee rates
- **Auto-calculation**: Materials cost, channel fees, and profit calculated automatically

### Flow 3: Pack & Ship
- **Order details**: Full view with dates, channel, items (with names), materials (with names), financial summary
- **Status stepper**: Visual progress with icons (🧾 Placed → 📦 Packed → 🚚 Shipped)
- **Material adjustment**: Record actual materials used vs. planned (waste tracking)
- **Profit recalculation**: Profit recalculated from components after material adjustment
- **Pack/Ship actions**: Updates status, deducts stock, recalculates profit

### Flow 4: Stock Management
- **Materials list**: Tabbed (All, Low, Promised) with search by material name
- **Material detail**: Stock overview with pip strip, receive/adjust actions, movements, products using it
- **Receive stock**: Packs received + price per pack with live weighted average cost preview. Pack size shown read-only
- **Delete material**: Blocked if used in BOM or has stock movement history

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
- **Navigation hub**: Links to Products, Channels, Buy List

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
| Materials list | ✅ | Tabbed, search, pip visualization |
| Material detail | ✅ | Stock overview, movements, receive, adjust, delete |
| Receive stock | ✅ | Packs + price, weighted avg cost preview, read-only pack size |
| Products list | ✅ | Search, margin display |
| Product/BOM editor | ✅ | Material stepper inputs, BOM management |
| Channels & fees | ✅ | CRUD with edit dialog, delete with confirmation |
| Delete materials | ✅ | Blocked if in BOM or has stock movements |
| Delete products | ✅ | Blocked if in orders or has BOM items |
| Delete channels | ✅ | Blocked if orders reference them |
| Earnings report | ✅ | Period navigation, summary, per-product, waste |
| Waste breakdown | ✅ | Per-material: name, pcs wasted, cost |
| Settings | ✅ | SQLite export/import, navigation hub |
| Backup/Restore | ✅ | Raw SQLite file copy (Android SAF compatible) |

### ✅ Infrastructure

- **Database**: 9 tables, 5 DAOs, Drift ORM with code generation
- **DI**: get_it with manual registration for all repos, use cases, BLoCs
- **Navigation**: go_router with ShellRoute bottom nav + push detail pages + auto-refresh on return
- **Theme**: Complete design system (colors, typography, text theme, dialog/chip/FAB themes)
- **Reusable widgets**: PipStrip, StepperInput (with text entry + focus management), StatusPill, CurrencyText, ConfirmDialog, SectionCard, StatusFilterChips
- **Test suite**: 71 tests — entities, use cases, widgets, utilities

---

## Key Design Decisions

### Profit is always recalculated on display
Stored `order.profit` can become stale after material adjustments. All displays (order detail, order cards, earnings report) compute `profit = sales - materials - fees - shipping` at render time.

### Earnings include packed + shipped orders
Not just shipped. Waste also scoped to packed/shipped only.

### Safe deletion with referential integrity
Deletes blocked when entities are referenced. No cascade data loss. Stock reversal on order deletion.

### Search fields use TextEditingController
Required for clear (X) button to work — clearing just the state variable doesn't reset the TextField.

### Auto-refresh after operations
Child pages pop with `true` after successful create/edit/delete. Parent pages await the result and reload.

### Navigation uses pushReplacement for peer views
Calendar week ↔ month use `pushReplacement` to avoid infinite back-stack loops.

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
- **Colors**: Earthy, muted palette with status colors (success green, alert red, warning amber, coin purple)
- **Typography**: Space Grotesk (display), IBM Plex Sans (body), IBM Plex Mono (labels)
- **Signature component**: Pip strip — small rectangles representing stock levels (filled = free, hatched = promised)

---

*Last updated: 2026-10-03*
