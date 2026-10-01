import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class KelolaMahasiswaScreen extends StatefulWidget {
  const KelolaMahasiswaScreen({super.key});

  @override
  State<KelolaMahasiswaScreen> createState() =>
      _KelolaMahasiswaScreenState();
}

class _KelolaMahasiswaScreenState extends State<KelolaMahasiswaScreen> {
  List<dynamic> _list = [];
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
    final result = await ApiService.getMahasiswaList(search: _searchQuery);
    if (mounted) {
      setState(() {
        _list = result['data'] ?? [];
        _isLoading = false;
      });
    }
  }

  void _showForm({dynamic existing}) {
    final namaCtrl = TextEditingController(text: existing?['nama'] ?? '');
    final nimCtrl = TextEditingController(text: existing?['nim'] ?? '');
    final emailCtrl = TextEditingController(text: existing?['email'] ?? '');
    final angkatanCtrl = TextEditingController(
        text: existing?['angkatan']?.toString() ?? '');
    final passCtrl = TextEditingController();
    final prodiCtrl = TextEditingController(
        text: existing?['prodi'] ?? 'Teknik Informatika');
    final fakultasCtrl = TextEditingController(
        text: existing?['fakultas'] ?? 'Fakultas Teknik');
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;
    bool isSaving = false;

    // Semester dropdown - default 1
    int selectedSemester = existing?['semester'] ?? 1;

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
                  Text(
                    isEdit ? 'Edit Mahasiswa' : 'Tambah Mahasiswa',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 20),
                  buildInputField(
                      controller: namaCtrl,
                      label: 'Nama Lengkap',
                      icon: Icons.person_rounded,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: nimCtrl,
                      label: 'NIM',
                      icon: Icons.badge_rounded,
                      isNumber: true,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: emailCtrl,
                      label: 'Email',
                      icon: Icons.email_rounded,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: angkatanCtrl,
                      label: 'Angkatan',
                      icon: Icons.calendar_month_rounded,
                      isNumber: true,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: prodiCtrl,
                      label: 'Program Studi',
                      icon: Icons.school_rounded,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: fakultasCtrl,
                      label: 'Fakultas',
                      icon: Icons.business_rounded,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),

                  // ← TAMBAHAN: Dropdown Semester
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Semester',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A237E))),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedSemester,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF1565C0)),
                            items: List.generate(14, (i) => i + 1)
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.looks_one_rounded,
                                              size: 18,
                                              color: Color(0xFF1565C0)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Semester $s ${s % 2 != 0 ? "(Ganjil)" : "(Genap)"}',
                                            style: const TextStyle(
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModal(() => selectedSemester = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  buildInputField(
                      controller: passCtrl,
                      label: isEdit
                          ? 'Password Baru (kosongkan jika tidak diubah)'
                          : 'Password',
                      icon: Icons.lock_rounded,
                      validator: isEdit
                          ? null
                          : (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModal(() => isSaving = true);

                              final data = {
                                'nama': namaCtrl.text,
                                'nim': nimCtrl.text,
                                'email': emailCtrl.text,
                                'angkatan': int.tryParse(angkatanCtrl.text),
                                'prodi': prodiCtrl.text,
                                'fakultas': fakultasCtrl.text,
                                'semester': selectedSemester,
                                if (passCtrl.text.isNotEmpty)
                                  'password': passCtrl.text,
                              };

                              Map<String, dynamic> result;
                              if (isEdit) {
                                result = await ApiService.updateMahasiswa(
                                    existing['id'], data);
                              } else {
                                result =
                                    await ApiService.createMahasiswa(data);
                              }

                              if (!mounted) return;
                              Navigator.pop(ctx);

                              if (result['success'] == true) {
                                showSnackBar(
                                    context,
                                    isEdit
                                        ? 'Data berhasil diperbarui!'
                                        : 'Mahasiswa berhasil ditambahkan!');
                                _loadData();
                              } else {
                                showSnackBar(
                                    context,
                                    result['message'] ?? 'Gagal!',
                                    isError: true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        isSaving
                            ? 'Menyimpan...'
                            : isEdit
                                ? 'SIMPAN PERUBAHAN'
                                : 'TAMBAH MAHASISWA',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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

  void _deleteConfirm(dynamic mhs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Mahasiswa',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Hapus akun ${mhs['nama']}?',
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result =
                  await ApiService.deleteMahasiswa(mhs['id']);
              if (!mounted) return;
              if (result['success'] == true) {
                showSnackBar(context, 'Mahasiswa berhasil dihapus!');
                _loadData();
              } else {
                showSnackBar(context, result['message'] ?? 'Gagal!',
                    isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
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
        title: const Text('Kelola Mahasiswa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1565C0),
        onPressed: () => _showForm(),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Tambah',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                _searchQuery = v;
                _loadData();
              },
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIM...',
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF1565C0)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Colors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          _searchQuery = '';
                          _loadData();
                        })
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Memuat data...')
                : _list.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'Belum Ada Mahasiswa',
                        subtitle: 'Tambah mahasiswa dengan tombol di bawah',
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _list.length,
                        itemBuilder: (ctx, i) {
                          final mhs = _list[i];
                          final semester = mhs['semester'] ?? 1;
                          final isGanjil = semester % 2 != 0;
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
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0),
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                child: Center(
                                  child: Text(
                                    (mhs['nama'] as String).isNotEmpty
                                        ? (mhs['nama'] as String)[0]
                                        : '?',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              title: Text(mhs['nama'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF1A237E))),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 3),
                                  Text('NIM: ${mhs['nim']}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500])),
                                  const SizedBox(height: 3),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      CustomChip(
                                        text: '${mhs['angkatan']}',
                                        bgColor: const Color(0xFFE3F2FD),
                                        textColor: const Color(0xFF1565C0),
                                      ),
                                      // ← TAMBAHAN: Chip semester
                                      CustomChip(
                                        text: 'Smtr $semester ${isGanjil ? "Ganjil" : "Genap"}',
                                        bgColor: isGanjil
                                            ? const Color(0xFFF3E5F5)
                                            : const Color(0xFFE8F5E9),
                                        textColor: isGanjil
                                            ? Colors.purple
                                            : Colors.green[700]!,
                                      ),
                                      CustomChip(
                                        text: mhs['status_bayar'] == true
                                            ? 'Lunas'
                                            : 'Belum Bayar',
                                        bgColor: mhs['status_bayar'] == true
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFFFEBEE),
                                        textColor: mhs['status_bayar'] == true
                                            ? Colors.green[700]!
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded,
                                    color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(children: [
                                        Icon(Icons.edit_rounded,
                                            size: 18,
                                            color: Color(0xFF1565C0)),
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
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showForm(existing: mhs);
                                  } else {
                                    _deleteConfirm(mhs);
                                  }
                                },
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