import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class LihatKRSScreen extends StatefulWidget {
  const LihatKRSScreen({super.key});

  @override
  State<LihatKRSScreen> createState() => _LihatKRSScreenState();
}

class _LihatKRSScreenState extends State<LihatKRSScreen> {
  List<dynamic> _krsList = [];
  String _semesterNama = '';
  int _totalSks = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getMyKRS();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _krsList = result['data'] ?? [];
          _semesterNama = result['semester'] ?? '';
          _totalSks = (result['total_sks'] as num?)?.toInt() ?? 0;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('KRS Saya'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat KRS...')
          : Column(
              children: [
                _buildSummary(),
                const SizedBox(height: 8),
                Expanded(
                  child: _krsList.isEmpty
                      ? const EmptyState(
                          icon: Icons.list_alt_rounded,
                          title: 'KRS Kosong',
                          subtitle: 'Anda belum mengisi KRS semester ini',
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _krsList.length,
                          itemBuilder: (ctx, i) =>
                              _buildCard(_krsList[i], i + 1),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummary() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('${_krsList.length}', 'Mata Kuliah'),
          _vLine(),
          _stat('$_totalSks', 'Total SKS'),
          _vLine(),
          _stat(_semesterNama.split(' ').first, 'Semester'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _vLine() =>
      Container(width: 1, height: 40, color: Colors.white24);

  Widget _buildCard(dynamic k, int no) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text('$no',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k['matkul_nama'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A237E))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CustomChip(
                          text: k['matkul_kode'] ?? '',
                          bgColor: const Color(0xFFE3F2FD),
                          textColor: const Color(0xFF1565C0)),
                      const SizedBox(width: 6),
                      CustomChip(
                          text: '${k['matkul_sks']} SKS',
                          bgColor: const Color(0xFFE8F5E9),
                          textColor: Colors.green[700]!),
                      const SizedBox(width: 6),
                      CustomChip(
                          text: 'Kelas ${k['nama_kelas']}',
                          bgColor: const Color(0xFFE8EAF6),
                          textColor: const Color(0xFF283593)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_rounded,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(k['dosen_nama'] ?? '',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${k['hari']} | ${k['jam']}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 8),
                      const Icon(Icons.room_rounded,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(k['ruangan'] ?? '',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}