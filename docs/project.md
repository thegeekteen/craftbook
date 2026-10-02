# Craftbook - Business Context & Current State

## What is Craftbook?

Craftbook is an offline-first Android application designed for small craft businesses to manage orders, track materials (BOM - Bill of Materials), and calculate real profit. The app treats every order as a material consumer - when you save an order, it reserves pieces; when you pack, it deducts them.

### Core Value Proposition
- **Offline-first**: No accounts, no sync, no network calls. All data lives on-device
- **BOM-aware orders**: Orders are created with products, but the app expands them into materials behind the scenes
- **Real profit tracking**: Profit = Sales − Materials (actual, including waste) − Channel fees − Shipping
- **Stock as pips**: Visual representation of stock levels showing free vs. promised pieces

### Target Platform
- Android only (Flutter)
- Minimum SDK: API 21 (Android 5.0)
- Target SDK: API 34 (Android 14)

---

## Planned Features (from UI Flow)

The app is designed around 6 main user flows:

### Flow 1: Day View
- **Today screen**: Shows orders due today with alerts for low stock
- **Calendar views**: Week and month views showing order timelines
- **Alert banners**: Visual warnings for materials below alert level
- **Order status tracking**: See which orders are ready, packed, or short on materials

### Flow 2: Order Creation
- **Multi-step wizard**: Customer details → Add products → Review & save
- **Product picker**: Shows buildable quantity from current stock
- **Channel selection**: Shopee, TikTok, Lazada, Facebook, Walk-in with fee rates
- **Auto-calculation**: Materials cost, channel fees, and profit calculated automatically

### Flow 3: Pack & Ship
- **Order details**: View items and materials needed
- **Material adjustment**: Record actual materials used vs. planned (waste tracking)
- **Pack confirmation**: Shows before/after stock levels
- **Ship marking**: Updates order status and closes the profit calculation

### Flow 4: Stock Management
- **Materials list**: Shows all materials with pip visualization
- **Stock receive**: Record new stock purchases with weighted average cost
- **Material detail**: Shows movements, what products use it, buildable quantities
- **Buy list**: Auto-generated list of what to reorder based on alert levels

### Flow 5: Products & BOM
- **Product catalog**: List all products with margin and buildable quantity
- **BOM editor**: Define what materials go into each product
- **Channel management**: Configure fee rates for each sales channel

### Flow 6: Earnings
- **Profit overview**: Total earnings by date range
- **Per-product breakdown**: Which products are most profitable
- **Waste analysis**: How much money is lost to material waste

### Settings
- **Backup/restore**: Export and import all data as JSON
- **App preferences**: Currency, date format, etc.

---

## What Has Been Built

### ✅ Completed Infrastructure

#### Core Module (`lib/core/`)
- **Constants**: App-wide constants and route names
- **Theme**: Complete design system with colors, text styles, and theme configuration
- **Widgets**: Reusable UI components:
  - `PipStrip`: Visual stock level indicator (signature component)
  - `StepperInput`: +/- quantity input
  - `StatusPill`: Status badges (READY, SHORT, PACKED, etc.)
  - `CurrencyText`: PHP currency formatting
  - `ConfirmDialog`: Reusable confirmation dialog
- **Utils**: 
  - Currency formatter (PHP)
  - Date utilities
  - Dart extensions
- **Error handling**: Failure types and custom exceptions
- **Dependency injection**: get_it + injectable setup

#### Database Layer (`lib/database/`)
- **9 Table definitions**:
  - `Orders`: Customer info, dates, status, financials
  - `OrderItems`: Products within an order
  - `OrderMaterials`: Materials used in an order (planned vs. actual)
  - `Materials`: Inventory with stock levels
  - `Products`: Sellable items
  - `BomItems`: Bill of materials linking products to materials
  - `Channels`: Sales channels with fee rates
  - `StockMovements`: Audit trail for all stock changes
  - `Settings`: App configuration
- **5 DAOs** (Data Access Objects):
  - `OrderDao`: CRUD operations for orders
  - `MaterialDao`: Stock management operations
  - `ProductDao`: Product and BOM operations
  - `ChannelDao`: Channel management
  - `EarningsDao`: Financial calculations and reporting
- **Migrations**: Schema versioning system ready

#### Domain Entities (`lib/features/*/domain/entities/`)
- `Order`: Complete order entity with status tracking
- `OrderItem`: Product within an order
- `Material`: Inventory item with stock calculations
- `Product`: Sellable product
- `Channel`: Sales channel with fee calculation

#### App Shell
- Main app entry point with DI initialization
- GoRouter navigation setup with 5 main routes
- Basic page stubs for all features

### ⚠️ Partially Implemented

#### Feature Pages
All feature folders exist with basic page stubs:
- `TodayPage`: Placeholder
- `OrdersListPage`: Placeholder
- `MaterialsListPage`: Placeholder
- `EarningsPage`: Placeholder
- `SettingsPage`: Placeholder

**Status**: Pages exist but have no UI implementation yet

### ❌ Not Yet Implemented

#### Business Logic (Use Cases)
- Order creation workflow
- Material reservation system
- Stock deduction on pack
- Profit calculation
- BOM expansion
- Buildable quantity calculation
- Buy list generation
- Earnings aggregation

#### UI Implementation
- Today screen with order cards and alerts
- Calendar views (week/month)
- Order creation wizard (3 steps)
- Order detail with material adjustment
- Pack confirmation dialog
- Materials list with pip visualization
- Material detail with movements
- Receive stock form
- Product list with margin display
- BOM editor
- Channel management
- Earnings dashboard with charts
- Settings page

#### Repository Layer
- Repository interfaces (defined in domain layer)
- Repository implementations (connecting DAOs to use cases)

#### BLoC State Management
- Events and states for each feature
- BLoC classes with business logic
- Integration with use cases

#### Testing
- Unit tests for use cases
- Widget tests for key components
- Integration tests for critical flows

---

## Current State Summary

**Completion Estimate: ~25%**

### What Works
- ✅ Project builds successfully
- ✅ Database schema is complete
- ✅ Core UI components are ready
- ✅ Navigation structure is set up
- ✅ Dependency injection is configured

### What Needs Work
- ❌ All feature UI screens (currently just placeholders)
- ❌ Business logic (use cases)
- ❌ State management (BLoC implementation)
- ❌ Repository layer
- ❌ Testing

### Next Steps (Priority Order)
1. **Today feature**: Implement the day view screen (most used)
2. **Orders feature**: Order creation wizard and list
3. **Stock feature**: Materials list and receive stock
4. **Products feature**: Product list and BOM editor
5. **Earnings feature**: Profit dashboard
6. **Settings**: Backup/restore functionality

---

## Technical Stack

| Layer | Technology | Status |
|-------|-----------|--------|
| UI Framework | Flutter 3.x | ✅ Installed |
| State Management | flutter_bloc | ✅ Added, not implemented |
| Local Database | SQLite via Drift ORM | ✅ Complete |
| Dependency Injection | get_it + injectable | ✅ Configured |
| Navigation | go_router | ✅ Basic setup |
| Date/Time | intl | ✅ Added |
| Charts | fl_chart | ✅ Added, not used yet |
| Testing | mocktail + bloc_test | ✅ Added, not written |

---

## Key Business Rules (To Be Implemented)

1. **Stock Reservation**: When an order is saved, materials are reserved (promised) but not deducted
2. **Stock Deduction**: When an order is packed, materials are actually deducted from stock
3. **Waste Tracking**: Orders store both planned and actual material quantities
4. **Weighted Average Cost**: Stock receipts recalculate unit cost as weighted average
5. **Profit Calculation**: `profit = sales - actual_material_cost - channel_fees - shipping`
6. **Buildable Quantity**: `min(material.quantity_on_hand / bom_item.quantity_required)` for all BOM items

---

## Design System

The app uses a custom design system defined in `lib/core/theme/`:
- **Colors**: Earthy, muted palette with status colors (success, alert, warning)
- **Typography**: Space Grotesk (display), IBM Plex Sans (body), IBM Plex Mono (labels)
- **Components**: Pip strips, status pills, stepper inputs, currency displays

The signature visual element is the **pip strip** - a row of small rectangles representing stock levels, where filled = free, hatched = promised to orders.

---

*Last updated: 2026-10-03*
