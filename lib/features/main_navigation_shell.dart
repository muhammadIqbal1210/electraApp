import 'package:flutter/material.dart';
import 'package:electra_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:electra_app/features/iot/presentation/screens/iot_screen.dart';
import 'package:electra_app/features/supply_chain/presentation/screens/tracking_screen.dart';
import 'package:electra_app/features/ai_agent/presentation/screens/ai_agent_screen.dart';
import 'package:electra_app/features/profile/presentation/screens/profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    IotScreen(),
    AiAgentScreen(), // Budidaya / Smart Farming
    TrackingScreen(), // Pengiriman
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF388E3C),
          unselectedItemColor: const Color(0xFF64748B),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded, color: Color(0xFF388E3C)),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wifi_tethering_rounded),
              activeIcon: Icon(Icons.wifi_tethering_rounded, color: Color(0xFF388E3C)),
              label: 'IoT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco, color: Color(0xFF388E3C)),
              label: 'Budidaya',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping, color: Color(0xFF388E3C)),
              label: 'Pengiriman',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded, color: Color(0xFF388E3C)),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
