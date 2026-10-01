import 'package:flutter/material.dart';
import 'mahasiswa/mahasiswa_home.dart';
import 'mahasiswa/profile_screen.dart';
import 'dosen/dosen_home.dart';
import 'admin/admin_home.dart';

class MainNavigation extends StatefulWidget {
  final String role;
  const MainNavigation({super.key, required this.role});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  Widget _getHome() {
    switch (widget.role) {
      case 'dosen':
        return const DosenHome();
      case 'admin':
        return const AdminHome();
      default:
        return const MahasiswaHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _getHome(),
      ProfileScreen(role: widget.role),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1565C0),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _navIcon(Icons.home_outlined, 0),
              activeIcon: _navIcon(Icons.home_rounded, 0),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Icons.person_outline_rounded, 1),
              activeIcon: _navIcon(Icons.person_rounded, 1),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? const Color(0xFFE3F2FD)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon),
    );
  }
}