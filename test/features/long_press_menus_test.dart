import 'package:craftbook/core/constants/route_names.dart';
import 'package:craftbook/core/di/injection.dart';
import 'package:craftbook/core/widgets/choice_chip_row.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/notes/domain/entities/note.dart';
import 'package:craftbook/features/notes/domain/repositories/note_repository.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/domain/repositories/order_field_repository.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/usecases/create_order.dart';
import 'package:craftbook/features/products/domain/entities/channel.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/social_links/domain/entities/social_link.dart';
import 'package:craftbook/features/social_links/domain/repositories/social_link_repository.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

/// The long-press menus on every list, end to end. Orders have their own
/// file (order_menu_and_cancel_test.dart).
void main() {
  /// Yarn goes into the Tulip, which Ana ordered through Walk-in, so Yarn,
  /// Tulip and Walk-in are all protected. Glue, Strap, Etsy and the Address
  /// field are used by nothing. Gift box is resell.
  Future<void> seed() async {
    final materials = getIt<MaterialRepository>();
    final products = getIt<ProductRepository>();
    final channels = getIt<ChannelRepository>();
    final yarn = ok(await materials.createMaterial(
        name: 'Yarn',
        packSize: 10,
        packPrice: 100,
        unitCost: 10,
        quantityOnHand: 20,
        alertLevel: 0));
    ok(await materials.createMaterial(
        name: 'Glue',
        packSize: 1,
        packPrice: 30,
        unitCost: 30,
        quantityOnHand: 0,
        alertLevel: 0));
    final tulip =
        ok(await products.createProduct(name: 'Tulip', sellPrice: 300));
    ok(await products.saveBomItems(
        tulip, [BomItemInput(materialId: yarn, quantityRequired: 1)]));
    ok(await products.createProduct(name: 'Strap', sellPrice: 80));
    ok(await products.createProduct(
        name: 'Gift box', sellPrice: 60, isStandalone: true));
    Future<int> channel(String name) async => ok(await channels.createChannel(
        name: name,
        commissionRate: 0,
        transactionFeeRate: 0,
        flatFee: 0,
        shippingPaidByUs: 0));
    final walkIn = await channel('Walk-in');
    await channel('Etsy');
    final now = DateTime.now();
    ok(await getIt<CreateOrder>()(
      customerName: 'Ana',
      orderDate: now,
      shipByDate: now.add(const Duration(days: 3)),
      channelId: walkIn,
      totalSales: 300,
      channelFees: 0,
      shippingCost: 0,
      items: [
        OrderItemInput(
            productId: tulip,
            productName: 'Tulip',
            quantity: 1,
            unitPrice: 300),
      ],
    ));
    ok(await getIt<SocialLinkRepository>().createLink(const SocialLink(
        platform: 'facebook',
        label: 'Facebook',
        url: 'https://facebook.com/lorna.crafts')));
    ok(await getIt<OrderFieldRepository>().createField(
        const OrderField(name: 'Address', type: OrderFieldType.text)));
    ok(await getIt<NoteRepository>()
        .createNote(const Note(title: 'Supplier numbers', isPinned: true)));
  }

  Future<void> longPress(WidgetTester tester, String text) async {
    final target = find.text(text).first;
    await tester.ensureVisible(target);
    await tester.longPress(target);
    await settle(tester);
  }

  Future<void> confirm(WidgetTester tester, String button) async {
    await tester.tap(find.widgetWithText(FilledButton, button));
    await settle(tester);
  }

  Future<List<Product>> products(WidgetTester tester) async {
    final r = await db<Result<List<Product>>>(
        tester, () => getIt<ProductRepository>().getAllProducts());
    final List<Product> all = ok(r);
    return all;
  }

  Future<List<Material>> materials(WidgetTester tester) async {
    final r = await db<Result<List<Material>>>(
        tester, () => getIt<MaterialRepository>().getAllMaterials());
    final List<Material> all = ok(r);
    return all;
  }

  Future<List<Channel>> channels(WidgetTester tester) async {
    final r = await db<Result<List<Channel>>>(
        tester, () => getIt<ChannelRepository>().getAllChannels());
    final List<Channel> all = ok(r);
    return all;
  }

  group('Products', () {
    testWidgets('menu fits the product: Receive only for resell',
        (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.products);
      await longPress(tester, 'Tulip');
      expect(find.text('Edit product'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Receive stock'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await settle(tester);

      await longPress(tester, 'Gift box');
      expect(find.text('Receive stock'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('deletes an unused product', (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.products);
      await longPress(tester, 'Strap');
      await tester.tap(find.text('Delete product'));
      await settle(tester);
      await confirm(tester, 'Delete');

      expect(find.text('Product deleted'), findsOneWidget);
      expect(find.text('Strap'), findsNothing);
      expect((await products(tester)).map((p) => p.name),
          isNot(contains('Strap')));
      await closeApp(tester);
    });

    testWidgets('a protected product says why and stays', (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.products);
      await longPress(tester, 'Tulip');
      await tester.tap(find.text('Delete product'));
      await settle(tester);
      await confirm(tester, 'Delete');

      expect(find.textContaining('Cannot delete product'), findsOneWidget);
      expect(find.text('Tulip'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('archives, shows under Archived, and unarchives',
        (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.products);
      await longPress(tester, 'Tulip');
      await tester.tap(find.text('Archive'));
      await settle(tester);

      expect(find.text('Tulip archived'), findsOneWidget);
      var tulip = (await products(tester)).firstWhere((p) => p.name == 'Tulip');
      expect(tulip.isArchived, isTrue);
      expect(find.text('Tulip'), findsNothing);

      final chip = find.widgetWithText(AppChip, 'Archived');
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await settle(tester);
      await longPress(tester, 'Tulip');
      await tester.tap(find.text('Unarchive'));
      await settle(tester);
      tulip = (await products(tester)).firstWhere((p) => p.name == 'Tulip');
      expect(tulip.isArchived, isFalse);
      await closeApp(tester);
    });
  });

  group('Materials', () {
    testWidgets('deletes an unused material', (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.materials);
      await longPress(tester, 'Glue');
      expect(find.text('Receive stock'), findsOneWidget);
      await tester.tap(find.text('Delete material'));
      await settle(tester);
      await confirm(tester, 'Delete');

      expect(find.text('Glue deleted'), findsOneWidget);
      expect((await materials(tester)).map((m) => m.name), ['Yarn']);
      await closeApp(tester);
    });

    testWidgets('stock history alone does not block a delete', (tester) async {
      await startApp(tester, seed: seed);
      final glue =
          (await materials(tester)).firstWhere((m) => m.name == 'Glue');
      await db<Result<void>>(
          tester,
          () => getIt<MaterialRepository>().receiveStock(
              materialId: glue.id!, packsReceived: 2, pricePerPack: 30));
      await openApp(tester, RouteNames.materials);
      await longPress(tester, 'Glue');
      await tester.tap(find.text('Delete material'));
      await settle(tester);
      expect(find.textContaining('You still have 2 on hand'), findsOneWidget);
      await confirm(tester, 'Delete');

      expect(find.text('Glue deleted'), findsOneWidget);
      expect((await materials(tester)).map((m) => m.name), ['Yarn']);
      await closeApp(tester);
    });

    testWidgets('archives, shows under Archived, and unarchives',
        (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.materials);
      await longPress(tester, 'Yarn');
      await tester.tap(find.text('Archive'));
      await settle(tester);

      expect(find.text('Yarn archived'), findsOneWidget);
      expect(_matNamed(await materials(tester), 'Yarn').isArchived, isTrue);
      expect(find.text('Yarn'), findsNothing);

      final chip = find.widgetWithText(AppChip, 'Archived');
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await settle(tester);
      await longPress(tester, 'Yarn');
      await tester.tap(find.text('Unarchive'));
      await settle(tester);
      expect(_matNamed(await materials(tester), 'Yarn').isArchived, isFalse);
      await closeApp(tester);
    });

    testWidgets('a material in a product says why and stays', (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.materials);
      await longPress(tester, 'Yarn');
      await tester.tap(find.text('Delete material'));
      await settle(tester);
      await confirm(tester, 'Delete');

      expect(find.textContaining('Cannot delete material'), findsOneWidget);
      expect(find.text('Yarn'), findsOneWidget);
      await closeApp(tester);
    });
  });

  group('Navigation', () {
    Finder tab(String label) => find.descendant(
        of: find.byType(NavigationBar), matching: find.text(label));

    testWidgets('Products is a tab with the buy list; Materials is under More',
        (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.today);
      expect(tab('Stock'), findsNothing);

      await tester.tap(tab('Products'));
      await settle(tester);
      expect(find.text('Tulip'), findsOneWidget);
      expect(find.textContaining('Buy list'), findsOneWidget);

      await tester.tap(tab('More'));
      await settle(tester);
      final row = find.text('Materials');
      await tester.ensureVisible(row);
      await tester.tap(row);
      await settle(tester);
      expect(find.text('Glue'), findsOneWidget);
      expect(find.textContaining('Buy list'), findsOneWidget);
      await closeApp(tester);
    });
  });

  group('Detail page menus', () {
    Future<void> archiveFromMenu(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await settle(tester);
      await tester.tap(find.text('Archive'));
      await settle(tester);
    }

    testWidgets('a product archives from its page and shows the tag',
        (tester) async {
      await startApp(tester, seed: seed);
      final strap =
          (await products(tester)).firstWhere((p) => p.name == 'Strap');
      await openApp(tester, RouteNames.productPath(strap.id!));
      await archiveFromMenu(tester);

      expect(find.text('Strap archived'), findsOneWidget);
      expect(find.text('ARCHIVED'), findsOneWidget);
      expect(
          (await products(tester))
              .firstWhere((p) => p.name == 'Strap')
              .isArchived,
          isTrue);

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await settle(tester);
      expect(find.text('Unarchive'), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('a material archives from its page and shows the tag',
        (tester) async {
      await startApp(tester, seed: seed);
      final glue = _matNamed(await materials(tester), 'Glue');
      await openApp(tester, RouteNames.materialPath(glue.id!));
      await archiveFromMenu(tester);

      expect(find.text('Glue archived'), findsOneWidget);
      expect(find.text('ARCHIVED'), findsOneWidget);
      expect(_matNamed(await materials(tester), 'Glue').isArchived, isTrue);
      await closeApp(tester);
    });
  });

  group('Channels', () {
    testWidgets('turns a channel off and on', (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.channels);
      await longPress(tester, 'Etsy');
      await tester.tap(find.text('Turn off'));
      await settle(tester);
      expect(_named(await channels(tester), 'Etsy').isActive, isFalse);

      await longPress(tester, 'Etsy');
      await tester.tap(find.text('Turn on'));
      await settle(tester);
      expect(_named(await channels(tester), 'Etsy').isActive, isTrue);
      await closeApp(tester);
    });

    testWidgets('deletes an unused channel, refuses a used one',
        (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.channels);
      await longPress(tester, 'Etsy');
      await tester.tap(find.text('Delete channel'));
      await settle(tester);
      await confirm(tester, 'Delete');
      expect(find.text('Channel deleted'), findsOneWidget);
      expect(find.text('Etsy'), findsNothing);

      await longPress(tester, 'Walk-in');
      await tester.tap(find.text('Delete channel'));
      await settle(tester);
      await confirm(tester, 'Delete');
      expect(find.textContaining('Cannot delete channel'), findsOneWidget);
      expect((await channels(tester)).map((c) => c.name), ['Walk-in']);
      await closeApp(tester);
    });
  });

  testWidgets('social links: long press removes a shortcut', (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.socialLinks);
    await longPress(tester, 'Facebook');
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Edit shortcut'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await settle(tester);
    await confirm(tester, 'Remove');

    expect(find.text('Facebook'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('order fields: long press deletes an unused field',
      (tester) async {
    await startApp(tester, seed: seed);
    await openApp(tester, RouteNames.orderFields);
    await longPress(tester, 'Address');
    expect(find.text('Edit field'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await settle(tester);
    await confirm(tester, 'Delete');

    expect(find.text('Address'), findsNothing);
    await closeApp(tester);
  });

  group('Today pinned notes', () {
    testWidgets('unpin from the long-press menu', (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.today);
      await longPress(tester, 'Supplier numbers');
      await tester.tap(find.text('Unpin'));
      await settle(tester);

      expect(find.textContaining('PINNED NOTES'), findsNothing);
      await closeApp(tester);
    });

    testWidgets('delete, then undo brings it back', (tester) async {
      await startApp(tester, seed: seed);
      await openApp(tester, RouteNames.today);
      await longPress(tester, 'Supplier numbers');
      await tester.tap(find.text('Delete'));
      await settle(tester);
      await confirm(tester, 'Delete');
      expect(find.text('Supplier numbers deleted'), findsOneWidget);
      expect(find.textContaining('PINNED NOTES'), findsNothing);

      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect(find.text('Supplier numbers'), findsOneWidget);
      await closeApp(tester);
    });
  });
}

Channel _named(List<Channel> all, String name) =>
    all.firstWhere((c) => c.name == name);

Material _matNamed(List<Material> all, String name) =>
    all.firstWhere((m) => m.name == name);
