import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class TranskripScreen extends StatefulWidget {
  const TranskripScreen({super.key});

  @override
  State<TranskripScreen> createState() => _TranskripScreenState();
}

class _TranskripScreenState extends State<TranskripScreen> {
  List<dynamic> _semesters = []; // List per semester [{semester_nama, data, ip_semester, total_sks}]
  double _ipk = 0;
  int _totalSks = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getTranskrip();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _semesters = result['semesters'] ?? [];
          _ipk       = (result['ipk'] as num?)?.toDouble() ?? 0;
          _totalSks  = (result['total_sks'] as num?)?.toInt() ?? 0;
        }
        _isLoading = false;
      });
    }
  }

  String _getPredikat(double ipk) {
    if (ipk >= 3.51) return 'Dengan Pujian';
    if (ipk >= 3.01) return 'Sangat Memuaskan';
    if (ipk >= 2.76) return 'Memuaskan';
    if (ipk >= 2.00) return 'Cukup';
    return 'Kurang';
  }

  // Hitung total matkul dari semua semester
  int get _totalMatkul => _semesters.fold(
      0, (sum, s) => sum + ((s['data'] as List?)?.length ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Transkrip Nilai'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat transkrip...')
          : Column(
              children: [
                _buildHeader(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: SectionTitle(
                      title: 'Rekap Nilai',
                      subtitle: 'Seluruh mata kuliah per semester'),
                ),
                Expanded(
                  child: _semesters.isEmpty
                      ? const EmptyState(
                          icon: Icons.description_rounded,
                          title: 'Transkrip Kosong',
                          subtitle: 'Belum ada nilai yang tersedia',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _semesters.length,
                          itemBuilder: (ctx, i) =>
                              _buildSemesterSection(_semesters[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('$_totalSks', 'Total SKS'),
              _vLine(),
              _stat(_ipk.toStringAsFixed(2), 'IPK'),
              _vLine(),
              _stat('$_totalMatkul', 'Mata Kuliah'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(_getPredikat(_ipk),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION PER SEMESTER ====================
  Widget _buildSemesterSection(dynamic semester) {
    final List<dynamic> nilaiList = semester['data'] ?? [];
    final double ipSemester =
        (semester['ip_semester'] as num?)?.toDouble() ?? 0;
    final int totalSks = (semester['total_sks'] as num?)?.toInt() ?? 0;
    final String namaSemester = semester['semester_nama'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header semester
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Color(0xFF1565C0), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      namaSemester,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A237E)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _chipInfo('IP: ${ipSemester.toStringAsFixed(2)}'),
                    const SizedBox(width: 6),
                    _chipInfo('$totalSks SKS'),
                  ],
                ),
              ],
            ),
          ),
          // Daftar nilai di semester ini
          ...nilaiList.asMap().entries.map((entry) {
            final int no = entry.key + 1;
            final dynamic n = entry.value;
            return _buildCard(n, no, isLast: no == nilaiList.length);
          }),
        ],
      ),
    );
  }

  Widget _chipInfo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _vLine() =>
      Container(width: 1, height: 40, color: Colors.white24);

  Widget _buildCard(dynamic n, int no, {bool isLast = false}) {
    final color = getNilaiColor(n['nilai_akhir']);
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Text('$no',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1565C0))),
          ),
        ),
        title: Text(n['matkul_nama'] ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1A237E))),
        subtitle: Text(
            '${n['matkul_kode']} • ${n['matkul_sks']} SKS',
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        trailing: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(10)),
          child: Text(n['nilai_akhir'] ?? '-',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ),
    );
  }
}