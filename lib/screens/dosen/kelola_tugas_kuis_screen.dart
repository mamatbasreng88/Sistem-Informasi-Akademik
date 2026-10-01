import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

double _num(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

// ===================== LIST TUGAS / KUIS PER KELAS =====================
// jenis: 'tugas' atau 'kuis'
class KelolaTugasKuisScreen extends StatefulWidget {
  final int kelasId;
  final String matkulNama;
  final String namaKelas;
  final String jenis;

  const KelolaTugasKuisScreen({
    super.key,
    required this.kelasId,
    required this.matkulNama,
    required this.namaKelas,
    required this.jenis,
  });

  @override
  State<KelolaTugasKuisScreen> createState() => _KelolaTugasKuisScreenState();
}

class _KelolaTugasKuisScreenState extends State<KelolaTugasKuisScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  String get _label => widget.jenis == 'tugas' ? 'Tugas' : 'Kuis';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getTugasKuis(widget.kelasId, widget.jenis);
    if (mounted) {
      setState(() {
        _items = result['success'] == true ? (result['data'] ?? []) : [];
        _isLoading = false;
      });
    }
  }

  void _snack(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showTambahDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tambah $_label Baru',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 255,
          decoration: InputDecoration(
            labelText: 'Keterangan',
            hintText: widget.jenis == 'tugas'
                ? 'Contoh: Membuat ERD Sistem'
                : 'Contoh: Konsep OOP',
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final ket = ctrl.text.trim();
              if (ket.isEmpty) {
                _snack('Keterangan tidak boleh kosong!', false);
                return;
              }
              Navigator.pop(ctx);
              final result = await ApiService.createTugasKuis(
                  widget.kelasId, widget.jenis, ket);
              if (!mounted) return;
              _snack(result['message'] ?? '', result['success'] == true);
              if (result['success'] == true) _load();
            },
            child: const Text('Simpan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus $_label?',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            '$_label ke-${item['urutan']} (${item['keterangan']}) beserta seluruh nilainya akan dihapus, dan rata-rata nilai mahasiswa dihitung ulang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final result =
                  await ApiService.deleteTugasKuis(item['id'], widget.jenis);
              if (!mounted) return;
              _snack(result['message'] ?? '', result['success'] == true);
              if (result['success'] == true) _load();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kelola $_label',
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            Text('${widget.matkulNama} • Kelas ${widget.namaKelas}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1565C0),
        onPressed: _showTambahDialog,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Tambah $_label',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? LoadingWidget(message: 'Memuat $_label...')
          : _items.isEmpty
              ? EmptyState(
                  icon: Icons.assignment_rounded,
                  title: 'Belum Ada $_label',
                  subtitle: 'Tekan tombol Tambah untuk membuat $_label pertama',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) {
                    final item = Map<String, dynamic>.from(_items[i]);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8, offset: const Offset(0, 2),
                        )],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('${item['urutan']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1565C0))),
                          ),
                        ),
                        title: Text('$_label ke-${item['urutan']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A237E))),
                        subtitle: Text(item['keterangan'] ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Color(0xFFD32F2F)),
                          onPressed: () => _konfirmasiHapus(item),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _InputNilaiTugasKuisScreen(
                              id: item['id'],
                              jenis: widget.jenis,
                              judul: '$_label ke-${item['urutan']}',
                              keterangan: item['keterangan'] ?? '',
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

// ===================== INPUT NILAI 1 TUGAS / 1 KUIS UNTUK SEMUA MAHASISWA =====================
class _InputNilaiTugasKuisScreen extends StatefulWidget {
  final int id;
  final String jenis;
  final String judul;
  final String keterangan;

  const _InputNilaiTugasKuisScreen({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.keterangan,
  });

  @override
  State<_InputNilaiTugasKuisScreen> createState() =>
      _InputNilaiTugasKuisScreenState();
}

class _InputNilaiTugasKuisScreenState
    extends State<_InputNilaiTugasKuisScreen> {
  List<dynamic> _mahasiswa = [];
  final Map<int, TextEditingController> _ctrls = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getNilaiTugasKuis(widget.id, widget.jenis);
    if (!mounted) return;
    final list = result['success'] == true ? (result['data'] ?? []) : [];
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _ctrls.clear();
    for (final m in list) {
      final mid = m['mahasiswa_id'] as int;
      final n = m['nilai'];
      _ctrls[mid] = TextEditingController(
          text: n == null ? '' : _num(n).toStringAsFixed(0));
    }
    setState(() {
      _mahasiswa = list;
      _isLoading = false;
    });
  }

  Future<void> _simpan() async {
    final payload = <Map<String, dynamic>>[];
    for (final m in _mahasiswa) {
      final mid = m['mahasiswa_id'] as int;
      final txt = _ctrls[mid]?.text.trim() ?? '';
      if (txt.isEmpty) continue;
      final v = double.tryParse(txt.replaceAll(',', '.'));
      if (v == null || v < 0 || v > 100) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Nilai ${m['nama']} harus angka 0–100!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
      payload.add({'mahasiswa_id': mid, 'nilai': v});
    }

    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Belum ada nilai yang diisi!'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isSaving = true);
    final result =
        await ApiService.simpanNilaiTugasKuis(widget.id, widget.jenis, payload);
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result['message'] ?? ''),
      backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    if (result['success'] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.judul,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            Text(widget.keterangan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat daftar mahasiswa...')
          : _mahasiswa.isEmpty
              ? const EmptyState(
                  icon: Icons.people_rounded,
                  title: 'Belum Ada Mahasiswa',
                  subtitle: 'Belum ada mahasiswa yang mendaftar kelas ini',
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _mahasiswa.length,
                        itemBuilder: (ctx, i) {
                          final m = _mahasiswa[i];
                          final mid = m['mahasiswa_id'] as int;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8, offset: const Offset(0, 2),
                              )],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m['nama'] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF1A237E))),
                                      Text('NIM: ${m['nim'] ?? ''}',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey[500])),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: TextField(
                                    controller: _ctrls[mid],
                                    textAlign: TextAlign.center,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      hintText: '0–100',
                                      isDense: true,
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFF),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF1565C0), width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isSaving ? null : _simpan,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Simpan Semua Nilai',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}