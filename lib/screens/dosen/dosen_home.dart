import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class DosenHome extends StatefulWidget {
  const DosenHome({super.key});

  @override
  State<DosenHome> createState() => _DosenHomeState();
}

class _DosenHomeState extends State<DosenHome> {
  Map<String, dynamic>? _user;
  List<dynamic> _allKelas = [];
  List<dynamic> _jadwalHariIni = [];
  Map<String, dynamic>? _semester;
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
    final user = await ApiService.getUser();
    final kelasResult = await ApiService.getKelasDosen();
    final semResult = await ApiService.getSemesterAktif();

    List<dynamic> kelas = [];
    List<dynamic> jadwal = [];
    if (kelasResult['success'] == true) {
      kelas = kelasResult['data'] ?? [];
      jadwal = kelas.where((k) => k['hari'] == _hariIni).toList();
    }

    if (mounted) {
      setState(() {
        _user = user;
        _allKelas = kelas;
        _jadwalHariIni = jadwal;
        _semester = semResult['success'] == true ? semResult['data'] : null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingWidget(message: 'Memuat data...'));
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
              _buildStatCard(),
              _buildNotifikasi(),
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
      colors: const [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF1E88E5)],
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
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat Datang,',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      Text(_user?['name'] ?? 'Dosen',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.notifications_rounded,
                          color: Colors.white, size: 24),
                    ),
                    if (_jadwalHariIni.isNotEmpty)
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF5722),
                              shape: BoxShape.circle),
                        ),
                      ),
                  ],
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
                  const Icon(Icons.calendar_today_rounded,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          StatCard(
            value: '${_allKelas.length}',
            label: 'Kelas\nDiampu',
            icon: Icons.class_rounded,
            color: const Color(0xFF1565C0),
            bgColor: const Color(0xFFE3F2FD),
          ),
          const SizedBox(width: 14),
          StatCard(
            value: '${_jadwalHariIni.length}',
            label: 'Jadwal\nHari Ini',
            icon: Icons.today_rounded,
            color: const Color(0xFF00695C),
            bgColor: const Color(0xFFE0F2F1),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifikasi() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded,
                  color: Color(0xFF0D47A1), size: 18),
              const SizedBox(width: 8),
              Text('Jadwal Mengajar $_hariIni Ini',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                      fontSize: 15)),
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.event_available_rounded,
                      color: Color(0xFF1565C0), size: 22),
                  SizedBox(width: 12),
                  Text('Tidak ada jadwal mengajar hari ini',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A237E))),
                ],
              ),
            )
          else
            ..._jadwalHariIni.map((j) => _jadwalCard(j)),
        ],
      ),
    );
  }

  Widget _jadwalCard(dynamic j) {
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: const Color(0xFF0D47A1),
                borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.cast_for_education_rounded,
                color: Colors.white, size: 24),
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
                    const Icon(Icons.group_rounded,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                        'Kelas ${j['nama_kelas']} • ${j['terisi']} Mhs',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${j['hari']} | ${j['jam']}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 8),
                    const Icon(Icons.room_rounded,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(j['ruangan'] ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
              title: 'Menu Dosen',
              subtitle: 'Kelola perkuliahan Anda'),
          const SizedBox(height: 14),
          MenuCardList(
            icon: Icons.fact_check_rounded,
            label: 'Daftar Mahasiswa',
            desc: 'Lihat mahasiswa per kelas',
            color: const Color(0xFF0D47A1),
            bgColor: const Color(0xFFE3F2FD),
            onTap: () =>
                Navigator.pushNamed(context, '/daftar_mahasiswa'),
          ),
          const SizedBox(height: 12),
          MenuCardList(
            icon: Icons.event_available_rounded,
            label: 'Input Kehadiran',
            desc: 'Catat kehadiran per pertemuan',
            color: const Color(0xFF00838F),
            bgColor: const Color(0xFFE0F7FA),
            onTap: () => Navigator.pushNamed(context, '/input_absensi'),
          ),
          const SizedBox(height: 12),
          MenuCardList(
            icon: Icons.assignment_turned_in_rounded,
            label: 'Input & Edit Nilai',
            desc: 'Kelola nilai mahasiswa',
            color: const Color(0xFF00695C),
            bgColor: const Color(0xFFE0F2F1),
            onTap: () => Navigator.pushNamed(context, '/input_nilai'),
          ),
        ],
      ),
    );
  }
}