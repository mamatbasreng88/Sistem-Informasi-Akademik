import 'package:flutter/material.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'Bagaimana cara mengisi KRS?',
      'a': 'Masuk ke menu "Input KRS", pilih mata kuliah yang tersedia, '
          'lalu tekan tombol "Simpan KRS". Pastikan periode KRS sedang dibuka oleh admin.',
    },
    {
      'q': 'Mengapa saya tidak bisa mengisi KRS?',
      'a': 'Ada beberapa kemungkinan: (1) Periode KRS belum dibuka, '
          '(2) Pembayaran UKT tahap 1 belum dikonfirmasi admin, '
          '(3) Total SKS yang dipilih melebihi batas maksimal.',
    },
    {
      'q': 'Bagaimana cara melihat nilai saya?',
      'a': 'Nilai semester aktif dapat dilihat di menu "KHS" (Kartu Hasil Studi). '
          'Untuk rekap nilai seluruh semester, gunakan menu "Transkrip".',
    },
    {
      'q': 'Apa itu Pessimistic Locking pada KRS?',
      'a': 'Sistem SIKAD menggunakan Pessimistic Locking untuk mencegah konflik '
          'saat banyak mahasiswa mendaftar kelas yang sama secara bersamaan. '
          'Jika kelas sudah penuh, sistem akan memberitahu secara real-time.',
    },
    {
      'q': 'Bagaimana cara mendapatkan notifikasi KRS?',
      'a': 'Pastikan Anda sudah login dan mengizinkan notifikasi saat pertama '
          'kali membuka aplikasi. Notifikasi akan dikirim otomatis saat admin '
          'membuka atau menutup periode KRS.',
    },
    {
      'q': 'Bagaimana cara mengubah password?',
      'a': 'Masuk ke menu Profil → Pengaturan Akun → Ubah Password. '
          'Masukkan password lama dan password baru minimal 8 karakter.',
    },
    {
      'q': 'Siapa yang bisa menghubungi admin?',
      'a': 'Untuk keperluan akademik seperti konfirmasi pembayaran atau '
          'permasalahan data, silakan hubungi bagian administrasi akademik '
          'Universitas Islam Riau secara langsung.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Bantuan & FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.help_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pusat Bantuan',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Temukan jawaban atas pertanyaan Anda',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Pertanyaan yang Sering Diajukan',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E))),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => _buildFaqItem(faq['q']!, faq['a']!)),
          const SizedBox(height: 8),
          // Kontak
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.support_agent_rounded,
                      color: Color(0xFF1565C0), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Butuh bantuan lebih lanjut?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1A237E))),
                      SizedBox(height: 2),
                      Text('Hubungi bagian akademik UIR',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 14),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.question_mark_rounded,
              color: Color(0xFF1565C0), size: 16),
        ),
        title: Text(question,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1A237E))),
        iconColor: const Color(0xFF1565C0),
        collapsedIconColor: Colors.grey,
        children: [
          Text(answer,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5)),
        ],
      ),
    );
  }
}