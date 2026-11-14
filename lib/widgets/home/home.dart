import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

// ==========================================
// 1. EXACT FIGMA COLORS EXTRACTED FROM YOUR CSS
// ==========================================
class FigmaColors {
  static const Color bunker = Color(0xFF0B0E15);
  static const Color vulcanCard = Color(0xFF121620);
  static const Color vulcanSheet = Color(0xFF131722);
  static const Color mirageBorder = Color(0xFF1D293D);
  static const Color mirageButton = Color(0xFF1B2030);

  static const Color caribbeanGreen = Color(0xFF00D492);
  static const Color turquoiseBlue = Color(0xFF5EE9B5);
  static const Color dodgerBlue = Color(0xFF00BCFF);

  static const Color catskillWhite = Color(0xFFF1F5F9);
  static const Color mystic = Color(0xFFE2E8F0);
  static const Color baliHai = Color(0xFF90A1B9);
  static const Color lynch = Color(0xFF62748E);
  static const Color fiord = Color(0xFF45556C);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Timer & Connection State ---
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isConnected = false;

  // --- Servers State ---
  String _activeServerTab = "All"; // All, Relay, Direct
  String _selectedServerCode = "TR1"; // Matches a specific server ID
  bool _isSortActive = false;

  // --- Games State ---
  final List _availableGames = [
  {"id": "PM", "name": "PUBG Mobile", "pkg": "com.tencent.ig", "color": Colors.orange},
  {"id": "VM", "name": "Valorant Mobile", "pkg": "com.riotgames.valorant", "color": Colors.pink},
  {"id": "WR", "name": "Wild Rift", "pkg": "com.riotgames.wildrift", "color": Colors.blue},
  {"id": "GI", "name": "Genshin Impact", "pkg": "com.miHoYo.Genshin", "color": Colors.purple},
  {"id": "ML", "name": "Mobile Legends", "pkg": "com.mobile.legends", "color": Colors.lightBlue},
  {"id": "BS", "name": "Brawl Stars", "pkg": "com.supercell.brawlstars", "color": Colors.amber},
  ];
  Set<String> _selectedGameIds = {'PM', 'VM', 'WR'}; // Default selected

  String get _formattedTime {
    final hours = (_secondsElapsed ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_secondsElapsed % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
      if (_isConnected) {
        _secondsElapsed = 0;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _secondsElapsed++;
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ==========================================
  // 2. SELECTED GAMES BOTTOM SHEET
  // ==========================================
  void _showSelectedGamesSheet() {
    // We create a temporary set so if the user clicks "Cancel", we don't save the changes.
    Set<String> tempSelected = Set.from(_selectedGameIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // StatefulBuilder allows the bottom sheet to update its own UI (like checkboxes)
        // without rebuilding the entire screen behind it.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: FigmaColors.vulcanSheet,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 50, offset: Offset(0, -12))
                  ],
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: FigmaColors.fiord,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Header (Selected Games | All | Clear | Close)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          const Text(
                            "Selected Games",
                            style: TextStyle(color: FigmaColors.catskillWhite, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          _buildSheetHeaderButton("All", onTap: () {
                            setModalState(() {
                              tempSelected.addAll(_availableGames.map((g) => g['id'] as String));
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
                                border: Border.all(color: FigmaColors.baliHai.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.close, size: 16, color: FigmaColors.baliHai),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: FigmaColors.bunker,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: FigmaColors.mirageBorder),
                        ),
                        child: TextField(
                          style: const TextStyle(color: FigmaColors.catskillWhite, fontSize: 12),
                          decoration: InputDecoration(
                            hintText: "Search game name or process ID...",
                            hintStyle: const TextStyle(color: FigmaColors.lynch, fontSize: 12),
                            prefixIcon: const Icon(Icons.search, color: FigmaColors.baliHai, size: 16),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),

                    // Games List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _availableGames.length,
                        itemBuilder: (context, index) {
                          final game = _availableGames[index];
                          final isSelected = tempSelected.contains(game['id']);

                          return _buildGameItem(
                              game['id'],
                              game['name'],
                              game['pkg'],
                              game['color'],
                              isSelected: isSelected,
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    tempSelected.remove(game['id']);
                                  } else {
                                    tempSelected.add(game['id']);
                                  }
                                });
                              }
                          );
                        },
                      ),
                    ),

                    // Footer Buttons (Cancel / Confirm)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0E111A),
                        border: Border(top: BorderSide(color: FigmaColors.mirageBorder)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 42,
                              width: 72,
                              decoration: BoxDecoration(
                                color: FigmaColors.mirageButton,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text("Cancel", style: TextStyle(color: FigmaColors.catskillWhite, fontSize: 12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Save the temporary selection to the main state and close
                                setState(() {
                                  _selectedGameIds = tempSelected;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: FigmaColors.caribbeanGreen,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text(
                                    "Confirm Selected Games (${tempSelected.length})",
                                    style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
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

  // ==========================================
  // 3. MAIN BUILD METHOD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.bunker,
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

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildConnectionStatusCard() {
    return Container(
      height: 195,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FigmaColors.vulcanCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FigmaColors.mirageBorder),
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
              color: FigmaColors.caribbeanGreen.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: FigmaColors.caribbeanGreen,
                width: 2.0,
              ),
              boxShadow: _isConnected ? [
                BoxShadow(
                  color: FigmaColors.caribbeanGreen.withOpacity(0.35),
                  blurRadius: 32,
                  spreadRadius: -8,
                ),
              ] : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.power_settings_new,
                  color: FigmaColors.caribbeanGreen,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  _isConnected ? "Connected" : "Connect",
                  style: const TextStyle(
                    color: FigmaColors.turquoiseBlue,
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
                        color: FigmaColors.baliHai,
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
    // Generate the summary string (e.g. "PUBG Mobile, Valorant Mobile...")
    final selectedNames = _availableGames
        .where((g) => _selectedGameIds.contains(g['id']))
        .map((g) => g['name'])
        .join(", ");

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: FigmaColors.vulcanCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FigmaColors.mirageBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FigmaColors.caribbeanGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FigmaColors.caribbeanGreen.withOpacity(0.3)),
            ),
            child: const Icon(Icons.gamepad, color: FigmaColors.caribbeanGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selected Games (${_selectedGameIds.length})",
                  style: const TextStyle(color: FigmaColors.catskillWhite, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  selectedNames.isEmpty ? "No games selected" : selectedNames,
                  style: const TextStyle(color: FigmaColors.baliHai, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSelectedGamesSheet,
            child: Row(
              children: [
                const Text("Select", style: TextStyle(color: FigmaColors.caribbeanGreen, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: FigmaColors.caribbeanGreen, size: 16),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildServersListCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FigmaColors.vulcanCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FigmaColors.mirageBorder),
      ),
      child: Column(
        children: [
          // --- Tabs ---
          Container(
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: FigmaColors.bunker,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: FigmaColors.mirageBorder),
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

          // --- Search & Filters Row ---
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: FigmaColors.bunker,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FigmaColors.mirageBorder),
                  ),
                  child: TextField(
                    style: const TextStyle(color: FigmaColors.catskillWhite, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: "Search server...",
                      hintStyle: const TextStyle(color: FigmaColors.lynch, fontSize: 12),
                      prefixIcon: const Icon(Icons.search, color: FigmaColors.baliHai, size: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Sort Button
              GestureDetector(
                onTap: () => setState(() => _isSortActive = !_isSortActive),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _isSortActive ? FigmaColors.mirageBorder : FigmaColors.bunker,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FigmaColors.mirageBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sort, color: _isSortActive ? FigmaColors.catskillWhite : FigmaColors.baliHai, size: 14),
                      const SizedBox(width: 4),
                      Text("Sort", style: TextStyle(color: _isSortActive ? FigmaColors.catskillWhite : FigmaColors.baliHai, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Ping Button
              GestureDetector(
                onTap: () {
                  // Add visual pinging logic here if needed
                },
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: FigmaColors.caribbeanGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.speed, color: Colors.black, size: 14),
                      const SizedBox(width: 4),
                      const Text("Ping", style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // --- Servers List ---
          Column(
            children: [
              _buildServerItem("TR1", "TR", "Istanbul 01", "24 ms", "IR Relay"),
              const Divider(color: FigmaColors.mirageBorder, height: 1),
              _buildServerItem("TR2", "TR", "Istanbul 01", "49 ms", "Direct", isDirect: true),
              const Divider(color: FigmaColors.mirageBorder, height: 1),
              _buildServerItem("DE1", "DE", "Frankfurt 01", "36 ms", "IR Relay"),
              const Divider(color: FigmaColors.mirageBorder, height: 1),
              _buildServerItem("DE2", "DE", "Frankfurt 01", "68 ms", "Direct", isDirect: true),
              const Divider(color: FigmaColors.mirageBorder, height: 1),
              _buildServerItem("NL1", "NL", "Amsterdam 01", "39 ms", "IR Relay"),
            ],
          )
        ],
      ),
    );
  }

  // ==========================================
  // REUSABLE UI BUILDERS
  // ==========================================

  Widget _buildServerTab(String title) {
    bool isActive = _activeServerTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeServerTab = title),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? FigmaColors.caribbeanGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  color: isActive ? Colors.black : FigmaColors.baliHai,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal
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
          color: FigmaColors.mirageButton,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: FigmaColors.baliHai),
              const SizedBox(width: 4),
            ],
            Text(text, style: const TextStyle(color: FigmaColors.catskillWhite, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameItem(String initials, String title, String package, Color iconColor, {required bool isSelected, required VoidCallback onTap}) {
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
                color: iconColor.withOpacity(0.1),
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
                  Text(title, style: const TextStyle(color: FigmaColors.catskillWhite, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(package, style: const TextStyle(color: FigmaColors.lynch, fontSize: 11)),
                ],
              ),
            ),
            // Checkbox
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? FigmaColors.caribbeanGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? FigmaColors.caribbeanGreen : FigmaColors.fiord),
              ),
              child: isSelected ? const Icon(Icons.check, color: FigmaColors.bunker, size: 14) : null,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildServerItem(String id, String code, String name, String ping, String type, {bool isDirect = false}) {
    bool isSelected = _selectedServerCode == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedServerCode = id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 57,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? FigmaColors.caribbeanGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? FigmaColors.caribbeanGreen.withOpacity(0.2) : FigmaColors.bunker,
                border: Border.all(color: isSelected ? FigmaColors.caribbeanGreen.withOpacity(0.5) : FigmaColors.mirageBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  code,
                  style: TextStyle(color: isSelected ? FigmaColors.turquoiseBlue : FigmaColors.baliHai, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: const TextStyle(color: FigmaColors.catskillWhite, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(ping, style: const TextStyle(color: FigmaColors.catskillWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(type, style: TextStyle(color: isDirect ? FigmaColors.dodgerBlue : FigmaColors.caribbeanGreen, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 12),
            // Check circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? FigmaColors.caribbeanGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? FigmaColors.caribbeanGreen : FigmaColors.fiord),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: FigmaColors.bunker) : null,
            )
          ],
        ),
      ),
    );
  }
}