import 'package:flutter/material.dart';

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

enum _PingFilter { all, relay, direct }
enum _SortMetric { avg, min, loss }

class _PingTarget {
  const _PingTarget({
    required this.countryCode,
    required this.city,
    required this.type,
    required this.min,
    required this.avg,
    required this.max,
    required this.loss,
  });

  final String countryCode;
  final String city;
  final String type;
  final int min;
  final int avg;
  final int max;
  final int loss;

  bool get isRelay => type == 'IR Relay';
}

const List<_PingTarget> _targets = [
  _PingTarget(
    countryCode: 'TR', city: 'Istanbul 01', type: 'IR Relay',
    min: 21, avg: 24, max: 27, loss: 0,
  ),
  _PingTarget(
    countryCode: 'AE', city: 'Dubai 01', type: 'IR Relay',
    min: 26, avg: 29, max: 32, loss: 0,
  ),
  _PingTarget(
    countryCode: 'DE', city: 'Frankfurt 01', type: 'IR Relay',
    min: 33, avg: 36, max: 39, loss: 0,
  ),
  _PingTarget(
    countryCode: 'NL', city: 'Amsterdam 01', type: 'IR Relay',
    min: 36, avg: 39, max: 42, loss: 0,
  ),
  _PingTarget(
    countryCode: 'TR', city: 'Istanbul 01', type: 'Direct',
    min: 46, avg: 49, max: 52, loss: 10,
  ),
  _PingTarget(
    countryCode: 'AE', city: 'Dubai 01', type: 'Direct',
    min: 55, avg: 58, max: 61, loss: 20,
  ),
  _PingTarget(
    countryCode: 'DE', city: 'Frankfurt 01', type: 'Direct',
    min: 66, avg: 69, max: 71, loss: 20,
  ),
  _PingTarget(
    countryCode: 'NL', city: 'Amsterdam 01', type: 'Direct',
    min: 71, avg: 74, max: 77, loss: 20,
  ),
];

/// ICMP page content only.
///
/// This widget is designed to be used inside the application's existing
/// Scaffold, AppBar/TopBar and bottomNavigationBar. It deliberately does not
/// create a MaterialApp, Scaffold, top bar, status bar or navigation bar.
class IcmpScreen extends StatefulWidget {
  const IcmpScreen({super.key});

  @override
  State<IcmpScreen> createState() => _IcmpScreenState();
}

class _IcmpScreenState extends State<IcmpScreen> {
  _PingFilter _filter = _PingFilter.all;
  _SortMetric _sortMetric = _SortMetric.avg;
  bool _ascending = true;

  List<_PingTarget> get _visibleTargets {
    final result = _targets.where((target) {
      switch (_filter) {
        case _PingFilter.all:
          return true;
        case _PingFilter.relay:
          return target.isRelay;
        case _PingFilter.direct:
          return !target.isRelay;
      }
    }).toList();

    int valueOf(_PingTarget target) {
      switch (_sortMetric) {
        case _SortMetric.avg:
          return target.avg;
        case _SortMetric.min:
          return target.min;
        case _SortMetric.loss:
          return target.loss;
      }
    }

    result.sort((a, b) {
      final comparison = valueOf(a).compareTo(valueOf(b));
      return _ascending ? comparison : -comparison;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _Palette.bunker,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The source design is 392 px wide, with a 10 px outer frame on
          // each side. The content area is therefore capped at 372 px.
          final contentWidth = constraints.maxWidth < 372
              ? constraints.maxWidth
              : 372.0;

          return Center(
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _PingSummaryCard(),
                    const SizedBox(height: 12),
                    _ResultsPanel(
                      filter: _filter,
                      sortMetric: _sortMetric,
                      ascending: _ascending,
                      targets: _visibleTargets,
                      onFilterChanged: (value) =>
                          setState(() => _filter = value),
                      onSortMetricChanged: (value) =>
                          setState(() => _sortMetric = value),
                      onDirectionPressed: () =>
                          setState(() => _ascending = !_ascending),
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
  const _PingSummaryCard();

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
                const Text(
                  'Best: TR (24 ms)',
                  style: TextStyle(
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
          const SizedBox(
            height: 61,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    title: 'IR Relay Avg',
                    value: '32 ms',
                    titleColor: _Palette.green,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _SummaryMetric(
                    title: 'Direct Avg',
                    value: '63 ms',
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
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'testing servers ...',
                        style: TextStyle(
                          color: _Palette.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: _Palette.vulcanDark,
                      behavior: SnackBarBehavior.floating,
                      shape: StadiumBorder(
                          side: BorderSide(color: _Palette.green))
                    ),
                  );
              },
              icon: const Icon(Icons.wifi_tethering_rounded,
                  size: 14, color: _Palette.blackPearl),
              label: const Text(
                'Start Deep ICMP Test (All Servers)',
                style: TextStyle(
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

  final _PingFilter filter;
  final _SortMetric sortMetric;
  final bool ascending;
  final List<_PingTarget> targets;
  final ValueChanged<_PingFilter> onFilterChanged;
  final ValueChanged<_SortMetric> onSortMetricChanged;
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
                        selected: sortMetric == _SortMetric.avg,
                        onTap: () => onSortMetricChanged(_SortMetric.avg),
                      ),
                      const SizedBox(width: 4),
                      _MetricFilter(
                        label: 'Min Ping',
                        width: 66,
                        selected: sortMetric == _SortMetric.min,
                        onTap: () => onSortMetricChanged(_SortMetric.min),
                      ),
                      const SizedBox(width: 4),
                      _MetricFilter(
                        label: 'Loss',
                        width: 46,
                        selected: sortMetric == _SortMetric.loss,
                        onTap: () => onSortMetricChanged(_SortMetric.loss),
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

  final _PingFilter selected;
  final ValueChanged<_PingFilter> onChanged;

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
            selected: selected == _PingFilter.all,
            onTap: () => onChanged(_PingFilter.all),
          ),
          _FilterTab(
            label: 'Relay',
            selected: selected == _PingFilter.relay,
            onTap: () => onChanged(_PingFilter.relay),
          ),
          _FilterTab(
            label: 'Direct',
            selected: selected == _PingFilter.direct,
            onTap: () => onChanged(_PingFilter.direct),
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

  final _PingTarget target;

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
                        target.city,
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

