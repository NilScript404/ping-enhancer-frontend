
import 'package:flutter/foundation.dart';

import 'package:my_app/features/icmp/models/ping_target.dart';
import 'package:my_app/features/icmp/repositories/icmp_repository.dart';

class IcmpViewModel extends ChangeNotifier {
  IcmpViewModel({
    required IcmpRepository repository,
  }) : _repository = repository;

  final IcmpRepository _repository;

  // -------------------------
  // State
  // -------------------------

  List<PingTarget> _targets = [];

  bool _isLoadingTargets = false;
  bool _isTestingIcmp = false;

  String? _errorMessage;

  PingFilter _filter = PingFilter.all;
  SortMetric _sortMetric = SortMetric.avg;
  bool _ascending = true;

  // -------------------------
  // Getters
  // -------------------------

  List<PingTarget> get targets => List.unmodifiable(_targets);

  bool get isLoadingTargets => _isLoadingTargets;

  bool get isTestingIcmp => _isTestingIcmp;

  String? get errorMessage => _errorMessage;

  PingFilter get filter => _filter;

  SortMetric get sortMetric => _sortMetric;

  bool get ascending => _ascending;

  // -------------------------
  // Fetch Targets
  // -------------------------

  Future<void> fetchTargets() async {
    if (_isLoadingTargets) return;

    _isLoadingTargets = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _targets = await _repository.fetchTargets();
    } catch (e) {
      _errorMessage = 'Failed to load servers: $e';
    } finally {
      _isLoadingTargets = false;
      notifyListeners();
    }
  }

  // -------------------------
  // ICMP Test
  // -------------------------

  Future<void> testAllTargets() async {
    if (_isTestingIcmp || _targets.isEmpty) return;

    _isTestingIcmp = true;
    _errorMessage = null;

    // Reset previous results before starting a new test.
    _targets = _targets.map((target) {
      return target.copyWith(
        min: 0,
        avg: 0,
        max: 0,
        loss: 0,
      );
    }).toList();

    notifyListeners();

    try {
      // Test all servers concurrently.
      await Future.wait(
        _targets.map(_testSingleTarget),
      );
    } catch (e) {
      _errorMessage = 'ICMP test failed: $e';
    } finally {
      _isTestingIcmp = false;
      notifyListeners();
    }
  }

  Future<void> _testSingleTarget(PingTarget target) async {
    final updatedTarget = await _repository.testTarget(target);

    final index = _targets.indexWhere(
          (item) => item.routeAddress == target.routeAddress,
    );

    if (index == -1) return;

    _targets[index] = updatedTarget;

    // Update the UI as each server test finishes.
    notifyListeners();
  }

  // -------------------------
  // Filtering
  // -------------------------

  void setFilter(PingFilter newFilter) {
    if (_filter == newFilter) return;

    _filter = newFilter;
    notifyListeners();
  }

  List<PingTarget> get visibleTargets {
    List<PingTarget> result = _targets.where((target) {
      switch (_filter) {
        case PingFilter.all:
          return true;

        case PingFilter.relay:
          return target.isRelay;

        case PingFilter.direct:
          return target.type.toLowerCase().contains('direct');
      }
    }).toList();

    result.sort(_compareTargets);

    return result;
  }

  // -------------------------
  // Sorting
  // -------------------------

  void setSortMetric(SortMetric metric) {
    if (_sortMetric == metric) return;

    _sortMetric = metric;
    notifyListeners();
  }

  void toggleSortDirection() {
    _ascending = !_ascending;
    notifyListeners();
  }

  int _compareTargets(PingTarget a, PingTarget b) {
    int result;

    switch (_sortMetric) {
      case SortMetric.avg:
        result = a.avg.compareTo(b.avg);
        break;

      case SortMetric.min:
        result = a.min.compareTo(b.min);
        break;

      case SortMetric.loss:
        result = a.loss.compareTo(b.loss);
        break;
    }

    return _ascending ? result : -result;
  }

  // -------------------------
  // Average Ping
  // -------------------------

  double _averagePingFor(List<PingTarget> list) {
    final testedTargets = list.where(
          (target) => target.avg > 0 && target.loss < 100,
    );

    if (testedTargets.isEmpty) return 0;

    final total = testedTargets.fold<int>(
      0,
          (sum, target) => sum + target.avg,
    );

    return total / testedTargets.length;
  }

  double get relayAverage {
    final relayTargets = _targets.where(
          (target) => target.type.toLowerCase().contains('relay'),
    ).toList();

    return _averagePingFor(relayTargets);
  }

  double get directAverage {
    final directTargets = _targets.where(
          (target) => target.type.toLowerCase().contains('direct'),
    ).toList();

    return _averagePingFor(directTargets);
  }

  // -------------------------
  // Best Target
  // -------------------------

  PingTarget? get bestTarget {
    final availableTargets = _targets.where(
          (target) => target.avg > 0 && target.loss < 100,
    ).toList();

    if (availableTargets.isEmpty) return null;

    availableTargets.sort(
          (a, b) => a.avg.compareTo(b.avg),
    );

    return availableTargets.first;
  }

  String get bestTargetLabel {
    final best = bestTarget;

    if (best == null) {
      return 'Best: -- (-1 ms)';
    }

    return 'Best: ${best.countryCode} (${best.avg} ms)';
  }
}
