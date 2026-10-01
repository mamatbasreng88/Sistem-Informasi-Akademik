import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class KelolaPembayaranScreen extends StatefulWidget {
  const KelolaPembayaranScreen({super.key});

  @override
  State<KelolaPembayaranScreen> createState() => _KelolaPembayaranScreenState();
}

class _KelolaPembayaranScreenState extends State<KelolaPembayaranScreen> {
  List<dynamic> _data = [];
  String _semesterAktif = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getPembayaranList();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _data = result['data'] ?? [];
          _semesterAktif = result['semester_aktif'] ?? '';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _toggle(int mahasiswaId, int index) async {
    setState(() {
      _data[index]['status'] = !_data[index]['status'];
    });

    final result = await ApiService.togglePembayaran(mahasiswaId);

    if (!result['success']) {
      setState(() {
        _data[index]['status'] = !_data[index]['status'];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal mengubah status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Kelola Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat data pembayaran...')
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: Color(0xFF1565C0), size: 18),
                        const SizedBox(width: 10),
                        Text('Semester Aktif: $_semesterAktif',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _data.isEmpty
                        ? const EmptyState(
                            icon: Icons.payments_rounded,
                            title: 'Belum Ada Data Mahasiswa',
                            subtitle: 'Data mahasiswa belum tersedia',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _data.length,
                            itemBuilder: (ctx, i) {
                              final item = _data[i];
                              final bool sudahBayar = item['status'] == true;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['nama'] ?? '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1A237E))),
                                          const SizedBox(height: 2),
                                          Text('NIM: ${item['nim'] ?? '-'}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500])),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          sudahBayar ? 'Sudah Bayar' : 'Belum Bayar',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: sudahBayar
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        Switch(
                                          value: sudahBayar,
                                          activeColor: Colors.green,
                                          onChanged: (_) =>
                                              _toggle(item['mahasiswa_id'], i),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}