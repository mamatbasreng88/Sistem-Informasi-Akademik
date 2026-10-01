import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class KHSScreen extends StatefulWidget {
  const KHSScreen({super.key});

  @override
  State<KHSScreen> createState() => _KHSScreenState();
}

class _KHSScreenState extends State<KHSScreen> {
  Map<String, dynamic>? _semesterTerakhir;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getProgres();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          final semesters = result['data_semester'] as List<dynamic>? ?? [];
          _semesterTerakhir = semesters.isNotEmpty ? semesters.last : null;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(title: const Text('Kartu Hasil Studi (KHS)')),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat KHS...')
          : _semesterTerakhir == null
              ? const EmptyState(
                  icon: Icons.description_rounded,
                  title: 'Belum Ada Nilai',
                  subtitle: 'Nilai semester ini belum diinput dosen',
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00695C),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Semester ${_semesterTerakhir!['semester_ke']} — ${_semesterTerakhir!['semester_nama']}',
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(
                                  'IPS: ${_semesterTerakhir!['ips']}   •   ${_semesterTerakhir!['total_sks']} SKS   •   ${_semesterTerakhir!['jumlah_matkul']} Mata Kuliah',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Rincian Nilai per Mata Kuliah',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A237E))),
                        const SizedBox(height: 10),
                        ...(_semesterTerakhir!['detail_nilai'] as List<dynamic>? ?? [])
                            .map((n) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8, offset: const Offset(0, 2),
                                    )],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(n['matkul_nama'] ?? '',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1A237E))),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: _nilaiColor(n['nilai_akhir_huruf'] ?? '-'),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(n['nilai_akhir_huruf'] ?? '-',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${n['matkul_sks']} SKS  •  Nilai Akhir: ${n['nilai_akhir_angka']}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                      const Divider(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _komponenNilai('Tugas', n['nilai_tugas']),
                                          _komponenNilai('Kuis', n['nilai_kuis']),
                                          _komponenNilai('UTS', n['nilai_uts']),
                                          _komponenNilai('UAS', n['nilai_uas']),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _komponenNilai(String label, dynamic nilai) {
    return Column(
      children: [
        Text('$nilai',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF00695C))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }

  Color _nilaiColor(String huruf) {
    switch (huruf) {
      case 'A': case 'A-': return Colors.green;
      case 'B+': case 'B': case 'B-': return const Color(0xFF1565C0);
      case 'C+': case 'C': return Colors.orange;
      case 'D': return Colors.deepOrange;
      default: return Colors.red;
    }
  }
}