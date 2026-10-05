import '../core/constants/app_constants.dart';

/// The units a database starts with, in list order. Seeded on a fresh install
/// and by migration v11, so an existing shop keeps reading "pc" everywhere it
/// read "PCS" before, and a new one has the common craft units to pick from.
///
/// [AppConstants.defaultUnitLabel] comes first, so it is the default.
const seedUnitLabels = [
  AppConstants.defaultUnitLabel,
  'sheet',
  'm',
  'cm',
  'g',
  'kg',
  'ml',
  'pack',
];
