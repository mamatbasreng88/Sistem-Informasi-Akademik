import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class KelolaMatkulScreen extends StatefulWidget {
  const KelolaMatkulScreen({super.key});

  @override
  State<KelolaMatkulScreen> createState() => _KelolaMatkulScreenState();
}

class _KelolaMatkulScreenState extends State<KelolaMatkulScreen> {
  List<dynamic> _list = [];
  List<dynamic> _dosenList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      ApiService.getMatkulList(search: _searchQuery),
      ApiService.getDosenList(),
    ]);
    if (mounted) {
      setState(() {
        _list = results[0]['data'] ?? [];
        _dosenList = results[1]['data'] ?? [];
        _isLoading = false;
      });
    }
  }

  // ==================== FORM TAMBAH/EDIT MATKUL ====================
  void _showFormMatkul({dynamic existing}) {
    final kodeCtrl =
        TextEditingController(text: existing?['kode'] ?? '');
    final namaCtrl =
        TextEditingController(text: existing?['nama'] ?? '');
    final sksCtrl = TextEditingController(
        text: existing?['sks']?.toString() ?? '');
    final semCtrl = TextEditingController(
        text: existing?['semester']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(13)),
                      child: Icon(
                          isEdit
                              ? Icons.edit_rounded
                              : Icons.menu_book_rounded,
                          color: const Color(0xFF00695C)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEdit ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                buildInputField(
                    controller: kodeCtrl,
                    label: 'Kode Mata Kuliah (contoh: TI601)',
                    icon: Icons.code_rounded,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                buildInputField(
                    controller: namaCtrl,
                    label: 'Nama Mata Kuliah',
                    icon: Icons.menu_book_rounded,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: buildInputField(
                          controller: sksCtrl,
                          label: 'SKS',
                          icon: Icons.numbers_rounded,
                          isNumber: true,
                          validator: (v) =>
                              v!.isEmpty ? 'Wajib diisi' : null),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildInputField(
                          controller: semCtrl,
                          label: 'Semester',
                          icon: Icons.calendar_today_rounded,
                          isNumber: true,
                          validator: (v) =>
                              v!.isEmpty ? 'Wajib diisi' : null),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModal(() => isSaving = true);
                            final data = {
                              'kode': kodeCtrl.text,
                              'nama': namaCtrl.text,
                              'sks': int.tryParse(sksCtrl.text),
                              'semester': int.tryParse(semCtrl.text),
                            };
                            final result = isEdit
                                ? await ApiService.updateMatkul(
                                    existing['id'], data)
                                : await ApiService.createMatkul(data);
                            if (!mounted) return;
                            Navigator.pop(ctx);
                            if (result['success'] == true) {
                              showSnackBar(
                                  context,
                                  isEdit
                                      ? 'Mata kuliah berhasil diperbarui!'
                                      : 'Matkul ditambahkan! Sekarang tambah kelas.');
                              _loadData();
                            } else {
                              showSnackBar(context,
                                  result['message'] ?? 'Gagal!',
                                  isError: true);
                            }
                          },
                    icon: Icon(
                        isEdit ? Icons.save_rounded : Icons.add_rounded,
                        color: Colors.white),
                    label: Text(
                        isSaving
                            ? 'Menyimpan...'
                            : isEdit
                                ? 'SIMPAN PERUBAHAN'
                                : 'TAMBAH MATA KULIAH',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== FORM TAMBAH KELAS ====================
  void _showFormKelas(dynamic matkul) {
    dynamic selectedDosen;
    String? selectedNamaKelas;
    String? selectedHari;
    final kapasitasCtrl = TextEditingController(text: '40');
    final jamCtrl = TextEditingController();
    final ruanganCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final kelasOptions = ['A', 'B', 'C', 'D', 'E', 'F'];

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
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFBE9E7),
                            borderRadius: BorderRadius.circular(13)),
                        child: const Icon(Icons.class_rounded,
                            color: Color(0xFFE65100)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tambah Kelas',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A237E))),
                            Text(matkul['nama'],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pilih Nama Kelas
                  const Text('Nama Kelas',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedNamaKelas,
                        isExpanded: true,
                        hint: const Text('Pilih Kelas (A, B, C...)'),
                        items: kelasOptions
                            .map((k) => DropdownMenuItem(
                                value: k, child: Text('Kelas $k')))
                            .toList(),
                        onChanged: (val) =>
                            setModal(() => selectedNamaKelas = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pilih Dosen
                  const Text('Dosen Pengampu',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        value: selectedDosen,
                        isExpanded: true,
                        hint: const Text('Pilih Dosen Pengampu'),
                        items: _dosenList
                            .map((d) => DropdownMenuItem<dynamic>(
                                value: d,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(d['nama'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                    Text('NIDN: ${d['nidn']}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500])),
                                  ],
                                )))
                            .toList(),
                        onChanged: (val) =>
                            setModal(() => selectedDosen = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  buildInputField(
                      controller: kapasitasCtrl,
                      label: 'Kapasitas Mahasiswa',
                      icon: Icons.people_rounded,
                      isNumber: true,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),

                  // Pilih Hari
                  const Text('Hari Kuliah',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedHari,
                        isExpanded: true,
                        hint: const Text('Pilih Hari'),
                        items: hariList
                            .map((h) =>
                                DropdownMenuItem(value: h, child: Text(h)))
                            .toList(),
                        onChanged: (val) =>
                            setModal(() => selectedHari = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: buildInputField(
                            controller: jamCtrl,
                            label: 'Jam (08.00-10.30)',
                            icon: Icons.access_time_rounded,
                            validator: (v) =>
                                v!.isEmpty ? 'Wajib diisi' : null),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildInputField(
                            controller: ruanganCtrl,
                            label: 'Ruangan',
                            icon: Icons.room_rounded,
                            validator: (v) =>
                                v!.isEmpty ? 'Wajib diisi' : null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              if (selectedNamaKelas == null) {
                                showSnackBar(context, 'Pilih nama kelas!',
                                    isError: true);
                                return;
                              }
                              if (selectedDosen == null) {
                                showSnackBar(
                                    context, 'Pilih dosen pengampu!',
                                    isError: true);
                                return;
                              }
                              if (selectedHari == null) {
                                showSnackBar(context, 'Pilih hari kuliah!',
                                    isError: true);
                                return;
                              }
                              setModal(() => isSaving = true);
                              final data = {
                                'matkul_id': matkul['id'],
                                'dosen_id': selectedDosen['id'],
                                'nama_kelas': selectedNamaKelas,
                                'kapasitas':
                                    int.tryParse(kapasitasCtrl.text) ?? 40,
                                'hari': selectedHari,
                                'jam': jamCtrl.text,
                                'ruangan': ruanganCtrl.text,
                              };
                              final result =
                                  await ApiService.createKelas(data);
                              if (!mounted) return;
                              Navigator.pop(ctx);
                              if (result['success'] == true) {
                                showSnackBar(context,
                                    'Kelas $selectedNamaKelas berhasil ditambahkan!');
                                _loadData();
                              } else {
                                showSnackBar(context,
                                    result['message'] ?? 'Gagal!',
                                    isError: true);
                              }
                            },
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: Text(isSaving ? 'Menyimpan...' : 'TAMBAH KELAS',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
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

  // ==================== DETAIL MATKUL & LIST KELAS ====================
  void _showDetailMatkul(dynamic matkul) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(matkul['nama'],
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E))),
                          const SizedBox(height: 6),
                          Row(children: [
                            CustomChip(
                                text: matkul['kode'],
                                bgColor: const Color(0xFFE0F2F1),
                                textColor: const Color(0xFF00695C)),
                            const SizedBox(width: 6),
                            CustomChip(
                                text: '${matkul['sks']} SKS',
                                bgColor: const Color(0xFFE3F2FD),
                                textColor: const Color(0xFF1565C0)),
                            const SizedBox(width: 6),
                            CustomChip(
                                text: 'Sem ${matkul['semester']}',
                                bgColor: const Color(0xFFFFF3E0),
                                textColor: Colors.orange[700]!),
                          ]),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showFormKelas(matkul);
                      },
                      icon: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                      label: const Text('+ Kelas',
                          style:
                              TextStyle(color: Colors.white, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Daftar Kelas',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1A237E))),
                ),
              ),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future:
                      ApiService.getKelasList(matkulId: matkul['id']),
                  builder: (ctx, snap) {
                    if (!snap.hasData) {
                      return const LoadingWidget(
                          message: 'Memuat kelas...');
                    }
                    final kelas = snap.data!['data'] as List? ?? [];
                    if (kelas.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.class_outlined,
                              size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('Belum ada kelas',
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Ketuk "+ Kelas" untuk menambahkan',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400])),
                        ],
                      );
                    }
                    return ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: kelas.length,
                      itemBuilder: (ctx, i) {
                        final k = kelas[i];
                        final isPenuh = k['is_penuh'] == true;
                        final pct = ((k['terisi'] as num) /
                                (k['kapasitas'] as num))
                            .clamp(0.0, 1.0);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: isPenuh
                                    ? Colors.red.withOpacity(0.3)
                                    : const Color(0xFFBBDEFB)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: isPenuh
                                            ? const Color(0xFFFFEBEE)
                                            : const Color(0xFFE3F2FD),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(k['nama_kelas'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isPenuh
                                                  ? Colors.red
                                                  : const Color(
                                                      0xFF1565C0))),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          const Icon(Icons.person_rounded,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                                k['dosen_nama'] ?? '',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    fontSize: 13),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ]),
                                        Row(children: [
                                          const Icon(
                                              Icons.access_time_rounded,
                                              size: 13,
                                              color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text('${k['hari']} | ${k['jam']}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600])),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.room_rounded,
                                              size: 13, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(k['ruangan'] ?? '',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600])),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          '${k['terisi']}/${k['kapasitas']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isPenuh
                                                  ? Colors.red
                                                  : Colors.green[700])),
                                      if (isPenuh)
                                        CustomChip(
                                            text: 'PENUH',
                                            bgColor:
                                                const Color(0xFFFFEBEE),
                                            textColor: Colors.red),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct.toDouble(),
                                  minHeight: 5,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      isPenuh
                                          ? Colors.red
                                          : const Color(0xFF1565C0)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Kelola Mata Kuliah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00695C),
        onPressed: () => _showFormMatkul(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Matkul',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded,
                    color: Colors.orange, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ketuk nama matkul untuk lihat & tambah kelas',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                _searchQuery = v;
                _loadData();
              },
              decoration: InputDecoration(
                hintText: 'Cari nama atau kode matkul...',
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF00695C)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Memuat matkul...')
                : _list.isEmpty
                    ? const EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'Belum Ada Mata Kuliah',
                        subtitle:
                            'Tambah mata kuliah dengan tombol di bawah',
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _list.length,
                        itemBuilder: (ctx, i) {
                          final mk = _list[i];
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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showDetailMatkul(mk),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color:
                                                const Color(0xFFE0F2F1),
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        child: const Icon(
                                            Icons.menu_book_rounded,
                                            color: Color(0xFF00695C),
                                            size: 24),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(mk['nama'],
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(
                                                        0xFF1A237E))),
                                            const SizedBox(height: 6),
                                            Row(children: [
                                              CustomChip(
                                                  text: mk['kode'],
                                                  bgColor: const Color(
                                                      0xFFE0F2F1),
                                                  textColor: const Color(
                                                      0xFF00695C)),
                                              const SizedBox(width: 6),
                                              CustomChip(
                                                  text:
                                                      '${mk['sks']} SKS',
                                                  bgColor: const Color(
                                                      0xFFE3F2FD),
                                                  textColor: const Color(
                                                      0xFF1565C0)),
                                              const SizedBox(width: 6),
                                              CustomChip(
                                                  text:
                                                      'Sem ${mk['semester']}',
                                                  bgColor: const Color(
                                                      0xFFFFF3E0),
                                                  textColor:
                                                      Colors.orange[700]!),
                                            ]),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(
                                            Icons.more_vert_rounded,
                                            color: Colors.grey),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem(
                                              value: 'kelas',
                                              child: Row(children: [
                                                Icon(Icons.class_rounded,
                                                    size: 18,
                                                    color:
                                                        Color(0xFFE65100)),
                                                SizedBox(width: 10),
                                                Text('Tambah Kelas'),
                                              ])),
                                          const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(children: [
                                                Icon(Icons.edit_rounded,
                                                    size: 18,
                                                    color:
                                                        Color(0xFF00695C)),
                                                SizedBox(width: 10),
                                                Text('Edit'),
                                              ])),
                                          const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(children: [
                                                Icon(Icons.delete_rounded,
                                                    size: 18,
                                                    color: Colors.red),
                                                SizedBox(width: 10),
                                                Text('Hapus',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ])),
                                        ],
                                        onSelected: (val) async {
                                          if (val == 'kelas') {
                                            _showFormKelas(mk);
                                          } else if (val == 'edit') {
                                            _showFormMatkul(existing: mk);
                                          } else {
                                            final result =
                                                await ApiService
                                                    .deleteMatkul(mk['id']);
                                            if (!mounted) return;
                                            if (result['success'] == true) {
                                              showSnackBar(context,
                                                  'Matkul berhasil dihapus!');
                                              _loadData();
                                            } else {
                                              showSnackBar(
                                                  context,
                                                  result['message'] ??
                                                      'Gagal!',
                                                  isError: true);
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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