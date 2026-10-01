import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class KelolaKelasScreen extends StatefulWidget {
  const KelolaKelasScreen({super.key});

  @override
  State<KelolaKelasScreen> createState() => _KelolaKelasScreenState();
}

class _KelolaKelasScreenState extends State<KelolaKelasScreen> {
  List<dynamic> _list = [];
  List<dynamic> _matkulList = [];
  List<dynamic> _dosenList = [];
  dynamic _selectedMatkul;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      ApiService.getKelasList(matkulId: _selectedMatkul?['id']),
      ApiService.getMatkulList(),
      ApiService.getDosenList(),
    ]);

    if (mounted) {
      setState(() {
        _list = results[0]['data'] ?? [];
        _matkulList = results[1]['data'] ?? [];
        _dosenList = results[2]['data'] ?? [];
        _isLoading = false;
      });
    }
  }

  void _showForm({dynamic existing}) {
    dynamic selectedMatkul = existing != null
        ? _matkulList.firstWhere((m) => m['id'] == existing['matkul_id'], orElse: () => null)
        : null;
    dynamic selectedDosen = existing != null
        ? _dosenList.firstWhere((d) => d['id'] == existing['dosen_id'], orElse: () => null)
        : null;
    final namaKelasCtrl = TextEditingController(text: existing?['nama_kelas'] ?? '');
    final kapasitasCtrl = TextEditingController(text: existing?['kapasitas']?.toString() ?? '40');
    final jamCtrl = TextEditingController(text: existing?['jam'] ?? '');
    final ruanganCtrl = TextEditingController(text: existing?['ruangan'] ?? '');
    String? selectedHari = existing?['hari'];
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;
    bool isSaving = false;
    final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text(isEdit ? 'Edit Kelas' : 'Tambah Kelas',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 20),

                  // Pilih Matkul
                  const Text('Mata Kuliah', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        value: selectedMatkul,
                        isExpanded: true,
                        hint: const Text('Pilih Mata Kuliah'),
                        items: _matkulList.map((mk) => DropdownMenuItem<dynamic>(value: mk, child: Text(mk['nama']))).toList(),
                        onChanged: (val) => setModal(() => selectedMatkul = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pilih Dosen
                  const Text('Dosen Pengampu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        value: selectedDosen,
                        isExpanded: true,
                        hint: const Text('Pilih Dosen'),
                        items: _dosenList.map((d) => DropdownMenuItem<dynamic>(value: d, child: Text(d['nama']))).toList(),
                        onChanged: (val) => setModal(() => selectedDosen = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(children: [
                    Expanded(child: buildInputField(controller: namaKelasCtrl, label: 'Kelas (A/B/C)', icon: Icons.label_rounded,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: buildInputField(controller: kapasitasCtrl, label: 'Kapasitas', icon: Icons.people_rounded,
                        isNumber: true, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                  ]),
                  const SizedBox(height: 12),

                  // Pilih Hari
                  const Text('Hari', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedHari,
                        isExpanded: true,
                        hint: const Text('Pilih Hari'),
                        items: hariList.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                        onChanged: (val) => setModal(() => selectedHari = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(children: [
                    Expanded(child: buildInputField(controller: jamCtrl, label: 'Jam (08.00-10.30)', icon: Icons.access_time_rounded,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: buildInputField(controller: ruanganCtrl, label: 'Ruangan', icon: Icons.room_rounded,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                  ]),
                  const SizedBox(height: 24),

                  SizedBox(width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        if (!formKey.currentState!.validate()) return;
                        if (selectedMatkul == null || selectedDosen == null || selectedHari == null) {
                          showSnackBar(context, 'Pilih matkul, dosen, dan hari!', isError: true);
                          return;
                        }
                        setModal(() => isSaving = true);
                        final data = {
                          'matkul_id': selectedMatkul['id'],
                          'dosen_id': selectedDosen['id'],
                          'nama_kelas': namaKelasCtrl.text.toUpperCase(),
                          'kapasitas': int.tryParse(kapasitasCtrl.text) ?? 40,
                          'hari': selectedHari,
                          'jam': jamCtrl.text,
                          'ruangan': ruanganCtrl.text,
                        };
                        final result = isEdit
                            ? await ApiService.updateKelas(existing['id'], data)
                            : await ApiService.createKelas(data);
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        if (result['success'] == true) {
                          showSnackBar(context, isEdit ? 'Kelas berhasil diperbarui!' : 'Kelas berhasil ditambahkan!');
                          _loadData();
                        } else {
                          showSnackBar(context, result['message'] ?? 'Gagal!', isError: true);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: Text(isSaving ? 'Menyimpan...' : isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH KELAS',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(title: const Text('Kelola Kelas'),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context))),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE65100),
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Kelas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter matkul
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))]),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                value: _selectedMatkul,
                isExpanded: true,
                hint: const Text('Filter: Semua Mata Kuliah'),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE65100)),
                style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w600, fontSize: 14),
                items: [
                  const DropdownMenuItem<dynamic>(value: null, child: Text('Semua Mata Kuliah')),
                  ..._matkulList.map((mk) => DropdownMenuItem<dynamic>(value: mk, child: Text(mk['nama']))),
                ],
                onChanged: (val) { setState(() => _selectedMatkul = val); _loadData(); },
              ),
            ),
          ),

          Expanded(
            child: _isLoading ? const LoadingWidget(message: 'Memuat kelas...')
                : _list.isEmpty ? const EmptyState(icon: Icons.class_outlined, title: 'Belum Ada Kelas', subtitle: 'Tambah kelas dengan tombol di bawah')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _list.length,
                    itemBuilder: (ctx, i) {
                      final k = _list[i];
                      final isPenuh = k['is_penuh'] == true;
                      final pct = ((k['terisi'] as num) / (k['kapasitas'] as num)).clamp(0.0, 1.0);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isPenuh ? Border.all(color: Colors.red.withOpacity(0.3)) : null,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: 44, height: 44,
                                      decoration: BoxDecoration(
                                          color: isPenuh ? const Color(0xFFFFEBEE) : const Color(0xFFFBE9E7),
                                          borderRadius: BorderRadius.circular(12)),
                                      child: Center(child: Text(k['nama_kelas'],
                                          style: TextStyle(color: isPenuh ? Colors.red : const Color(0xFFE65100),
                                              fontWeight: FontWeight.bold, fontSize: 18)))),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(k['matkul_nama'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A237E))),
                                    const SizedBox(height: 3),
                                    Text(k['dosen_nama'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500]), overflow: TextOverflow.ellipsis),
                                  ])),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: Color(0xFFE65100)), SizedBox(width: 10), Text('Edit')])),
                                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: Colors.red), SizedBox(width: 10), Text('Hapus', style: TextStyle(color: Colors.red))])),
                                    ],
                                    onSelected: (val) async {
                                      if (val == 'edit') {
                                        _showForm(existing: k);
                                      } else {
                                        final result = await ApiService.deleteKelas(k['id']);
                                        if (!mounted) return;
                                        if (result['success'] == true) {
                                          showSnackBar(context, 'Kelas berhasil dihapus!');
                                          _loadData();
                                        } else {
                                          showSnackBar(context, result['message'] ?? 'Gagal!', isError: true);
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(children: [
                                const Icon(Icons.access_time_rounded, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('${k['hari']} | ${k['jam']}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                const SizedBox(width: 10),
                                const Icon(Icons.room_rounded, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(k['ruangan'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              ]),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${k['terisi']}/${k['kapasitas']} Mahasiswa',
                                      style: TextStyle(fontSize: 12, color: isPenuh ? Colors.red : Colors.grey[600], fontWeight: FontWeight.w500)),
                                  if (isPenuh) CustomChip(text: 'PENUH', bgColor: const Color(0xFFFFEBEE), textColor: Colors.red),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct.toDouble(),
                                  minHeight: 6,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(isPenuh ? Colors.red : const Color(0xFFE65100)),
                                ),
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