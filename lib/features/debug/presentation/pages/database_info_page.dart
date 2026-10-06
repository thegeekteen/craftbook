import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/factory/coverage.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_label.dart';
import '../../domain/entities/database_info.dart';
import '../bloc/debug_cubit.dart';
import '../bloc/debug_state.dart';

/// What the database holds and, more usefully, which of the app's options the
/// data in it actually exercised. A zero or a missing line here is a gap in the
/// sample shop rather than a quiet screen.
class DatabaseInfoPage extends StatelessWidget {
  const DatabaseInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DebugCubit>()..loadInfo(),
      child: BlocBuilder<DebugCubit, DebugState>(
        builder: (context, state) {
          final info = state.info;
          return Scaffold(
            appBar: AppBar(title: const Text('Database & coverage')),
            body: info == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: AppSpacing.page,
                    children: [
                      const SectionLabel('This database',
                          padding: EdgeInsets.fromLTRB(2, 4, 2, 0)),
                      const SizedBox(height: 8),
                      _Card(rows: [
                        _Row(
                            label: 'Schema',
                            value: 'v${info.schemaVersion}',
                            mono: true),
                        _Row(label: 'Rows', value: '${info.totalRows}'),
                        _Row(label: 'File', value: info.location, mono: true),
                      ]),
                      const SectionLabel('Coverage',
                          padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
                      const SizedBox(height: 8),
                      _CoverageCard(info: info),
                      const SectionLabel('Tables',
                          padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
                      const SizedBox(height: 8),
                      _Card(
                        rows: [
                          for (final entry in info.tableCounts.entries)
                            _Row(label: entry.key, value: '${entry.value}'),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard({required this.info});

  final DatabaseInfo info;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final coverage = info.coverage;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.isComplete
                ? 'Every option the app offers showed up somewhere.'
                : 'Not everything was exercised (${info.gaps.length} missing).',
            style: AppTextStyles.bodyMedium
                .copyWith(color: info.isComplete ? c.go : c.alert),
          ),
          if (!info.isComplete) ...[
            const SizedBox(height: 8),
            for (final gap in info.gaps)
              Text('· $gap',
                  style: AppTextStyles.bodySmall.copyWith(color: c.alert)),
          ],
          for (final domain in coverageDomains)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(domain.label.toUpperCase(),
                      style: AppTextStyles.monoLabel.copyWith(color: c.muted)),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      for (final entry in coverage.ranked(domain.key))
                        Text('${entry.key} ${entry.value}',
                            style:
                                AppTextStyles.bodySmall.copyWith(color: c.ink)),
                      if (!domain.required && coverage.used(domain.key).isEmpty)
                        Text('none',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: c.muted)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) =>
      AppCard.flush(child: CardList(children: rows));
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CardRow(
      title: Text(label, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        value,
        style: (mono ? AppTextStyles.monoTag : AppTextStyles.bodySmall)
            .copyWith(color: c.muted),
      ),
    );
  }
}
