import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class SemesterScreen extends StatefulWidget {
  const SemesterScreen({super.key});

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  Map<String, dynamic>? _semester;
  bool _isLoading = true;
  bool _krsOpen = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getSemesterAktif();
    if (mounted) {
      setState(() {
        _semester = result['success'] == true ? result['data'] : null;
        _krsOpen = _semester?['status_krs'] == true;
        _isLoading = false;
      });
    }
  }

  void _toggleKRS() {
    if (_semester == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          _krsOpen ? 'Tutup Periode KRS?' : 'Buka Periode KRS?',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _krsOpen ? Colors.red : const Color(0xFF1565C0)),
        ),
        content: Text(
          _krsOpen
              ? 'Mahasiswa tidak dapat mengisi KRS setelah ditutup.'
              : 'Mahasiswa dapat mengisi KRS setelah dibuka.',
          style: const TextStyle(color: Colors.grey),
        ),
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
                  await ApiService.toggleKRS(_semester!['id']);
              if (!mounted) return;
              if (result['success'] == true) {
                showSnackBar(context, result['message']);
                _loadData();
              } else {
                showSnackBar(context, result['message'] ?? 'Gagal!',
                    isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _krsOpen ? Colors.red : const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_krsOpen ? 'Tutup' : 'Buka',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFormSemester({bool isEdit = false}) {
    final namaCtrl = TextEditingController(
        text: isEdit ? (_semester?['nama'] ?? '') : '');
    final tahunCtrl = TextEditingController(
        text: isEdit ? (_semester?['tahun_akademik'] ?? '') : '');
    final mulaiCtrl = TextEditingController(
        text: isEdit
            ? (_semester?['tanggal_mulai_krs']?.toString() ?? '')
            : '');
    final selesaiCtrl = TextEditingController(
        text: isEdit
            ? (_semester?['tanggal_selesai_krs']?.toString() ?? '')
            : '');
    String? selectedPeriode =
        isEdit ? (_semester?['periode'] as String?) : null;
    final formKey = GlobalKey<FormState>();
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
                Text(
                  isEdit ? 'Edit Semester' : 'Buat Semester Baru',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 20),
                buildInputField(
                    controller: namaCtrl,
                    label: 'Nama Semester (Genap 2024/2025)',
                    icon: Icons.calendar_month_rounded,
                    validator: (v) =>
                        v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                buildInputField(
                    controller: tahunCtrl,
                    label: 'Tahun Akademik (2024/2025)',
                    icon: Icons.date_range_rounded,
                    validator: (v) =>
                        v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),

                // Periode
                if (!isEdit) ...[
                  const Text('Periode',
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
                        value: selectedPeriode,
                        isExpanded: true,
                        hint: const Text('Pilih Periode'),
                        items: ['Ganjil', 'Genap']
                            .map((p) => DropdownMenuItem(
                                value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) =>
                            setModal(() => selectedPeriode = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                buildInputField(
                    controller: mulaiCtrl,
                    label: 'Tanggal Mulai KRS (2025-01-10)',
                    icon: Icons.play_arrow_rounded,
                    validator: (v) =>
                        v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                buildInputField(
                    controller: selesaiCtrl,
                    label: 'Tanggal Selesai KRS (2025-01-31)',
                    icon: Icons.stop_rounded,
                    validator: (v) =>
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
                            if (!isEdit && selectedPeriode == null) {
                              showSnackBar(context, 'Pilih periode!',
                                  isError: true);
                              return;
                            }
                            setModal(() => isSaving = true);

                            final data = {
                              'nama': namaCtrl.text,
                              'tahun_akademik': tahunCtrl.text,
                              if (!isEdit) 'periode': selectedPeriode,
                              'tanggal_mulai_krs': mulaiCtrl.text,
                              'tanggal_selesai_krs': selesaiCtrl.text,
                            };

                            Map<String, dynamic> result;
                            if (isEdit && _semester != null) {
                              result = await ApiService.updateSemester(
                                  _semester!['id'], data);
                            } else {
                              result =
                                  await ApiService.createSemester(data);
                            }

                            if (!mounted) return;
                            Navigator.pop(ctx);

                            if (result['success'] == true) {
                              showSnackBar(context,
                                  isEdit ? 'Semester diperbarui!' : 'Semester baru dibuat!');
                              _loadData();
                            } else {
                              showSnackBar(
                                  context,
                                  result['message'] ?? 'Gagal!',
                                  isError: true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF880E4F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      isSaving
                          ? 'Menyimpan...'
                          : isEdit
                              ? 'SIMPAN PERUBAHAN'
                              : 'BUAT SEMESTER BARU',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Kelola Semester'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showFormSemester(),
            tooltip: 'Buat Semester Baru',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat semester...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Semester aktif card
                  if (_semester != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF880E4F),
                            Color(0xFFAD1457)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded,
                                  color: Colors.white70, size: 20),
                              const SizedBox(width: 8),
                              const Text('Semester Aktif',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    _showFormSemester(isEdit: true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: const Row(children: [
                                    Icon(Icons.edit_rounded,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Edit',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w600)),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(_semester!['nama'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_semester!['tahun_akademik'],
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.red, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Belum Ada Semester Aktif',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                                Text(
                                    'Buat semester baru dengan tombol + di atas',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red[700])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Status KRS
                  if (_semester != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Periode KRS',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E))),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: _krsOpen
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFFEBEE),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _krsOpen
                                      ? Icons.lock_open_rounded
                                      : Icons.lock_rounded,
                                  color: _krsOpen
                                      ? Colors.green
                                      : Colors.red,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _krsOpen
                                          ? 'KRS Sedang Dibuka'
                                          : 'KRS Sedang Ditutup',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: _krsOpen
                                              ? Colors.green[700]
                                              : Colors.red),
                                    ),
                                    Text(
                                      _krsOpen
                                          ? 'Mahasiswa dapat mengisi KRS'
                                          : 'Mahasiswa tidak dapat mengisi KRS',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _krsOpen,
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                                inactiveTrackColor:
                                    Colors.red.withOpacity(0.3),
                                onChanged: (_) => _toggleKRS(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _dateInfo(
                                  'Mulai KRS',
                                  _semester!['tanggal_mulai_krs']
                                          ?.toString() ??
                                      '-',
                                  Icons.play_arrow_rounded,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _dateInfo(
                                  'Selesai KRS',
                                  _semester!['tanggal_selesai_krs']
                                          ?.toString() ??
                                      '-',
                                  Icons.stop_rounded,
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _dateInfo(
      String label, String date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey[500])),
                Text(date,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}