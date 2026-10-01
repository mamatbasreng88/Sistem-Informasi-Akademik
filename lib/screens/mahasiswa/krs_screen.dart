import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class KRSScreen extends StatefulWidget {
  const KRSScreen({super.key});

  @override
  State<KRSScreen> createState() => _KRSScreenState();
}

class _KRSScreenState extends State<KRSScreen> {
  List<dynamic> _kelasList = [];
  List<int> _selectedIds = [];
  List<int> _savedIds = [];
  int _totalSks = 0;
  int _maxSks = 24;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _statusKRS = false;
  int _semesterMahasiswa = 1;
  String _tipeSemester = 'Ganjil';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Cek status KRS dari semester aktif
    final semesterResult = await ApiService.getSemesterAktif();
    final statusKRS = semesterResult['data']?['status_krs'] == true;

    if (!statusKRS) {
      if (mounted) {
        setState(() {
          _statusKRS = false;
          _isLoading = false;
        });
      }
      return;
    }

    // Ambil KRS yang sudah tersimpan
    final krsResult    = await ApiService.getMyKRS();
    final user         = await ApiService.getUser();
    final profile      = user?['profile'];

    List<int> existingIds = [];
    if (krsResult['success'] == true && krsResult['data'] != null) {
      existingIds = (krsResult['data'] as List)
          .map((k) => k['kelas_id'] as int)
          .toList();
    }

    // Ambil kelas tersedia
    final kelasResult  = await ApiService.getKelasTersedia();
    List<dynamic> kelasList = [];
    int semesterMhs    = 1;
    String tipeSemester = 'Ganjil';

    if (kelasResult['success'] == true) {
      kelasList     = kelasResult['data'] ?? [];
      semesterMhs   = kelasResult['semester_mahasiswa'] ?? 1;
      tipeSemester  = kelasResult['tipe_semester'] ?? 'Ganjil';
    }

    // Tambahkan kelas yang sudah diambil tapi tidak ada di daftar tersedia
    if (krsResult['success'] == true && krsResult['data'] != null) {
      for (var krs in krsResult['data']) {
        final alreadyIn = kelasList.any((k) => k['id'] == krs['kelas_id']);
        if (!alreadyIn) {
          kelasList.add({
            ...krs,
            'id': krs['kelas_id'],
            'is_penuh': false,
          });
        }
      }
    }

    if (mounted) {
      setState(() {
        _statusKRS          = statusKRS;
        _kelasList          = kelasList;
        _selectedIds        = List.from(existingIds);
        _savedIds           = List.from(existingIds);
        _maxSks             = profile?['max_sks'] ?? 24;
        _semesterMahasiswa  = semesterMhs;
        _tipeSemester       = tipeSemester;
        _hitungSks();
        _isLoading          = false;
      });
    }
  }

  void _hitungSks() {
    int total = 0;
    for (var id in _selectedIds) {
      final kelas = _kelasList.where((k) => k['id'] == id).toList();
      if (kelas.isNotEmpty) {
        total += (kelas[0]['matkul_sks'] as num).toInt();
      }
    }
    _totalSks = total;
  }

  Map<String, List<dynamic>> get _groupedKelas {
    Map<String, List<dynamic>> result = {};
    for (var k in _kelasList) {
      final key = k['matkul_nama'] as String;
      result.putIfAbsent(key, () => []).add(k);
    }
    return result;
  }

  Future<void> _simpanKRS() async {
    if (_selectedIds.isEmpty) return;
    if (_totalSks > _maxSks) {
      showSnackBar(context, 'SKS melebihi batas maksimal!', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final result = await ApiService.simpanKRS(_selectedIds);
    setState(() => _isSaving = false);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() => _savedIds = List.from(_selectedIds));
      showSnackBar(
          context, 'KRS berhasil disimpan! Total ${result['total_sks']} SKS');
    } else {
      if (result['message']?.contains('ditutup') == true) {
        showSnackBar(context, 'Periode KRS telah ditutup oleh admin!',
            isError: true);
        _loadData();
      } else {
        showSnackBar(context, result['message'] ?? 'Gagal menyimpan KRS!',
            isError: true);
      }
    }
  }

  Future<void> _batalkanKRS() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan KRS',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text(
            'Apakah Anda yakin ingin membatalkan semua mata kuliah yang dipilih?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Tidak', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    final result = await ApiService.simpanKRS([]);
    setState(() => _isSaving = false);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _selectedIds.clear();
        _savedIds.clear();
        _hitungSks();
      });
      showSnackBar(context, 'Semua KRS berhasil dibatalkan!');
      _loadData();
    } else {
      showSnackBar(context, result['message'] ?? 'Gagal membatalkan KRS!',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Input KRS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat data kelas...')
          : !_statusKRS
              ? _buildKRSDitutup()
              : Column(
                  children: [
                    _buildInfoSemester(),
                    _buildSksHeader(),
                    Expanded(child: _buildMatkulList()),
                    _buildSimpanButton(),
                  ],
                ),
    );
  }

  Widget _buildInfoSemester() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _tipeSemester == 'Ganjil'
            ? const Color(0xFFF3E5F5)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _tipeSemester == 'Ganjil'
              ? Colors.purple.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.school_rounded,
              color:
                  _tipeSemester == 'Ganjil' ? Colors.purple : Colors.green,
              size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Semester $_semesterMahasiswa ($_tipeSemester) - '
              'Menampilkan matkul semester $_tipeSemester',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _tipeSemester == 'Ganjil'
                    ? Colors.purple[700]
                    : Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKRSDitutup() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0), shape: BoxShape.circle),
              child: const Icon(Icons.event_busy_rounded,
                  color: Colors.orange, size: 50),
            ),
            const SizedBox(height: 24),
            const Text('Periode KRS Ditutup',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E))),
            const SizedBox(height: 12),
            Text(
              'Periode pengisian KRS saat ini sedang ditutup. '
              'Silakan tunggu informasi pembukaan KRS dari admin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Refresh',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSksHeader() {
    final bool isOver = _totalSks > _maxSks;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SKS Dipilih',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                Text('$_totalSks SKS',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isOver
                            ? Colors.red
                            : const Color(0xFF1565C0))),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Maksimal',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[500])),
                Text('$_maxSks SKS',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E))),
              ]),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_totalSks / _maxSks).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                  isOver ? Colors.red : const Color(0xFF1565C0)),
            ),
          ),
          if (isOver) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 16),
              const SizedBox(width: 6),
              Text('SKS melebihi batas!',
                  style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildMatkulList() {
    if (_groupedKelas.isEmpty) {
      return const EmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Tidak Ada Kelas Tersedia',
        subtitle:
            'Semua kelas sudah penuh atau belum ada kelas yang dibuka',
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: _groupedKelas.entries
          .map((e) => _buildMatkulGroup(e.key, e.value))
          .toList(),
    );
  }

  Widget _buildMatkulGroup(String matkulNama, List<dynamic> kelasList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(matkulNama,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))),
                if (kelasList.isNotEmpty)
                  Text(
                      '${kelasList[0]['matkul_kode']} • ${kelasList[0]['matkul_sks']} SKS',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ...kelasList.map((k) => _buildKelasItem(k)),
        ],
      ),
    );
  }

  Widget _buildKelasItem(dynamic k) {
    final bool isPenuh   = k['is_penuh'] == true;
    final bool isSelected = _selectedIds.contains(k['id'] as int);
    final int sisa       = (k['sisa_kursi'] as num?)?.toInt() ?? 0;

    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[100]!))),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isPenuh
              ? null
              : () {
                  setState(() {
                    final matkulNama = k['matkul_nama'] as String;
                    _selectedIds.removeWhere((id) {
                      final found = _kelasList
                          .where((kl) => kl['id'] == id)
                          .toList();
                      return found.isNotEmpty &&
                          found[0]['matkul_nama'] == matkulNama;
                    });
                    if (!isSelected) _selectedIds.add(k['id'] as int);
                    _hitungSks();
                  });
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPenuh
                          ? Colors.grey[300]!
                          : isSelected
                              ? const Color(0xFF1565C0)
                              : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFF1565C0)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('Kelas ${k['nama_kelas']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isPenuh
                                    ? Colors.grey[400]
                                    : const Color(0xFF1A237E))),
                        const SizedBox(width: 8),
                        if (isPenuh)
                          CustomChip(
                              text: 'PENUH',
                              bgColor: const Color(0xFFFFEBEE),
                              textColor: Colors.red),
                      ]),
                      const SizedBox(height: 4),
                      Text(k['dosen_nama'] ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: isPenuh
                                  ? Colors.grey[400]
                                  : Colors.grey[600])),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.access_time_rounded,
                            size: 12,
                            color: isPenuh
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${k['hari']} ${k['jam']}',
                            style: TextStyle(
                                fontSize: 12,
                                color: isPenuh
                                    ? Colors.grey[400]
                                    : Colors.grey[600])),
                        const SizedBox(width: 10),
                        Icon(Icons.room_rounded,
                            size: 12,
                            color: isPenuh
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(k['ruangan'] ?? '',
                            style: TextStyle(
                                fontSize: 12,
                                color: isPenuh
                                    ? Colors.grey[400]
                                    : Colors.grey[600])),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${k['terisi']}/${k['kapasitas']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isPenuh
                                ? Colors.red
                                : Colors.green[700])),
                    Text(
                        isPenuh ? 'Penuh' : '$sisa kursi',
                        style: TextStyle(
                            fontSize: 10,
                            color: isPenuh
                                ? Colors.red[300]
                                : Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpanButton() {
    final bool canSave        = _selectedIds.isNotEmpty && _totalSks <= _maxSks;
    final bool adaKRSTersimpan = _savedIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: (canSave && !_isSaving) ? _simpanKRS : null,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_rounded, color: Colors.white),
              label: Text(
                _isSaving
                    ? 'Menyimpan...'
                    : canSave
                        ? 'SIMPAN KRS ($_totalSks SKS)'
                        : _selectedIds.isEmpty
                            ? 'Pilih mata kuliah terlebih dahulu'
                            : 'SKS melebihi batas',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          if (adaKRSTersimpan) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _batalkanKRS,
                icon: const Icon(Icons.cancel_outlined,
                    color: Colors.red, size: 18),
                label: const Text('BATALKAN SEMUA KRS',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}