import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  List<dynamic> _data = [];
  String? _semester;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getMyAbsensi();
    if (mounted) {
      setState(() {
        _data = result['success'] == true ? result['data'] ?? [] : [];
        _semester = result['semester'];
        _isLoading = false;
      });
    }
  }

  Color _persenColor(double persen) {
    if (persen >= 80) return Colors.green;
    if (persen >= 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(title: const Text('Kehadiran Saya')),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat data kehadiran...')
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _data.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        EmptyState(
                          icon: Icons.event_busy_rounded,
                          title: 'Belum Ada Data Kehadiran',
                          subtitle:
                              'Dosen belum menginput kehadiran untuk semester ini',
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_semester != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text('Semester: $_semester',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13)),
                          ),
                        ..._data.map((item) {
                          final persen =
                              (item['persentase_hadir'] as num).toDouble();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF1565C0).withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['matkul_nama'] ?? '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1A237E))),
                                          Text(
                                              '${item['matkul_kode'] ?? ''} • Kelas ${item['nama_kelas'] ?? ''}',
                                              style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _persenColor(persen),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text('${persen.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: persen / 100,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFE3F2FD),
                                    color: _persenColor(persen),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                    'Hadir ${item['total_hadir']} dari ${item['total_pertemuan']} pertemuan',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[500])),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
    );
  }
}