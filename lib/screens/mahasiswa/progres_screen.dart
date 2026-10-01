import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

class ProgresScreen extends StatefulWidget {
  const ProgresScreen({super.key});

  @override
  State<ProgresScreen> createState() => _ProgresScreenState();
}

class _ProgresScreenState extends State<ProgresScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getProgres();
    if (mounted) {
      setState(() {
        _data = result['success'] == true ? result : null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(title: const Text('Progres Akademik')),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat data progres...')
          : _data == null
              ? const EmptyState(
                  icon: Icons.bar_chart_rounded,
                  title: 'Data Tidak Tersedia',
                  subtitle: 'Belum ada data nilai untuk ditampilkan',
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildEwsBanner(),
                        _buildGrafikSection(),
                        _buildDetailSemester(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _headerStat(_data!['ipk_kumulatif'].toString(), 'IPK Kumulatif'),
          _vLine(),
          _headerStat('${_data!['total_sks_lulus']} SKS', 'SKS Lulus'),
          _vLine(),
          _headerStat('${_data!['jumlah_semester']} Smt', 'Ditempuh'),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _vLine() => Container(width: 1, height: 36, color: Colors.white24);

  // ==================== EWS BANNER (BARU) ====================
  // Menampilkan ringkasan peringatan dini di bagian atas halaman,
  // muncul HANYA jika ada semester dengan IPS < 3.0 atau matkul dengan kehadiran < 12 pertemuan.
  Widget _buildEwsBanner() {
    final semesters = _data!['data_semester'] as List<dynamic>? ?? [];

    final semesterIpsBermasalah = semesters.where((s) => s['ews_ips'] == true).toList();

    int jumlahMatkulKehadiranBermasalah = 0;
    for (final s in semesters) {
      final detailKehadiran = s['detail_kehadiran'] as List<dynamic>? ?? [];
      jumlahMatkulKehadiranBermasalah +=
          detailKehadiran.where((k) => k['ews_kehadiran'] == true).length;
    }

    if (semesterIpsBermasalah.isEmpty && jumlahMatkulKehadiranBermasalah == 0) {
      return const SizedBox.shrink();
    }

    final List<String> pesan = [];
    if (semesterIpsBermasalah.isNotEmpty) {
      final semesterNomor = _joinSemesterNumbers(semesterIpsBermasalah);
      pesan.add('IPS Anda di bawah 3.0 pada Semester $semesterNomor.');
    }
    if (jumlahMatkulKehadiranBermasalah > 0) {
      pesan.add(
          'Kehadiran belum mencukupi pada $jumlahMatkulKehadiranBermasalah mata kuliah.');
    }
    pesan.add('Segera evaluasi progres akademik Anda.');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEF5350), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded, color: Color(0xFFD32F2F), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Peringatan Dini (EWS)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC62828),
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  pesan.join(' '),
                  style: const TextStyle(
                      color: Color(0xFFB71C1C), fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gabungkan daftar nomor semester jadi kalimat natural:
  // 1 item -> "3"
  // 2 item -> "3 dan 5"
  // 3+ item -> "3, 5, dan 7"
  String _joinSemesterNumbers(List<dynamic> semesterList) {
    final nomor = semesterList.map((s) => '${s['semester_ke']}').toList();
    if (nomor.length == 1) return nomor[0];
    if (nomor.length == 2) return '${nomor[0]} dan ${nomor[1]}';
    return '${nomor.sublist(0, nomor.length - 1).join(', ')}, dan ${nomor.last}';
  }

  Widget _buildGrafikSection() {
    final semesters = _data!['data_semester'] as List<dynamic>? ?? [];
    if (semesters.isEmpty) return const SizedBox.shrink();

    final ipsList = semesters.map((s) => (s['ips'] as num).toDouble()).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 3),
          )],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grafik IPS Per Semester',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A237E))),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _LineChartPainter(
                  ipsList: ipsList,
                  labels: semesters
                      .map((s) => 'Smt ${s['semester_ke']}')
                      .toList()
                      .cast<String>(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSemester() {
    final semesters = _data!['data_semester'] as List<dynamic>? ?? [];
    if (semesters.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Nilai Per Semester',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A237E))),
          const SizedBox(height: 12),
          ...semesters.map((s) {
            final bool ewsIps = s['ews_ips'] == true;
            final detailKehadiran = s['detail_kehadiran'] as List<dynamic>? ?? [];
            final kehadiranBermasalah =
                detailKehadiran.where((k) => k['ews_kehadiran'] == true).toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8, offset: const Offset(0, 2),
                )],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('${s['semester_ke']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6A1B9A), fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                        'Semester ${s['semester_ke']} — ${s['semester_nama']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A237E))),
                                  ),
                                  if (ewsIps) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD32F2F),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('⚠ Perlu Perhatian',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                  'IPS: ${s['ips']} • ${s['total_sks']} SKS • ${s['jumlah_matkul']} Matkul',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ewsIps
                                        ? const Color(0xFFD32F2F)
                                        : Colors.grey[500],
                                    fontWeight:
                                        ewsIps ? FontWeight.bold : FontWeight.normal,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // ==== DETAIL NILAI — LANGSUNG TAMPIL, TIDAK PERLU DI-TAP ====
                  ...(s['detail_nilai'] as List<dynamic>? ?? [])
                      .map((n) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n['matkul_nama'] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Text(
                                          'Tugas: ${n['nilai_tugas']}   Kuis: ${n['nilai_kuis']}   UTS: ${n['nilai_uts']}   UAS: ${n['nilai_uas']}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _nilaiColor(n['nilai_akhir_huruf'] ?? '-'),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(n['nilai_akhir_huruf'] ?? '-',
                                          style: const TextStyle(
                                              color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${n['nilai_akhir_angka']}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                  ],
                                ),
                              ],
                            ),
                          )),
                  // ==== EWS KEHADIRAN — TAMPIL HANYA JIKA ADA MATKUL BERMASALAH ====
                  if (kehadiranBermasalah.isNotEmpty) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.event_busy_rounded,
                                  color: Color(0xFFD32F2F), size: 16),
                              SizedBox(width: 6),
                              Text('Kehadiran Perlu Perhatian',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD32F2F))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...kehadiranBermasalah.map((k) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• ${k['matkul_nama']}: ${k['total_hadir']} dari 16 pertemuan — belum mencukupi',
                                  style: const TextStyle(
                                      fontSize: 11.5, color: Color(0xFFB71C1C)),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                ],
              ),
            );
          }),
        ],
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
}

class _LineChartPainter extends CustomPainter {
  final List<double> ipsList;
  final List<String> labels;

  _LineChartPainter({required this.ipsList, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (ipsList.isEmpty) return;

    const double padLeft = 40;
    const double padRight = 16;
    const double padTop = 16;
    const double padBottom = 40;

    final chartW = size.width - padLeft - padRight;
    final chartH = size.height - padTop - padBottom;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;

    final textStyle = TextStyle(color: Colors.grey[500], fontSize: 10);
    final yValues = [0.0, 1.0, 2.0, 3.0, 4.0];

    for (final yVal in yValues) {
      final y = padTop + chartH * (1 - yVal / 4.0);
      canvas.drawLine(Offset(padLeft, y), Offset(size.width - padRight, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: yVal.toStringAsFixed(1), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(padLeft - tp.width - 4, y - tp.height / 2));
    }

    final linePaint = Paint()
      ..color = const Color(0xFF6A1B9A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6A1B9A).withOpacity(0.2),
          const Color(0xFF6A1B9A).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(padLeft, padTop, chartW, chartH))
      ..style = PaintingStyle.fill;

    final n = ipsList.length;
    final xStep = n > 1 ? chartW / (n - 1) : chartW;

    List<Offset> points = [];
    for (int i = 0; i < n; i++) {
      final x = padLeft + (n > 1 ? i * xStep : chartW / 2);
      final y = padTop + chartH * (1 - ipsList[i] / 4.0);
      points.add(Offset(x, y));
    }

    final fillPath = Path();
    fillPath.moveTo(points.first.dx, padTop + chartH);
    for (final p in points) fillPath.lineTo(p.dx, p.dy);
    fillPath.lineTo(points.last.dx, padTop + chartH);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF6A1B9A)..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      canvas.drawCircle(p, 6, dotBorderPaint);
      canvas.drawCircle(p, 4.5, dotPaint);

      final valTp = TextPainter(
        text: TextSpan(
            text: ipsList[i].toStringAsFixed(2),
            style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 9, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(p.dx - valTp.width / 2, p.dy - 18));

      if (i < labels.length) {
        final lTp = TextPainter(
          text: TextSpan(text: labels[i], style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        lTp.paint(canvas, Offset(p.dx - lTp.width / 2, size.height - padBottom + 8));
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.ipsList != ipsList || old.labels != labels;
}