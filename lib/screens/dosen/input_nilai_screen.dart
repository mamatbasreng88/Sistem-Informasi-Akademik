import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';
import 'kelola_tugas_kuis_screen.dart';

double _num(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

class InputNilaiScreen extends StatefulWidget {
  const InputNilaiScreen({super.key});

  @override
  State<InputNilaiScreen> createState() => _InputNilaiScreenState();
}

class _InputNilaiScreenState extends State<InputNilaiScreen> {
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
      appBar: AppBar(title: const Text('Input Nilai')),
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
                        boxShadow: [BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.06),
                          blurRadius: 10, offset: const Offset(0, 3),
                        )],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.class_rounded,
                              color: Color(0xFF1565C0), size: 24),
                        ),
                        title: Text(k['matkul_nama'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E))),
                        subtitle: Text(
                            '${k['matkul_kode'] ?? ''} • Kelas ${k['nama_kelas'] ?? ''}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF1565C0), size: 14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _InputNilaiDetailScreen(
                              kelasId: k['id'],
                              matkulNama: k['matkul_nama'] ?? '',
                              namaKelas: k['nama_kelas'] ?? '',
                            ),
                          ),
                        ).then((_) => _loadKelas()),
                      ),
                    );
                  },
                ),
    );
  }
}

// ===================== DETAIL SCREEN — NILAI PER MAHASISWA =====================
class _InputNilaiDetailScreen extends StatefulWidget {
  final int kelasId;
  final String matkulNama;
  final String namaKelas;

  const _InputNilaiDetailScreen({
    required this.kelasId,
    required this.matkulNama,
    required this.namaKelas,
  });

  @override
  State<_InputNilaiDetailScreen> createState() => _InputNilaiDetailScreenState();
}

class _InputNilaiDetailScreenState extends State<_InputNilaiDetailScreen> {
  List<dynamic> _mahasiswaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getNilaiByKelas(widget.kelasId);
    if (mounted) {
      setState(() {
        _mahasiswaList = result['success'] == true ? result['data'] ?? [] : [];
        _isLoading = false;
      });
    }
  }

  void _bukaKelola(String jenis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KelolaTugasKuisScreen(
          kelasId: widget.kelasId,
          matkulNama: widget.matkulNama,
          namaKelas: widget.namaKelas,
          jenis: jenis,
        ),
      ),
    ).then((_) => _loadData());
  }

  // Dialog: rata-rata Tugas & Kuis hanya ditampilkan (otomatis), dosen mengisi UTS & UAS
  void _openInputDialog(Map<String, dynamic> mhs) {
    final rataTugas = _num(mhs['nilai_tugas']);
    final rataKuis = _num(mhs['nilai_kuis']);
    final uts = _num(mhs['nilai_uts']);
    final uas = _num(mhs['nilai_uas']);

    final utsCtrl = TextEditingController(text: uts == 0 ? '' : uts.toStringAsFixed(0));
    final uasCtrl = TextEditingController(text: uas == 0 ? '' : uas.toStringAsFixed(0));

    final previewNotifier = ValueNotifier<String>('—');

    void updatePreview() {
      final u = double.tryParse(utsCtrl.text) ?? 0;
      final a = double.tryParse(uasCtrl.text) ?? 0;
      final hasil = (rataTugas * 0.20) + (rataKuis * 0.10) + (u * 0.30) + (a * 0.40);
      previewNotifier.value = hasil.toStringAsFixed(2);
    }

    utsCtrl.addListener(updatePreview);
    uasCtrl.addListener(updatePreview);
    updatePreview();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mhs['nama'] ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E), fontSize: 16)),
            Text('NIM: ${mhs['nim'] ?? ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rata-rata Tugas (20%)',
                            style: TextStyle(fontSize: 12)),
                        Text(rataTugas.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rata-rata Kuis (10%)',
                            style: TextStyle(fontSize: 12)),
                        Text(rataKuis.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dihitung otomatis dari nilai Tugas/Kuis yang diinput lewat tombol Kelola Tugas/Kuis',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _nilaiField(utsCtrl, 'Nilai UTS (30%)', '0–100'),
              const SizedBox(height: 10),
              _nilaiField(uasCtrl, 'Nilai UAS (40%)', '0–100'),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: previewNotifier,
                builder: (_, val, __) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Nilai Akhir (Preview)',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(val,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const Text('(Tugas×20% + Kuis×10% + UTS×30% + UAS×40%)',
                          style: TextStyle(color: Colors.white60, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
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
              final u = double.tryParse(utsCtrl.text);
              final a = double.tryParse(uasCtrl.text);

              if (u == null || a == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nilai UTS dan UAS harus diisi!')),
                );
                return;
              }

              Navigator.pop(ctx);

              final result = await ApiService.inputKomponenNilai(
                mahasiswaId: mhs['mahasiswa_id'],
                kelasId: widget.kelasId,
                nilaiUts: u,
                nilaiUas: a,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result['message'] ?? ''),
                  backgroundColor:
                      result['success'] == true ? Colors.green : Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ));
                if (result['success'] == true) _loadData();
              }
            },
            child: const Text('Simpan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _nilaiField(TextEditingController ctrl, String label, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
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
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat data mahasiswa...')
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _BobotChipWhite(label: 'Tugas', bobot: '20%'),
                      _BobotChipWhite(label: 'Kuis', bobot: '10%'),
                      _BobotChipWhite(label: 'UTS', bobot: '30%'),
                      _BobotChipWhite(label: 'UAS', bobot: '40%'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _bukaKelola('tugas'),
                          icon: const Icon(Icons.assignment_rounded, size: 18),
                          label: const Text('Kelola Tugas'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1565C0),
                            side: const BorderSide(color: Color(0xFF1565C0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _bukaKelola('kuis'),
                          icon: const Icon(Icons.quiz_rounded, size: 18),
                          label: const Text('Kelola Kuis'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1565C0),
                            side: const BorderSide(color: Color(0xFF1565C0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _mahasiswaList.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_rounded,
                          title: 'Belum Ada Mahasiswa',
                          subtitle: 'Belum ada mahasiswa yang mendaftar kelas ini',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _mahasiswaList.length,
                          itemBuilder: (ctx, i) {
                            final mhs = _mahasiswaList[i];
                            final huruf = mhs['nilai_akhir_huruf'] ?? '-';
                            final sudahLengkap = huruf != '-' && huruf != null;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: sudahLengkap
                                    ? Border.all(
                                        color: Colors.green.withOpacity(0.3))
                                    : null,
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
                                    color: sudahLengkap
                                        ? Colors.green.withOpacity(0.1)
                                        : const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    sudahLengkap
                                        ? Icons.check_circle_rounded
                                        : Icons.person_rounded,
                                    color: sudahLengkap
                                        ? Colors.green
                                        : const Color(0xFF1565C0),
                                    size: 22,
                                  ),
                                ),
                                title: Text(mhs['nama'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF1A237E))),
                                subtitle: Text(
                                    'NIM ${mhs['nim']}\nTugas(rata²):${_num(mhs['nilai_tugas']).toStringAsFixed(1)}  Kuis(rata²):${_num(mhs['nilai_kuis']).toStringAsFixed(1)}  UTS:${_num(mhs['nilai_uts']).toStringAsFixed(0)}  UAS:${_num(mhs['nilai_uas']).toStringAsFixed(0)}',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[500])),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (sudahLengkap)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _nilaiColor(huruf),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(huruf,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        sudahLengkap
                                            ? Icons.edit_rounded
                                            : Icons.add_circle_rounded,
                                        color: const Color(0xFF1565C0),
                                      ),
                                      onPressed: () => _openInputDialog(
                                          Map<String, dynamic>.from(mhs)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _BobotChipWhite extends StatelessWidget {
  final String label;
  final String bobot;
  const _BobotChipWhite({required this.label, required this.bobot});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(bobot,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}