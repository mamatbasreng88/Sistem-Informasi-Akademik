import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  Map<String, dynamic>? _semester;
  int _totalMhs = 0;
  int _totalDosen = 0;
  int _totalMatkul = 0;
  int _totalKelas = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      ApiService.getSemesterAktif(),
      ApiService.getMahasiswaList(),
      ApiService.getDosenList(),
      ApiService.getMatkulList(),
      ApiService.getKelasList(),
    ]);

    if (mounted) {
      setState(() {
        _semester = results[0]['success'] == true ? results[0]['data'] : null;
        _totalMhs = (results[1]['data'] as List?)?.length ?? 0;
        _totalDosen = (results[2]['data'] as List?)?.length ?? 0;
        _totalMatkul = (results[3]['data'] as List?)?.length ?? 0;
        _totalKelas = (results[4]['data'] as List?)?.length ?? 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: LoadingWidget(message: 'Memuat dashboard...'));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildStatGrid(),
              _buildMenuSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GradientHeader(
      colors: const [
        Color(0xFF1A237E),
        Color(0xFF283593),
        Color(0xFF3949AB)
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selamat Datang,',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      Text('Admin Kampus',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold)),
                      Text('Staff Akademik - UIR',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.today_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Semester Aktif',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                        Text(
                          _semester?['nama'] ?? 'Belum ada semester aktif',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _semester != null
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _semester != null ? 'Aktif' : 'Tidak Ada',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              StatCard(
                value: '$_totalMhs',
                label: 'Total\nMahasiswa',
                icon: Icons.people_rounded,
                color: const Color(0xFF1565C0),
                bgColor: const Color(0xFFE3F2FD),
              ),
              const SizedBox(width: 14),
              StatCard(
                value: '$_totalDosen',
                label: 'Total\nDosen',
                icon: Icons.school_rounded,
                color: const Color(0xFF6A1B9A),
                bgColor: const Color(0xFFF3E5F5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              StatCard(
                value: '$_totalMatkul',
                label: 'Total\nMatkul',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF00695C),
                bgColor: const Color(0xFFE0F2F1),
              ),
              const SizedBox(width: 14),
              StatCard(
                value: '$_totalKelas',
                label: 'Total\nKelas',
                icon: Icons.class_rounded,
                color: const Color(0xFFE65100),
                bgColor: const Color(0xFFFBE9E7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menus = [
      {
        'icon': Icons.person_add_rounded,
        'label': 'Kelola Mahasiswa',
        'desc': 'Tambah, edit, hapus akun mahasiswa',
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
        'route': '/kelola_mahasiswa',
      },
      {
        'icon': Icons.manage_accounts_rounded,
        'label': 'Kelola Dosen',
        'desc': 'Tambah, edit, hapus akun dosen',
        'color': const Color(0xFF6A1B9A),
        'bg': const Color(0xFFF3E5F5),
        'route': '/kelola_dosen',
      },
      {
        'icon': Icons.menu_book_rounded,
        'label': 'Kelola Mata Kuliah',
        'desc': 'Tambah dan kelola mata kuliah',
        'color': const Color(0xFF00695C),
        'bg': const Color(0xFFE0F2F1),
        'route': '/kelola_matkul',
      },
      {
        'icon': Icons.class_rounded,
        'label': 'Kelola Kelas',
        'desc': 'Atur kelas, dosen & kapasitas',
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFBE9E7),
        'route': '/kelola_kelas',
      },
      {
        'icon': Icons.payment_rounded,
        'label': 'Status Pembayaran',
        'desc': 'Input status bayar mahasiswa',
        'color': const Color(0xFF1B5E20),
        'bg': const Color(0xFFE8F5E9),
        'route': '/pembayaran',
      },
      {
        'icon': Icons.calendar_month_rounded,
        'label': 'Kelola Semester',
        'desc': 'Atur semester & periode KRS',
        'color': const Color(0xFF880E4F),
        'bg': const Color(0xFFFCE4EC),
        'route': '/semester',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
              title: 'Manajemen Sistem',
              subtitle: 'Kelola semua data akademik'),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
            ),
            itemCount: menus.length,
            itemBuilder: (ctx, i) {
              final m = menus[i];
              return MenuCardGrid(
                icon: m['icon'] as IconData,
                label: m['label'] as String,
                desc: m['desc'] as String,
                color: m['color'] as Color,
                bgColor: m['bg'] as Color,
                onTap: () =>
                    Navigator.pushNamed(context, m['route'] as String)
                        .then((_) => _loadData()),
              );
            },
          ),
        ],
      ),
    );
  }
}