import 'dart:async';
import 'dart:ui';
import 'package:dart_ping/dart_ping.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';
import 'package:my_app/core/theme/app_colors.dart';

class ServerConfig {
  final int id;
  final String name;
  final String location;
  final String routeAddress;
  final String routeType;
  final String value;
  final int bytesTotal;
  final int bytesUsed;
  final int remainingDays;
  int? pingMs;
  bool isPinging;
  bool pingFailed;

  ServerConfig({
    required this.id,
    required this.name,
    required this.location,
    required this.routeAddress,
    required this.routeType,
    required this.value,
    required this.bytesTotal,
    required this.bytesUsed,
    required this.remainingDays,
    this.pingMs,
    this.isPinging = false,
    this.pingFailed = false,
  });

  bool get isDirect => routeType.toLowerCase() == 'direct';
  String get displayType => isDirect ? 'Direct' : 'IR Relay';

  String get pingLabel {
    if (isPinging) return '...';
    if (pingMs != null) return '$pingMs ms';
    if (pingFailed) return 'Timeout';
    return '-- ms';
  }

  String get wireGuardEndpoint {
    final match = RegExp(r'Endpoint\s*=\s*([^\s]+)', caseSensitive: false).firstMatch(value);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
    return routeAddress.contains(':') ? routeAddress : '$routeAddress:51820';
  }

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      routeAddress: json['route_address']?.toString() ?? '',
      routeType: json['route_type']?.toString() ?? 'relay',
      value: json['value']?.toString() ?? '',
      bytesTotal: (json['bytes_total'] as num?)?.toInt() ?? 0,
      bytesUsed: (json['bytes_used'] as num?)?.toInt() ?? 0,
      remainingDays: (json['remaining_days'] as num?)?.toInt() ?? 0,
    );
  }
}

class GameItem {
  final String name;
  final String processName;

  GameItem({
    required this.name,
    required this.processName,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  Color get badgeColor {
    const palette = [
      Colors.orange,
      Colors.pink,
      Colors.blue,
      Colors.purple,
      Colors.lightBlue,
      Colors.amber,
      Colors.teal,
    ];
    return palette[name.hashCode.abs() % palette.length];
  }

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      name: json['name']?.toString() ?? '',
      processName: json['process_name']?.toString() ?? '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: Replace 10.0.2.2 with your PC's LAN IP for a physical phone, or your deployed backend URL
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  final _wireguard = WireGuardFlutter.instance;
  StreamSubscription<VpnStage>? _vpnStageSub;
  VpnStage _vpnStage = VpnStage.disconnected;
  bool _vpnInitialized = false;

  Timer? _timer;
  int _secondsElapsed = 0;

  String _activeServerTab = "All";
  int? _selectedServerId;
  bool _isSortActive = false;
  bool _isPingingAll = false;
  String _serverSearchQuery = "";

  bool _isLoadingData = true;
  String? _loadError;

  List<ServerConfig> _availableServers = [];
  List<GameItem> _availableGames = [];
  Set<String> _selectedGameProcesses = {};

  bool get _isConnected => _vpnStage == VpnStage.connected;
  bool get _isConnecting =>
      _vpnStage == VpnStage.connecting ||
          _vpnStage == VpnStage.preparing ||
          _vpnStage == VpnStage.authenticating ||
          _vpnStage == VpnStage.waitingConnection ||
          _vpnStage == VpnStage.reconnect;

  ServerConfig? get _selectedServer {
    for (final s in _availableServers) {
      if (s.id == _selectedServerId) return s;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initVpn();
    _fetchBackendData();
  }

  Future<void> _initVpn() async {
    try {
      await _wireguard.initialize(
        interfaceName: 'wg0',
        vpnName: 'Ping Enhancer',
      );
      _vpnInitialized = true;

      _vpnStageSub = _wireguard.vpnStageSnapshot.listen((stage) {
        if (!mounted) return;
        setState(() {
          _vpnStage = stage;
        });

        if (stage == VpnStage.connected) {
          _startTimer();
        } else if (stage == VpnStage.disconnected ||
            stage == VpnStage.denied ||
            stage == VpnStage.noConnection) {
          _stopTimer();
        }
      });

      final currentStage = await _wireguard.stage();
      if (!mounted) return;
      setState(() {
        _vpnStage = currentStage;
      });
      if (currentStage == VpnStage.connected) {
        _startTimer();
      }
    } catch (e) {
      _showSnack('Failed to initialize VPN service: $e');
    }
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      setState(() {
        _secondsElapsed = 0;
      });
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
        backgroundColor: AppColors.vulcanCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fetchBackendData() async {
    setState(() {
      _isLoadingData = true;
      _loadError = null;
    });

    try {
      final results = await Future.wait([
        _dio.get('/api/configs'),
        _dio.get('/api/games'),
      ]);

      final rawConfigs = results[0].data as List<dynamic>;
      final rawGames = results[1].data as List<dynamic>;

      final servers = rawConfigs
          .map((item) => ServerConfig.fromJson(item as Map<String, dynamic>))
          .toList();

      final games = rawGames
          .map((item) => GameItem.fromJson(item as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _availableServers = servers;
        _availableGames = games;
        if (_selectedServerId == null && servers.isNotEmpty) {
          _selectedServerId = servers.first.id;
        }
        _isLoadingData = false;
      });

      _pingAllServers();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingData = false;
        _loadError = 'Could not reach backend on port 3000.';
      });
    }
  }

  String _extractHost(String routeAddress) {
    final cleaned = routeAddress.trim().replaceFirst(RegExp(r'^https?://'), '');
    return cleaned.split(':').first.split('/').first;
  }

  Future<void> _pingSingleServer(ServerConfig server) async {
    final host = _extractHost(server.routeAddress);
    if (host.isEmpty) {
      server.pingMs = null;
      server.pingFailed = true;
      server.isPinging = false;
      return;
    }

    int? measuredMs;
    try {
      final ping = Ping(host, count: 1, timeout: 3);
      await for (final event in ping.stream) {
        if (event is PingResponse && event.time != null) {
          measuredMs = event.time!.inMilliseconds;
          break;
        }
      }
    } catch (_) {
      measuredMs = null;
    }

    if (!mounted) return;
    setState(() {
      server.pingMs = measuredMs;
      server.pingFailed = measuredMs == null;
      server.isPinging = false;
    });
  }

  Future<void> _pingAllServers() async {
    if (_isPingingAll || _availableServers.isEmpty) return;

    setState(() {
      _isPingingAll = true;
      for (final server in _availableServers) {
        server.isPinging = true;
        server.pingFailed = false;
      }
    });

    await Future.wait(_availableServers.map(_pingSingleServer));

    if (!mounted) return;
    setState(() {
      _isPingingAll = false;
    });
  }

  String get _formattedTime {
    final hours = (_secondsElapsed ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_secondsElapsed % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _connectToSelectedServer() async {
    if (!_vpnInitialized) {
      await _initVpn();
    }

    final server = _selectedServer;
    if (server == null) {
      _showSnack('Select a server first.');
      return;
    }

    if (server.value.trim().isEmpty) {
      _showSnack('Selected server has no WireGuard config.');
      return;
    }

    setState(() {
      _vpnStage = VpnStage.connecting;
    });

    try {
      final selectedApps = _selectedGameProcesses.where((p) => p.isNotEmpty).toList();

      await _wireguard.startVpn(
        serverAddress: server.wireGuardEndpoint,
        wgQuickConfig: server.value,
        providerBundleIdentifier: 'com.example.my_app',
        includedApps: selectedApps.isNotEmpty ? selectedApps : null,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _vpnStage = VpnStage.disconnected;
      });
      _showSnack('Connection failed: $e');
    }
  }

  Future<void> _disconnectVpn() async {
    try {
      await _wireguard.stopVpn();
    } catch (e) {
      _showSnack('Disconnect failed: $e');
    } finally {
      _stopTimer();
      if (mounted) {
        setState(() {
          _vpnStage = VpnStage.disconnected;
        });
      }
    }
  }

  Future<void> _toggleConnection() async {
    if (_isConnecting) return;

    if (_isConnected) {
      await _disconnectVpn();
    } else {
      await _connectToSelectedServer();
    }
  }

  Future<void> _selectServer(ServerConfig server) async {
    if (_selectedServerId == server.id) return;

    final wasConnected = _isConnected;
    setState(() {
      _selectedServerId = server.id;
    });

    if (wasConnected) {
      await _disconnectVpn();
      await _connectToSelectedServer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vpnStageSub?.cancel();
    super.dispose();
  }

  List<ServerConfig> get _filteredServers {
    final query = _serverSearchQuery.trim().toLowerCase();

    final filtered = _availableServers.where((server) {
      bool matchesTab = true;
      if (_activeServerTab == "Relay") matchesTab = !server.isDirect;
      if (_activeServerTab == "Direct") matchesTab = server.isDirect;

      bool matchesSearch = query.isEmpty ||
          server.name.toLowerCase().contains(query) ||
          server.location.toLowerCase().contains(query) ||
          server.displayType.toLowerCase().contains(query) ||
          server.routeAddress.toLowerCase().contains(query);

      return matchesTab && matchesSearch;
    }).toList();

    if (_isSortActive) {
      filtered.sort((a, b) {
        final pingA = a.pingMs ?? 999999;
        final pingB = b.pingMs ?? 999999;
        return pingA.compareTo(pingB);
      });
    }

    return filtered;
  }

  void _showSelectedGamesSheet() {
    Set<String> tempSelected = Set.from(_selectedGameProcesses);
    String gameSearchQuery = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final q = gameSearchQuery.trim().toLowerCase();
            final filteredGames = _availableGames.where((g) {
              return g.name.toLowerCase().contains(q) ||
                  g.processName.toLowerCase().contains(q);
            }).toList();

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: AppColors.vulcanSheet,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 50, offset: Offset(0, -12))
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.fiord,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          const Text(
                            "Selected Games",
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          _buildSheetHeaderButton("All", onTap: () {
                            setModalState(() {
                              tempSelected.addAll(_availableGames.map((g) => g.processName));
                            });
                          }),
                          const SizedBox(width: 6),
                          _buildSheetHeaderButton("Clear", icon: Icons.delete_outline, onTap: () {
                            setModalState(() {
                              tempSelected.clear();
                            });
                          }),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.bunkerBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.mirageBorder80),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setModalState(() {
                              gameSearchQuery = val;
                            });
                          },
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: "Search game name or process ID...",
                            hintStyle: TextStyle(color: AppColors.textPlaceholder, fontSize: 12),
                            prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 16),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredGames.isEmpty
                          ? const Center(
                        child: Text(
                          "No games found.",
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredGames.length,
                        itemBuilder: (context, index) {
                          final game = filteredGames[index];
                          final isSelected = tempSelected.contains(game.processName);

                          return _buildGameItem(
                            game.initials,
                            game.name,
                            game.processName,
                            game.badgeColor,
                            isSelected: isSelected,
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  tempSelected.remove(game.processName);
                                } else {
                                  tempSelected.add(game.processName);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: AppColors.vulcanInnerCard,
                        border: Border(top: BorderSide(color: AppColors.mirageBorder80)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 42,
                              width: 72,
                              decoration: BoxDecoration(
                                color: AppColors.mirageButton,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text("Cancel", style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final wasConnected = _isConnected;
                                setState(() {
                                  _selectedGameProcesses = tempSelected;
                                });
                                Navigator.pop(context);
                                if (wasConnected) {
                                  await _disconnectVpn();
                                  await _connectToSelectedServer();
                                }
                              },
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.caribbeanGreen,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text(
                                    "Confirm Selected Games (${tempSelected.length})",
                                    style: const TextStyle(color: AppColors.blackPearl, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bunkerBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildConnectionStatusCard(),
            const SizedBox(height: 12),
            _buildSelectedGamesSummaryCard(),
            const SizedBox(height: 12),
            _buildServersListCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    final statusText = _isConnecting
        ? "Connecting..."
        : _isConnected
        ? "Connected"
        : "Connect";

    return Container(
      height: 195,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.vulcanCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mirageBorder80),
      ),
      child: Center(
        child: GestureDetector(
          onTap: _toggleConnection,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.jade10,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isConnecting ? AppColors.sunglowYellow : AppColors.caribbeanGreen,
                width: 2.0,
              ),
              boxShadow: _isConnected
                  ? const [
                BoxShadow(
                  color: AppColors.jade35,
                  blurRadius: 32,
                  spreadRadius: -8,
                ),
              ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isConnecting)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.sunglowYellow,
                    ),
                  )
                else
                  const Icon(
                    Icons.power_settings_new,
                    color: AppColors.caribbeanGreen,
                    size: 28,
                  ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: _isConnecting ? AppColors.sunglowYellow : AppColors.turquoiseBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isConnected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _formattedTime,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedGamesSummaryCard() {
    final selectedNames = _availableGames
        .where((g) => _selectedGameProcesses.contains(g.processName))
        .map((g) => g.name)
        .join(", ");

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.vulcanCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mirageBorder80),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.jade10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.caribbeanGreen.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.gamepad, color: AppColors.caribbeanGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selected Games (${_selectedGameProcesses.length})",
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  selectedNames.isEmpty ? "All traffic (no games selected)" : selectedNames,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSelectedGamesSheet,
            child: const Row(
              children: [
                Text("Select", style: TextStyle(color: AppColors.caribbeanGreen, fontSize: 12, fontWeight: FontWeight.w500)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: AppColors.caribbeanGreen, size: 16),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildServersListCard() {
    final servers = _filteredServers;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.vulcanCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mirageBorder80),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.bunkerBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.mirageBorder80),
            ),
            child: Row(
              children: [
                _buildServerTab("All"),
                _buildServerTab("Relay"),
                _buildServerTab("Direct"),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.bunkerBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.mirageBorder80),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _serverSearchQuery = val;
                      });
                    },
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: "Search server...",
                      hintStyle: TextStyle(color: AppColors.textPlaceholder, fontSize: 12),
                      prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _isSortActive = !_isSortActive),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _isSortActive ? AppColors.jade15 : AppColors.bunkerBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isSortActive ? AppColors.caribbeanGreen50 : AppColors.mirageBorder80,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort,
                        color: _isSortActive ? AppColors.turquoiseBlue : AppColors.textMuted,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Sort",
                        style: TextStyle(
                          color: _isSortActive ? AppColors.turquoiseBlue : AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _isPingingAll ? null : _pingAllServers,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _isPingingAll
                        ? AppColors.caribbeanGreen.withValues(alpha: 0.6)
                        : AppColors.caribbeanGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (_isPingingAll)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.blackPearl,
                          ),
                        )
                      else
                        const Icon(Icons.speed, color: AppColors.blackPearl, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _isPingingAll ? "Pinging" : "Ping",
                        style: const TextStyle(color: AppColors.blackPearl, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLoadingData)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.caribbeanGreen, strokeWidth: 2),
              ),
            )
          else if (_loadError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(_loadError!, style: const TextStyle(color: AppColors.watermelonRed, fontSize: 12)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _fetchBackendData,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.mirageButton,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text("Retry", style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            )
          else if (servers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text("No servers match your search or filter.", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ),
              )
            else
              Column(
                children: servers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final server = entry.value;
                  return Column(
                    children: [
                      _buildServerItem(server),
                      if (index < servers.length - 1)
                        const Divider(color: AppColors.mirageBorder80, height: 1),
                    ],
                  );
                }).toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildServerTab(String title) {
    final isActive = _activeServerTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeServerTab = title),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? AppColors.caribbeanGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? AppColors.blackPearl : AppColors.textMuted,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetHeaderButton(String text, {IconData? icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.mirageButton,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
            ],
            Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameItem(
      String initials,
      String title,
      String package,
      Color iconColor, {
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 61,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(package, style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 11)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.caribbeanGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.caribbeanGreen : AppColors.fiord),
              ),
              child: isSelected ? const Icon(Icons.check, color: AppColors.bunkerBg, size: 14) : null,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildServerItem(ServerConfig server) {
    final isSelected = _selectedServerId == server.id;

    return GestureDetector(
      onTap: () => _selectServer(server),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 57,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.jade10 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.caribbeanGreen20 : AppColors.bunkerBg,
                border: Border.all(color: isSelected ? AppColors.caribbeanGreen50 : AppColors.mirageBorder80),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  server.location,
                  style: TextStyle(
                    color: isSelected ? AppColors.turquoiseBlue : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                server.name,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  server.pingLabel,
                  style: TextStyle(
                    color: server.pingFailed ? AppColors.watermelonRed : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  server.displayType,
                  style: TextStyle(
                    color: server.isDirect ? AppColors.dodgerBlue : AppColors.caribbeanGreen,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.caribbeanGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.caribbeanGreen : AppColors.fiord),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: AppColors.bunkerBg) : null,
            )
          ],
        ),
      ),
    );
  }
}