import 'package:flutter/material.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 52),
            ),
            const SizedBox(height: 16),
            const Text('SIKAD UIR',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                    letterSpacing: 2)),
            const SizedBox(height: 6),
            Text('Sistem Informasi Akademik',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Versi 1.0.0',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 28),
            // Info cards
            _buildSection('Tentang Aplikasi', [
              _infoRow(Icons.info_outline_rounded, 'Nama Aplikasi', 'SIKAD UIR'),
              _infoRow(Icons.tag_rounded, 'Versi', '1.0.0'),
              _infoRow(Icons.phone_android_rounded, 'Platform', 'Android'),
              _infoRow(Icons.code_rounded, 'Framework', 'Flutter + Laravel 11'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Institusi', [
              _infoRow(Icons.business_rounded, 'Universitas',
                  'Universitas Islam Riau'),
              _infoRow(Icons.school_rounded, 'Fakultas',
                  'Fakultas Ilmu Komputer'),
              _infoRow(Icons.computer_rounded, 'Program Studi',
                  'Teknik Informatika'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Teknologi', [
              _infoRow(Icons.phone_android_rounded, 'Frontend',
                  'Flutter (Dart)'),
              _infoRow(Icons.dns_rounded, 'Backend', 'Laravel 11 (PHP)'),
              _infoRow(Icons.storage_rounded, 'Database', 'MySQL'),
              _infoRow(Icons.notifications_rounded, 'Push Notification',
                  'Firebase Cloud Messaging V1'),
              _infoRow(Icons.lock_rounded, 'Keamanan KRS',
                  'Pessimistic Locking'),
            ]),
            const SizedBox(height: 16),
            // Copyright
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.copyright_rounded,
                      color: Color(0xFF1565C0), size: 22),
                  const SizedBox(height: 8),
                  const Text('© 2026 SIKAD UIR',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E))),
                  const SizedBox(height: 4),
                  Text('Universitas Islam Riau',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(height: 4),
                  Text('Hak Cipta Dilindungi',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1565C0))),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A237E))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}