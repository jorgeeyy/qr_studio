import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_studio/screens/main/create_screen.dart';
import 'package:qr_studio/screens/main/history_screen.dart';
import 'package:qr_studio/screens/main/profile_screen.dart';
import 'package:qr_studio/screens/main/scan_screen.dart';
import 'package:qr_studio/screens/settings_screen.dart';
import 'package:qr_studio/widgets/homescreen_widgets/quick_generate_icons.dart';
import 'package:qr_studio/widgets/homescreen_widgets/digital_experience.dart';
import 'package:qr_studio/widgets/homescreen_widgets/recent_codes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _createScreenKey = GlobalKey<CreateScreenState>();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera].request();
  }

  late final List<Widget> _screens = [
    _HomeTab(
      onStartScanning: () => _onNavTapped(2),
      onHistory: () => _onNavTapped(3),
      onCreateType: (type) {
        _createScreenKey.currentState?.setType(type);
        _onNavTapped(1);
      },
    ),
    CreateScreen(key: _createScreenKey),
    const ScanScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  static const List<String> _titles = [
    'Overview',
    'Create',
    'Scan',
    'History',
    'Profile',
  ];

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: _titles[_currentIndex],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(36),
              clipBehavior: Clip.antiAlias,
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavItem(
                      icon: Icons.home,
                      index: 0,
                      current: _currentIndex,
                      onTap: _onNavTapped,
                    ),
                    _NavItem(
                      icon: Icons.add_box_outlined,
                      index: 1,
                      current: _currentIndex,
                      onTap: _onNavTapped,
                    ),
                    _NavItem(
                      icon: Icons.qr_code_scanner_outlined,
                      index: 2,
                      current: _currentIndex,
                      onTap: _onNavTapped,
                    ),
                    _NavItem(
                      icon: Icons.history,
                      index: 3,
                      current: _currentIndex,
                      onTap: _onNavTapped,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.index,
    required this.current,
    required this.onTap,
  });

  final IconData icon;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            icon,
            color: selected ? Colors.white : Colors.grey,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.onStartScanning,
    required this.onHistory,
    required this.onCreateType,
  });

  final VoidCallback onStartScanning;
  final VoidCallback onHistory;
  final ValueChanged<QrCreateType> onCreateType;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            QuickGenerateIcons(onTypeTap: onCreateType),
            const SizedBox(height: 20),
            DigitalExperience(
              onCreateType: () => onCreateType(QrCreateType.website),
            ),
            const SizedBox(height: 20),
            RecentCodes(onHistory: onHistory),
          ],
        ),
      ),
    );
  }
}
