import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String currency;
  final String dateFormat;
  final DateTime? lastBackupAt;

  const AppSettings({
    this.currency = 'PHP',
    this.dateFormat = 'dd MMM yyyy',
    this.lastBackupAt,
  });

  @override
  List<Object?> get props => [currency, dateFormat, lastBackupAt];
}
