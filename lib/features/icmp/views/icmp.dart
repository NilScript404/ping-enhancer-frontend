import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_app/core/theme/app_colors.dart';
import 'package:my_app/core/theme/app_theme.dart';

import 'package:my_app/features/icmp/models/ping_target.dart';
import 'package:my_app/features/icmp/repositories/icmp_repository.dart';
import 'package:my_app/features/icmp/services/icmp_api_service.dart';
import 'package:my_app/features/icmp/services/icmp_ping_service.dart';
import 'package:my_app/features/icmp/viewmodels/icmp_view_model.dart';


abstract final class _Palette {
  static const Color bunker = Color(0xFF0B0E15);
  static const Color shell = Color(0xFF1A1F2C);
  static const Color vulcan = Color(0xFF121620);
  static const Color vulcanDark = Color(0xFF0E121B);
  static const Color footer = Color(0xFF10141E);
  static const Color mirage = Color(0xFF1D293D);
  static const Color mirage70 = Color(0xB31D293D);
  static const Color mirage80 = Color(0xCC1D293D);
  static const Color white = Color(0xFFF1F5F9);
  static const Color muted = Color(0xFF90A1B9);
  static const Color mutedDark = Color(0xFF45556C);
  static const Color green = Color(0xFF00D492);
  static const Color greenText = Color(0xFF5EE9B5);
  static const Color jade = Color(0xFF00BC7D);
  static const Color blue = Color(0xFF00BCFF);
  static const Color yellow = Color(0xFFFFD230);
  static const Color red = Color(0xFFFF637E);
  static const Color blackPearl = Color(0xFF020618);
  static const Color paleBlue = Color(0xFFCAD5E2);
  static const Color rowSurface = Color(0xFF191E2B);
  static const Color rowBorder = Color(0xCC314158);
  static const Color relaySurface = Color(0x1A00BC7D);
  static const Color relayBorder = Color(0x6600BC7D);
  static const Color relayIconSurface = Color(0x3300D492);
  static const Color relayIconBorder = Color(0x8000D492);
}



/// ICMP page content only.
///
/// This widget is designed to be used inside the application's existing
/// Scaffold, AppBar/TopBar and bottomNavigationBar. It deliberately does not
/// create a MaterialApp, Scaffold, top bar, status bar or navigation bar.
class IcmpScreen extends StatelessWidget {
  const IcmpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final repository = IcmpRepository(
          apiService: IcmpApiService(),
          pingService: IcmpPingService(),
        );

        return IcmpViewModel(repository: repository)..fetchTargets();
      },
      child: const _IcmpScreenContent(),
    );
  }
}

class _IcmpScreenContent extends StatelessWidget {
  const _IcmpScreenContent();

  Future<void> _startIcmpTest(
      BuildContext context,
      IcmpViewModel vm,
      ) async {
    if (vm.isTestingIcmp) return;

    if (vm.targets.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'No servers are available to test.',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF0E121B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    await vm.testAllTargets();

    if (!context.mounted) return;

    final failedCount =
        vm.targets.where((target) => target.loss >= 100).length;

    final successfulCount = vm.targets.length - failedCount;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'ICMP finished: $successfulCount succeeded, $failedCount failed.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFF1F5F9),
            ),
          ),
          backgroundColor: const Color(0xFF0E121B),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IcmpViewModel>(
      builder: (context, vm, child) {
        return _buildContent(context, vm);
      },
    );
  }

  Widget _buildContent(BuildContext context, IcmpViewModel vm) {
    return ColoredBox(
      color: _Palette.bunker,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SizedBox(
              width: constraints.maxWidth > 372
                  ? 372
                  : constraints.maxWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary card
                    _PingSummaryCard(
                      isTesting: vm.isTestingIcmp,
                      serverCount: vm.targets.length,
                      bestLabel: vm.bestTargetLabel,
                      relayAverage: vm.relayAverage.round(),
                      directAverage: vm.directAverage.round(),
                      onTestPressed: () => _startIcmpTest(context, vm),
                    ),

                    const SizedBox(height: 16),

                    // Loading state
                    if (vm.isLoadingTargets)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _Palette.green,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )

                    // Error state
                    else if (vm.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _Palette.vulcan,
                          border: Border.all(
                            color: _Palette.red.withValues(alpha: 0.4),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: _Palette.red,
                              size: 30,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Failed to load servers',
                              style: TextStyle(
                                color: _Palette.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              vm.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _Palette.muted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: vm.fetchTargets,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                size: 16,
                              ),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _Palette.green,
                                foregroundColor: _Palette.blackPearl,
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      )

                    // Server results
                    else
                      _ResultsPanel(
                        filter: vm.filter,
                        sortMetric: vm.sortMetric,
                        ascending: vm.ascending,
                        targets: vm.visibleTargets,
                        onFilterChanged: vm.setFilter,
                        onSortMetricChanged: vm.setSortMetric,
                        onDirectionPressed: vm.toggleSortDirection,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PingSummaryCard extends StatelessWidget {
  const _PingSummaryCard({
    required this.isTesting,
    required this.serverCount,
    required this.bestLabel,
    required this.relayAverage,
    required this.directAverage,
    required this.onTestPressed,
  });

  final bool isTesting;
  final int serverCount;
  final String bestLabel;
  final int relayAverage;
  final int directAverage;
  final VoidCallback onTestPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.vulcan,
        border: Border.all(color: _Palette.mirage80),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 39,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ICMP Server Test',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w600,
                          color: _Palette.white,
                        ),
                      ),
                      Text(
                        'Gathering & testing server routes',
                        style: TextStyle(
                          fontSize: 11,
                          height: 16 / 11,
                          color: _Palette.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  bestLabel,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    height: 16 / 12,
                    color: _Palette.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 61,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    title: 'IR Relay Avg',
                    value: '$relayAverage ms',
                    titleColor: _Palette.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryMetric(
                    title: 'Direct Avg',
                    value: '$directAverage ms',
                    titleColor: _Palette.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: (isTesting || serverCount == 0) ? null : onTestPressed,
              icon: isTesting
                  ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _Palette.blackPearl,
                ),
              )
                  : const Icon(
                Icons.wifi_tethering_rounded,
                size: 14,
                color: _Palette.blackPearl,
              ),
              label: Text(
                isTesting
                    ? 'Testing all servers...'
                    : 'Test All Servers ($serverCount)',
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  color: _Palette.blackPearl,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.green,
                foregroundColor: _Palette.blackPearl,
                elevation: 0,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.title,
    required this.value,
    required this.titleColor,
  });

  final String title;
  final String value;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _Palette.bunker,
        border: Border.all(color: _Palette.mirage70),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 16 / 11,
              color: titleColor,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w700,
              color: _Palette.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.filter,
    required this.sortMetric,
    required this.ascending,
    required this.targets,
    required this.onFilterChanged,
    required this.onSortMetricChanged,
    required this.onDirectionPressed,
  });

  final PingFilter filter;
  final SortMetric sortMetric;
  final bool ascending;
  final List<PingTarget> targets;
  final ValueChanged<PingFilter> onFilterChanged;
  final ValueChanged<SortMetric> onSortMetricChanged;
  final VoidCallback onDirectionPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Palette.vulcan,
        border: Border.all(color: _Palette.mirage80),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterTabs(selected: filter, onChanged: onFilterChanged),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: [
                      _MetricFilter(
                        label: 'Avg Ping',
                        width: 67,
                        selected: sortMetric == SortMetric.avg,
                        onTap: () => onSortMetricChanged(SortMetric.avg),
                      ),
                      const SizedBox(width: 4),
                      _MetricFilter(
                        label: 'Min Ping',
                        width: 66,
                        selected: sortMetric == SortMetric.min,
                        onTap: () => onSortMetricChanged(SortMetric.min),
                      ),
                      const SizedBox(width: 4),
                      _MetricFilter(
                        label: 'Loss',
                        width: 46,
                        selected: sortMetric == SortMetric.loss,
                        onTap: () => onSortMetricChanged(SortMetric.loss),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _SortDirectionButton(
                ascending: ascending,
                onPressed: onDirectionPressed,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (targets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No servers found.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _Palette.muted, fontSize: 12),
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < targets.length; index++) ...[
                  _ServerResultCard(target: targets[index]),
                  if (index != targets.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onChanged});

  final PingFilter selected;
  final ValueChanged<PingFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _Palette.bunker,
        border: Border.all(color: _Palette.mirage80),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _FilterTab(
            label: 'All',
            selected: selected == PingFilter.all,
            onTap: () => onChanged(PingFilter.all),
          ),
          _FilterTab(
            label: 'Relay',
            selected: selected == PingFilter.relay,
            onTap: () => onChanged(PingFilter.relay),
          ),
          _FilterTab(
            label: 'Direct',
            selected: selected == PingFilter.direct,
            onTap: () => onChanged(PingFilter.direct),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? _Palette.green : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 30,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? _Palette.blackPearl : _Palette.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricFilter extends StatelessWidget {
  const _MetricFilter({
    required this.label,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0x2600BC7D) : _Palette.bunker,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: width,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? const Color(0x8000D492) : _Palette.mirage,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              height: 16 / 11,
              fontWeight: FontWeight.w500,
              color: selected ? _Palette.greenText : _Palette.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _SortDirectionButton extends StatelessWidget {
  const _SortDirectionButton({
    required this.ascending,
    required this.onPressed,
  });

  final bool ascending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Palette.bunker,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 58,
          height: 29,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: _Palette.mirage),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ascending ? Icons.vertical_align_top : Icons.vertical_align_bottom,
                size: 12,
                color: _Palette.green,
              ),
              const SizedBox(width: 4),
              Text(
                ascending ? 'Asc' : 'Desc',
                style: const TextStyle(
                  fontSize: 10,
                  height: 16 / 11,
                  fontWeight: FontWeight.w500,
                  color: _Palette.paleBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServerResultCard extends StatelessWidget {
  const _ServerResultCard({required this.target});

  final PingTarget target;

  @override
  Widget build(BuildContext context) {
    final relay = target.isRelay;
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: relay ? _Palette.relaySurface : _Palette.vulcanDark,
        border: Border.all(
          color: relay ? _Palette.relayBorder : _Palette.mirage80,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: relay ? _Palette.relayIconSurface : _Palette.bunker,
                    border: Border.all(
                      color: relay ? _Palette.relayIconBorder : _Palette.mirage,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    target.countryCode,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w700,
                      color: relay ? _Palette.greenText : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w600,
                          color: _Palette.white,
                        ),
                      ),
                      Text(
                        target.type,
                        style: TextStyle(
                          fontSize: 10,
                          height: 15 / 10,
                          fontWeight: FontWeight.w500,
                          color: relay ? _Palette.green : _Palette.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: _ResultMetric(
                    label: 'Min',
                    value: '${target.min} ms',
                    valueColor: _Palette.green,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ResultMetric(
                    label: 'Avg',
                    value: '${target.avg} ms',
                    valueColor: _Palette.white,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ResultMetric(
                    label: 'Max',
                    value: '${target.max} ms',
                    valueColor: _Palette.yellow,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ResultMetric(
                    label: 'Loss',
                    value: '${target.loss}%',
                    valueColor: relay ? _Palette.green : _Palette.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _Palette.bunker,
        border: Border.all(color: _Palette.mirage70),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              height: 15 / 10,
              color: _Palette.muted,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                height: 16 / 11,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
