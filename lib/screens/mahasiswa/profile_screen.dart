import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final String role;
  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await ApiService.getUser();
    if (mounted) setState(() { _user = user; _isLoading = false; });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Logout',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        content: const Text('Apakah Anda yakin ingin keluar?',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (r) => false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingWidget());
    }

    final bool isMhs = widget.role == 'mahasiswa';
    final bool isDsn = widget.role == 'dosen';
    final bool isAdm = widget.role == 'admin';

    final List<Color> colors = isAdm
        ? [const Color(0xFF1A237E), const Color(0xFF283593)]
        : isDsn
            ? [const Color(0xFF0D47A1), const Color(0xFF1976D2)]
            : [const Color(0xFF1565C0), const Color(0xFF1E88E5)];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(colors, isAdm, isDsn),
              _buildCard(isMhs, isDsn, isAdm),
              _buildSettings(),
              _buildLogout(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Color> colors, bool isAdm, bool isDsn) {
    final roleLabel = isAdm ? 'ADMIN' : isDsn ? 'DOSEN' : 'MAHASISWA';

    return GradientHeader(
      colors: colors,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 45),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Profil Saya',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                isAdm
                    ? Icons.admin_panel_settings_rounded
                    : isDsn
                        ? Icons.school_rounded
                        : Icons.person_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 14),
            Text(_user?['name'] ?? '-',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(roleLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(bool isMhs, bool isDsn, bool isAdm) {
    final profile = _user?['profile'];
    List<Map<String, dynamic>> rows = [];

    if (isAdm) {
      rows = [
        {'icon': Icons.badge_rounded, 'label': 'Role', 'value': 'Super Admin'},
        {'icon': Icons.email_rounded, 'label': 'Email', 'value': _user?['email'] ?? '-'},
        {'icon': Icons.business_rounded, 'label': 'Institusi', 'value': 'Universitas Islam Riau'},
      ];
    } else if (isDsn) {
      rows = [
        {'icon': Icons.badge_rounded, 'label': 'NIDN', 'value': profile?['nidn'] ?? '-'},
        {'icon': Icons.school_rounded, 'label': 'Program Studi', 'value': profile?['prodi'] ?? '-'},
        {'icon': Icons.business_rounded, 'label': 'Fakultas', 'value': profile?['fakultas'] ?? '-'},
        {'icon': Icons.email_rounded, 'label': 'Email', 'value': _user?['email'] ?? '-'},
        {'icon': Icons.phone_rounded, 'label': 'No. HP', 'value': profile?['no_hp'] ?? '-'},
      ];
    } else {
      rows = [
        {'icon': Icons.badge_rounded, 'label': 'NIM', 'value': profile?['nim'] ?? '-'},
        {'icon': Icons.school_rounded, 'label': 'Program Studi', 'value': profile?['prodi'] ?? '-'},
        {'icon': Icons.business_rounded, 'label': 'Fakultas', 'value': profile?['fakultas'] ?? '-'},
        {'icon': Icons.calendar_month_rounded, 'label': 'Angkatan', 'value': '${profile?['angkatan'] ?? '-'}'},
        {'icon': Icons.email_rounded, 'label': 'Email', 'value': _user?['email'] ?? '-'},
        {'icon': Icons.star_rounded, 'label': 'IPK', 'value': '${profile?['ipk'] ?? '0.00'}'},
      ];
    }

    return Transform.translate(
      offset: const Offset(0, -22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: List.generate(rows.length * 2 - 1, (i) {
              if (i.isOdd) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Divider(height: 1, color: Colors.grey[100]),
                );
              }
              final row = rows[i ~/ 2];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(row['icon'] as IconData,
                          color: const Color(0xFF1565C0), size: 19),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row['label'] as String,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500])),
                          const SizedBox(height: 2),
                          Text(row['value'] as String,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ==================== SETTINGS ====================
  Widget _buildSettings() {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pengaturan Akun',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E))),
            const SizedBox(height: 12),
            _settingItem(
              Icons.lock_rounded,
              'Ubah Password',
              'Ganti password akun Anda',
              '/ubah_password',
            ),
            const SizedBox(height: 10),
            _settingItem(
              Icons.help_outline_rounded,
              'Bantuan & FAQ',
              'Pertanyaan yang sering diajukan',
              '/bantuan',
            ),
            const SizedBox(height: 10),
            _settingItem(
              Icons.info_outline_rounded,
              'Tentang Aplikasi',
              'Versi dan informasi aplikasi',
              '/tentang',
            ),
          ],
        ),
      ),
    );
  }

  // Tambah parameter route dan subtitle
  Widget _settingItem(IconData icon, String label, String subtitle, String route) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 19),
        ),
        title: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: Color(0xFF1A237E))),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Color(0xFF1565C0), size: 14),
        onTap: () => Navigator.pushNamed(context, route), // ← navigasi aktif
      ),
    );
  }

  Widget _buildLogout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showLogoutDialog,
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          label: const Text('Logout',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}