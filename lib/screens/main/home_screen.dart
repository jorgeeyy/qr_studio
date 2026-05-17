import 'package:flutter/material.dart';
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

  late final List<Widget> _screens = [
    _HomeTab(
      onStartScanning: () => _onNavTapped(2),
      onHistory: () => _onNavTapped(3),
    ),
    const CreateScreen(),
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
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Material(
          elevation: 15,
          borderRadius: BorderRadius.circular(36),
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.transparent,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            elevation: 0,
            items: [
              // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home',),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),

                activeIcon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.home, color: Colors.white),
                ),

                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.add_box_outlined,
                    color: Colors.white,
                  ),
                ),

                label: 'Create',
                backgroundColor: Colors.red,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_outlined,
                    color: Colors.white,
                  ),
                ),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.history, color: Colors.white),
                ),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                activeIcon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                label: 'Profile',
              ),
            ],
            onTap: _onNavTapped,
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onStartScanning, required this.onHistory});

  final VoidCallback onStartScanning;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const QuickGenerateIcons(),
            const SizedBox(height: 20),
            DigitalExperience(onStartScanning: onStartScanning),
            const SizedBox(height: 20),
            RecentCodes(onHistory: onHistory),
          ],
        ),
      ),
    );
  }
}
