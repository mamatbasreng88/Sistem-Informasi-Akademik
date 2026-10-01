import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class InputAbsensiScreen extends StatefulWidget {
  const InputAbsensiScreen({super.key});

  @override
  State<InputAbsensiScreen> createState() => _InputAbsensiScreenState();
}

class _InputAbsensiScreenState extends State<InputAbsensiScreen> {
  List<dynamic> _kelasList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getKelasDosen();
    if (mounted) {
      setState(() {
        _kelasList = result['success'] == true ? result['data'] ?? [] : [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(title: const Text('Input Kehadiran')),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat kelas...')
          : _kelasList.isEmpty
              ? const EmptyState(
                  icon: Icons.class_rounded,
                  title: 'Belum Ada Kelas',
                  subtitle: 'Anda belum mengampu kelas apapun',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _kelasList.length,
                  itemBuilder: (ctx, i) {
                    final k = _kelasList[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1565C0).withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event_available_rounded,
                              color: Color(0xFF00838F), size: 24),
                        ),
                        title: Text(k['matkul_nama'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E))),
                        subtitle: Text(
                            '${k['kode'] ?? ''} • Kelas ${k['nama_kelas'] ?? ''}',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF1565C0), size: 14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _InputAbsensiDetailScreen(
                              kelasId: k['id'],
                              matkulNama: k['matkul_nama'] ?? '',
                              namaKelas: k['nama_kelas'] ?? '',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ===================== DETAIL SCREEN — INPUT ABSENSI PER PERTEMUAN =====================
class _InputAbsensiDetailScreen extends StatefulWidget {
  final int kelasId;
  final String matkulNama;
  final String namaKelas;

  const _InputAbsensiDetailScreen({
    required this.kelasId,
    required this.matkulNama,
    required this.namaKelas,
  });

  @override
  State<_InputAbsensiDetailScreen> createState() =>
      _InputAbsensiDetailScreenState();
}

class _InputAbsensiDetailScreenState
    extends State<_InputAbsensiDetailScreen> {
  int _pertemuanKe = 1;
  DateTime _tanggal = DateTime.now();
  List<dynamic> _roster = [];
  bool _isLoading = true;
  bool _isSaving = false;

  static const _statusOptions = ['hadir', 'izin', 'sakit', 'alpha'];
  static const _statusLabel = {
    'hadir': 'Hadir',
    'izin': 'Izin',
    'sakit': 'Sakit',
    'alpha': 'Alpha',
  };
  static const _statusColor = {
    'hadir': Colors.green,
    'izin': Color(0xFF1565C0),
    'sakit': Colors.orange,
    'alpha': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _loadRoster();
  }

  Future<void> _loadRoster() async {
    setState(() => _isLoading = true);
    final result =
        await ApiService.getRosterAbsensi(widget.kelasId, _pertemuanKe);
    if (mounted) {
      setState(() {
        _roster = result['success'] == true
            ? List<dynamic>.from(result['data'] ?? [])
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : [];
        _isLoading = false;
      });
    }
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime.now().subtract(const Duration(days: 180)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  void _setStatus(int index, String status) {
    setState(() => _roster[index]['status'] = status);
  }

  Future<void> _simpan() async {
    setState(() => _isSaving = true);

    final tanggalStr =
        '${_tanggal.year.toString().padLeft(4, '0')}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}';

    final kehadiran = _roster
        .map((m) => {
              'mahasiswa_id': m['mahasiswa_id'],
              'status': m['status'],
            })
        .toList();

    final result = await ApiService.simpanAbsensi(
      kelasId: widget.kelasId,
      tanggalPertemuan: tanggalStr,
      pertemuanKe: _pertemuanKe,
      kehadiran: kehadiran,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? ''),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.matkulNama,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            Text('Kelas ${widget.namaKelas}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ===== Selector pertemuan & tanggal =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _pertemuanKe,
                    decoration: InputDecoration(
                      labelText: 'Pertemuan ke-',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: List.generate(16, (i) => i + 1)
                        .map((p) => DropdownMenuItem(
                            value: p, child: Text('Pertemuan $p')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _pertemuanKe = val);
                        _loadRoster();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: _pickTanggal,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Tanggal',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFF),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        '${_tanggal.day.toString().padLeft(2, '0')}/${_tanggal.month.toString().padLeft(2, '0')}/${_tanggal.year}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ===== Roster mahasiswa =====
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Memuat mahasiswa...')
                : _roster.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_rounded,
                        title: 'Belum Ada Mahasiswa',
                        subtitle:
                            'Belum ada mahasiswa yang mendaftar kelas ini',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _roster.length,
                        itemBuilder: (ctx, i) {
                          final mhs = _roster[i];
                          final status = mhs['status'] ?? 'hadir';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1565C0),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text('${i + 1}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(mhs['nama'] ?? '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: Color(0xFF1A237E))),
                                          Text('NIM: ${mhs['nim'] ?? ''}',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[500])),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  children: _statusOptions.map((s) {
                                    final selected = status == s;
                                    return ChoiceChip(
                                      label: Text(_statusLabel[s]!),
                                      selected: selected,
                                      selectedColor: _statusColor[s],
                                      backgroundColor: const Color(0xFFF0F4FF),
                                      labelStyle: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                      onSelected: (_) => _setStatus(i, s),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          // ===== Tombol simpan =====
          if (!_isLoading && _roster.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _simpan,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Kehadiran',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}