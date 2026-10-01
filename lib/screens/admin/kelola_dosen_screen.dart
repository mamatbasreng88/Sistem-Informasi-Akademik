import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class KelolaDosenScreen extends StatefulWidget {
  const KelolaDosenScreen({super.key});

  @override
  State<KelolaDosenScreen> createState() => _KelolaDosenScreenState();
}

class _KelolaDosenScreenState extends State<KelolaDosenScreen> {
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
    final result = await ApiService.getDosenList(search: _searchQuery);
    if (mounted) {
      setState(() {
        _list = result['data'] ?? [];
        _isLoading = false;
      });
    }
  }

  void _showForm({dynamic existing}) {
    final namaCtrl =
        TextEditingController(text: existing?['nama'] ?? '');
    final nidnCtrl =
        TextEditingController(text: existing?['nidn'] ?? '');
    final emailCtrl =
        TextEditingController(text: existing?['email'] ?? '');
    final hpCtrl =
        TextEditingController(text: existing?['no_hp'] ?? '');
    final passCtrl = TextEditingController();
    final prodiCtrl = TextEditingController(
        text: existing?['prodi'] ?? 'Teknik Informatika');
    final fakultasCtrl = TextEditingController(
        text: existing?['fakultas'] ?? 'Fakultas Teknik');
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
                    isEdit ? 'Edit Dosen' : 'Tambah Dosen',
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
                      validator: (v) =>
                          v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: nidnCtrl,
                      label: 'NIDN',
                      icon: Icons.badge_rounded,
                      isNumber: true,
                      validator: (v) =>
                          v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: emailCtrl,
                      label: 'Email',
                      icon: Icons.email_rounded,
                      validator: (v) =>
                          v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: hpCtrl,
                      label: 'No. HP',
                      icon: Icons.phone_rounded,
                      isNumber: true),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: prodiCtrl,
                      label: 'Program Studi',
                      icon: Icons.school_rounded,
                      validator: (v) =>
                          v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: fakultasCtrl,
                      label: 'Fakultas',
                      icon: Icons.business_rounded,
                      validator: (v) =>
                          v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  buildInputField(
                      controller: passCtrl,
                      label: isEdit
                          ? 'Password Baru (kosongkan jika tidak diubah)'
                          : 'Password',
                      icon: Icons.lock_rounded,
                      validator: isEdit
                          ? null
                          : (v) =>
                              v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate())
                                return;
                              setModal(() => isSaving = true);

                              final data = {
                                'nama': namaCtrl.text,
                                'nidn': nidnCtrl.text,
                                'email': emailCtrl.text,
                                'prodi': prodiCtrl.text,
                                'fakultas': fakultasCtrl.text,
                                'no_hp': hpCtrl.text,
                                if (passCtrl.text.isNotEmpty)
                                  'password': passCtrl.text,
                              };

                              Map<String, dynamic> result;
                              if (isEdit) {
                                result = await ApiService.updateDosen(
                                    existing['id'], data);
                              } else {
                                result =
                                    await ApiService.createDosen(data);
                              }

                              if (!mounted) return;
                              Navigator.pop(ctx);

                              if (result['success'] == true) {
                                showSnackBar(context,
                                    isEdit
                                        ? 'Data berhasil diperbarui!'
                                        : 'Dosen berhasil ditambahkan!');
                                _loadData();
                              } else {
                                showSnackBar(
                                    context,
                                    result['message'] ?? 'Gagal!',
                                    isError: true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                      ),
                      child: Text(
                        isSaving
                            ? 'Menyimpan...'
                            : isEdit
                                ? 'SIMPAN PERUBAHAN'
                                : 'TAMBAH DOSEN',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
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

  void _deleteConfirm(dynamic dsn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Dosen',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Hapus akun ${dsn['nama']}?',
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result =
                  await ApiService.deleteDosen(dsn['id']);
              if (!mounted) return;
              if (result['success'] == true) {
                showSnackBar(context, 'Dosen berhasil dihapus!');
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
        title: const Text('Kelola Dosen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6A1B9A),
        onPressed: () => _showForm(),
        icon: const Icon(Icons.manage_accounts_rounded,
            color: Colors.white),
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
                hintText: 'Cari nama atau NIDN...',
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF6A1B9A)),
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
                ? const LoadingWidget(message: 'Memuat data...')
                : _list.isEmpty
                    ? const EmptyState(
                        icon: Icons.school_outlined,
                        title: 'Belum Ada Dosen',
                        subtitle:
                            'Tambah dosen dengan tombol di bawah',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        itemCount: _list.length,
                        itemBuilder: (ctx, i) {
                          final dsn = _list[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3))
                              ],
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                              leading: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF6A1B9A),
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                child: Center(
                                  child: Text(
                                    (dsn['nama'] as String).isNotEmpty
                                        ? (dsn['nama'] as String)[0]
                                        : '?',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              title: Text(dsn['nama'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF1A237E))),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 3),
                                  Text('NIDN: ${dsn['nidn']}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500])),
                                  Text(
                                      '${dsn['jumlah_kelas']} kelas diampu',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500])),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(
                                    Icons.more_vert_rounded,
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
                                            color:
                                                Color(0xFF6A1B9A)),
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
                                    _showForm(existing: dsn);
                                  } else {
                                    _deleteConfirm(dsn);
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