import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class DaftarMahasiswaScreen extends StatefulWidget {
  const DaftarMahasiswaScreen({super.key});

  @override
  State<DaftarMahasiswaScreen> createState() =>
      _DaftarMahasiswaScreenState();
}

class _DaftarMahasiswaScreenState extends State<DaftarMahasiswaScreen> {
  List<dynamic> _kelasList = [];
  List<dynamic> _mahasiswaList = [];
  dynamic _selectedKelas;
  bool _isLoadingKelas = true;
  bool _isLoadingMhs = false;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    setState(() => _isLoadingKelas = true);
    final result = await ApiService.getKelasDosen();
    if (mounted) {
      final kelas = result['data'] ?? [];
      setState(() {
        _kelasList = kelas;
        _isLoadingKelas = false;
      });
      if (kelas.isNotEmpty) {
        _selectedKelas = kelas[0];
        _loadMahasiswa(kelas[0]['id']);
      }
    }
  }

  Future<void> _loadMahasiswa(int kelasId) async {
    setState(() => _isLoadingMhs = true);
    final result = await ApiService.getMahasiswaInKelas(kelasId);
    if (mounted) {
      setState(() {
        _mahasiswaList = result['data'] ?? [];
        _isLoadingMhs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Daftar Mahasiswa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingKelas
          ? const LoadingWidget(message: 'Memuat kelas...')
          : Column(
              children: [
                _buildKelasSelector(),
                if (_selectedKelas != null) _buildKelasInfo(),
                const SizedBox(height: 4),
                Expanded(
                  child: _isLoadingMhs
                      ? const LoadingWidget(message: 'Memuat mahasiswa...')
                      : _mahasiswaList.isEmpty
                          ? const EmptyState(
                              icon: Icons.people_outline_rounded,
                              title: 'Belum Ada Mahasiswa',
                              subtitle:
                                  'Belum ada mahasiswa yang mengambil kelas ini',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              itemCount: _mahasiswaList.length,
                              itemBuilder: (ctx, i) =>
                                  _buildMhsCard(_mahasiswaList[i], i + 1),
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildKelasSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: _selectedKelas,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF1565C0)),
          style: const TextStyle(
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w600,
              fontSize: 14),
          items: _kelasList.map((k) {
            return DropdownMenuItem<dynamic>(
              value: k,
              child: Text('${k['matkul_nama']} - Kelas ${k['nama_kelas']}'),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedKelas = val);
            if (val != null) _loadMahasiswa(val['id']);
          },
        ),
      ),
    );
  }

  Widget _buildKelasInfo() {
    final k = _selectedKelas;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${k['matkul_nama']} - Kelas ${k['nama_kelas']}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text('${k['hari']} | ${k['jam']}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 10),
                    const Icon(Icons.room_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(k['ruangan'] ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('${_mahasiswaList.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22)),
                const Text('Mahasiswa',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMhsCard(dynamic mhs, int no) {
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
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
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
        title: Text(mhs['nama'] ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1A237E))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text('NIM: ${mhs['nim']}',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 3),
            CustomChip(
              text: 'IPK ${mhs['ipk']}',
              bgColor: const Color(0xFFE8F5E9),
              textColor: Colors.green[700]!,
            ),
          ],
        ),
      ),
    );
  }
}