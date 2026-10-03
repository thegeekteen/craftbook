# Craftbook — Code Architecture & Development Guide

## Project Overview

**Craftbook** is an offline-first Android application for small craft businesses to track orders, manage materials (BOM), and calculate real profit. It treats every order as a material consumer — when you save an order, it reserves pieces; when you pack, it deducts them.

### Core Value Proposition
- **Offline-first**: No accounts, no sync, no network calls. All data lives on-device.
- **BOM-aware orders**: Orders are created with products, but the app expands them into materials behind the scenes.
- **Real profit tracking**: Profit = Sales − Materials (actual, including waste) − Channel fees − Shipping.
- **Stock as pips**: Visual representation of stock levels showing free vs. promised pieces.

### Target Platform
- **Android only** (Flutter)
- **Minimum SDK**: API 21 (Android 5.0) — set by `flutter.minSdkVersion`
- **Target SDK**: API 36 (Android 16) — set by `flutter.targetSdkVersion`
- **Compile SDK**: API 36 — set by `flutter.compileSdkVersion`

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| UI Framework | Flutter 3.x | Cross-platform UI (Android target) |
| State Management | flutter_bloc | Predictable state management with BLoC pattern |
| Local Database | SQLite via Drift ORM | Type-safe database access with code generation |
| Dependency Injection | get_it (manual registration) | Service locator in `lib/core/di/injection.dart` |
| Navigation | go_router | Declarative routing with bottom nav shell |
| Date/Time | intl | Date formatting and localization |
| Charts | fl_chart | Simple charts for earnings visualization |
| File Picker | file_picker | SQLite backup export/import |
| Testing | mocktail + bloc_test | Unit and widget testing |

---

## Architecture Overview

This project follows **Clean Architecture** with a **feature-first** directory structure. Each feature contains its own presentation, domain, and data layers.

```
lib/
├── core/           # Theme, widgets, utils, DI, error types, constants
├── database/       # Drift tables, DAOs, migrations
├── features/       # Feature modules (today, orders, stock, products, earnings, settings)
│   └── <feature>/
│       ├── presentation/  (pages, bloc, widgets)
│       ├── domain/        (entities, usecases, repositories)
│       └── data/          (repository impls)
└── app.dart        # MaterialApp, routing, theme
```

### Layer Responsibilities

| Layer | Responsibility | Dependencies |
|-------|---------------|--------------|
| **Presentation** | UI rendering, user interaction, state management | Domain (Use Cases, Entities) |
| **Domain** | Business logic, use cases, entity definitions | None (pure Dart) |
| **Data** | Data persistence, repository implementations | Domain (Entities, Repository interfaces) |

### Feature Modules

| Feature | Route(s) | Key Pages |
|---------|----------|-----------|
| **Today** | `/` | Dashboard, week calendar, month calendar |
| **Orders** | `/orders`, `/orders/new`, `/orders/:id` | List (tabbed), creation wizard, detail view |
| **Stock** | `/materials`, `/materials/:id` | List (tabbed), detail, receive stock, buy list |
| **Products** | `/products`, `/products/:id/edit`, `/channels` | List, BOM editor, channels & fees |
| **Earnings** | `/earnings` | Summary with period nav, per-product breakdown, waste |
| **Settings** | `/settings` | Backup/restore, navigation hub |

---

## Key Business Rules

1. **Stock Reservation**: When an order is saved, materials are **reserved** (promised) but not deducted. The `quantity_promised` field on Material tracks this.

2. **Stock Deduction**: When an order is **packed**, materials are actually deducted from `quantity_on_hand`. The `quantity_promised` is also reduced.

3. **Waste Tracking**: The `order_materials` table stores both planned and actual quantities. The difference is waste, which affects profit calculation.

4. **Weighted Average Cost**: When receiving stock, the unit cost is recalculated:
   ```
   new_unit_cost = (old_qty × old_cost + new_qty × new_price) / (old_qty + new_qty)
   ```

5. **Profit Calculation**: Always recalculated from components on display:
   ```
   profit = sales - actual_material_cost - channel_fees - shipping
   ```
   **Do NOT trust stored `order.profit`** — it can become stale after material adjustments. Always compute `sales - materials - fees - shipping` at display time.

6. **Buildable Quantity**: For a product, the maximum buildable quantity is:
   ```
   min(material.quantity_on_hand / bom_item.quantity_required) for all BOM items
   ```

7. **Safe Deletion**: Orders blocked when shipped. Materials blocked when used in BOM or have stock movements. Products blocked when in orders or have BOM items. Channels blocked when orders reference them.

8. **Earnings Scope**: Earnings include both **packed and shipped** orders. Waste also only counts from packed/shipped orders.

---

## State Management Pattern

Each feature uses the **BLoC pattern**:

```dart
// Event: User actions
abstract class OrdersListEvent extends Equatable {}
class LoadOrders extends OrdersListEvent {}

// State: UI state
class OrdersListState extends Equatable {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
}

// BLoC: Business logic
class OrdersListBloc extends Bloc<OrdersListEvent, OrdersListState> {
  final GetOrdersUseCase getOrders;
  OrdersListBloc({required this.getOrders}) : super(OrdersListInitial()) {
    on<LoadOrders>(_onLoadOrders);
  }
}
```

---

## Dependency Injection

Using `get_it` with manual registration in `lib/core/di/injection.dart`:

```dart
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);

  // DAOs
  getIt.registerSingleton(OrderDao(db));
  // ...

  // Repositories
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt<OrderDao>()),
  );

  // Use Cases
  getIt.registerFactory(() => GetOrders(getIt()));

  // BLoCs
  getIt.registerFactory(() => OrdersListBloc(getOrders: getIt()));
}
```

---

## Navigation

Using `go_router` with a `ShellRoute` for the 5 bottom nav tabs (Today, Orders, Stock, Money, More) and push routes for detail pages.

- Tab switches use `context.go()` (replace)
- Detail pages use `context.push()` (push)
- Child pages pop with `context.pop(true)` after successful operations
- Parent pages `await` the push result and reload their BLoC

**Auto-refresh pattern**: After any create/edit/delete, child pages pop with `true`. Parent pages check the result and dispatch a reload event.

---

## Error Handling

All use cases return `Either<Failure, Success>` using the `dartz` package:

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {}
class ValidationFailure extends Failure {}
class NotFoundFailure extends Failure {}
```

---

## Testing Strategy

**MANDATORY RULE: When working on any feature, always write test cases.** Every use case must have unit tests, every BLoC must have `bloc_test` coverage, and every new widget must have a widget test.

| Level | Tool | Coverage Target |
|-------|------|----------------|
| Unit Tests | `test`, `mocktail` | Use cases, BLoCs, repositories |
| Widget Tests | `flutter_test` | Key widgets (PipStrip, StepperInput, etc.) |

### Testing Requirements
1. **Every use case** — happy path + each validation failure
2. **Every BLoC** — each event handler, verify correct state emissions
3. **Every new widget** — renders correctly with expected data
4. **Business logic** — profit calculation, stock reservation/deduction, BOM expansion, weighted average cost

### dartz Either in Tests
When mocking methods returning `Either<Failure, T>`, always add explicit type parameters:
```dart
// CORRECT
when(mockRepo.getOrders()).thenAnswer((_) async => Right<Failure, List<Order>>([testOrder]));
// WRONG — infers Right<dynamic, List<Order>>
when(mockRepo.getOrders()).thenAnswer((_) async => Right([testOrder]));
```

---

## Coding Standards

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Methods**: `camelCase`
- **Constants**: `camelCase` (not SCREAMING_CAPS)
- **Private members**: `_prefixWithUnderscore`

### Comments
- Document **why**, not **what**
- Use `///` for public API documentation

### Error Handling
- Never swallow errors silently
- Always show user-friendly error messages

---

## Database Migrations

Every schema change must:
1. Increment `schemaVersion` in `app_database.dart`
2. Add a migration step in `migrations.dart`
3. Handle data preservation during migration
4. Run `dart run build_runner build` to regenerate code

---

## Backup & Export

Raw SQLite file copy via `file_picker` (`lib/core/services/backup_service.dart`):
- **Export**: Reads `craftbook.sqlite` as bytes, passes to `FilePicker.saveFile()` (Android SAF compatible)
- **Import**: Picks a file, copies over current DB (or writes bytes), prompts restart

---

## Development Workflow

1. **Branch naming**: `feature/feature-name`, `fix/bug-name`, `refactor/description`
2. **Commit messages**: Conventional commits (`feat:`, `fix:`, `docs:`, etc.)
3. **After adding plugins**: Run `flutter clean && flutter pub get` then full rebuild (hot restart won't register native code)

### Getting Started

```bash
flutter pub get
dart run build_runner build
flutter run
flutter test
```

---

## Documentation

- **This file (AGENTS.md)**: Code architecture, patterns, and technical conventions.
- **[docs/project.md](docs/project.md)**: Business context, feature status, and current state.
- **[docs/craftbook-ui-flow.html](docs/craftbook-ui-flow.html)**: Interactive UI flow mockup.

---

*This document is the single source of truth for code architecture. All implementation decisions should align with these patterns.*
