import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class MahasiswaHome extends StatefulWidget {
  const MahasiswaHome({super.key});

  @override
  State<MahasiswaHome> createState() => _MahasiswaHomeState();
}

class _MahasiswaHomeState extends State<MahasiswaHome> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _semester;
  List<dynamic> _jadwalHariIni = [];
  bool _isLoading = true;

  final List<String> _hariList = [
    '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];
  String get _hariIni => _hariList[DateTime.now().weekday];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user      = await ApiService.getUser();
      final semResult = await ApiService.getSemesterAktif();
      final krsResult = await ApiService.getMyKRS();

      List<dynamic> jadwal = [];
      if (krsResult['success'] == true && krsResult['data'] != null) {
        jadwal = (krsResult['data'] as List)
            .where((k) => k['hari'] == _hariIni)
            .toList();
      }

      if (mounted) {
        setState(() {
          _user          = user;
          _semester      = semResult['success'] == true ? semResult['data'] : null;
          _jadwalHariIni = jadwal;
          _isLoading     = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingWidget(message: 'Memuat data...'));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildInfoCard(),
              _buildJadwal(),
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
      colors: const [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat Datang,',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(_user?['name'] ?? 'Mahasiswa',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
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
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Semester Aktif',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final profile = _user?['profile'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Row(
          children: [
            _infoItem('NIM', profile?['nim'] ?? '-'),
            _vertDivider(),
            _infoItem('Semester', '${profile?['semester'] ?? '-'}'),
            _vertDivider(),
            _infoItem('IPK', '${profile?['ipk'] ?? '0.00'}'),
            _vertDivider(),
            _infoItem('Max SKS', '${profile?['max_sks'] ?? '0'}'),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0))),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _vertDivider() =>
      Container(width: 1, height: 35, color: Colors.grey[200]);

  Widget _buildJadwal() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded,
                  color: Color(0xFF1565C0), size: 18),
              const SizedBox(width: 8),
              Text('Jadwal Kuliah $_hariIni Ini',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E), fontSize: 15)),
              const Spacer(),
              Text('${_jadwalHariIni.length} kelas',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 10),
          if (_jadwalHariIni.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.event_available_rounded,
                        color: Color(0xFF1565C0), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tidak ada kelas hari ini',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0))),
                        Text('Selamat beristirahat!',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ..._jadwalHariIni.map((j) => _jadwalCard(j)),
        ],
      ),
    );
  }

  Widget _jadwalCard(Map<String, dynamic> j) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.class_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(j['matkul_nama'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A237E))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(j['jam'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 10),
                    const Icon(Icons.room_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(j['ruangan'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          CustomChip(
            text: 'Kelas ${j['nama_kelas']}',
            bgColor: const Color(0xFFE3F2FD),
            textColor: const Color(0xFF1565C0),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menus = [
      {
        'icon': Icons.edit_note_rounded,
        'label': 'Input KRS',
        'desc': 'Pilih mata kuliah semester ini',
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
        'route': '/krs',
      },
      {
        'icon': Icons.list_alt_rounded,
        'label': 'Lihat KRS',
        'desc': 'KRS yang sudah diambil',
        'color': const Color(0xFF0277BD),
        'bg': const Color(0xFFE1F5FE),
        'route': '/lihat_krs',
      },
      {
        'icon': Icons.grade_rounded,
        'label': 'KHS',
        'desc': 'Kartu Hasil Studi',
        'color': const Color(0xFF00695C),
        'bg': const Color(0xFFE0F2F1),
        'route': '/khs',
      },
      {
        'icon': Icons.description_rounded,
        'label': 'Transkrip',
        'desc': 'Rekap nilai keseluruhan',
        'color': const Color(0xFF283593),
        'bg': const Color(0xFFE8EAF6),
        'route': '/transkrip',
      },
      {
        'icon': Icons.show_chart_rounded,
        'label': 'Progres Akademik',
        'desc': 'Grafik tren IPS per semester',
        'color': const Color(0xFF6A1B9A),
        'bg': const Color(0xFFF3E5F5),
        'route': '/progres',
      },
      // ← MENU BARU: Kehadiran
      {
        'icon': Icons.event_available_rounded,
        'label': 'Kehadiran',
        'desc': 'Rekap kehadiran per mata kuliah',
        'color': const Color(0xFF00838F),
        'bg': const Color(0xFFE0F7FA),
        'route': '/absensi',
      },
      // ← MENU BARU: Daftarkan Orang Tua/Wali
      {
        'icon': Icons.family_restroom_rounded,
        'label': 'Orang Tua/Wali',
        'desc': 'Daftarkan akun pemantauan untuk orang tua',
        'color': const Color(0xFFAD1457),
        'bg': const Color(0xFFFCE4EC),
        'route': '/daftar-orangtua',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
              title: 'Menu Akademik',
              subtitle: 'Kelola kebutuhan akademik Anda'),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.05,
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
                onTap: () => Navigator.pushNamed(context, m['route'] as String),
              );
            },
          ),
        ],
      ),
    );
  }
}