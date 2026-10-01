import '../models/user_model.dart';

class DummyData {
  // ===================== USERS =====================
  static List<Map<String, dynamic>> mahasiswaList = [
    {
      'id': 'mhs001',
      'nama': 'Chikal Verguson',
      'nim': '223510295',
      'email': 'chikal@student.uir.ac.id',
      'prodi': 'Teknik Informatika',
      'fakultas': 'Fakultas Teknik',
      'angkatan': '2022',
      'ipk': 3.75,
      'statusBayar': true,
      'password': '123',
    },
    {
      'id': 'mhs002',
      'nama': 'Budi Santoso',
      'nim': '223510001',
      'email': 'budi@student.uir.ac.id',
      'prodi': 'Teknik Informatika',
      'fakultas': 'Fakultas Teknik',
      'angkatan': '2022',
      'ipk': 2.80,
      'statusBayar': false,
      'password': '123',
    },
    {
      'id': 'mhs003',
      'nama': 'Siti Aminah',
      'nim': '223510045',
      'email': 'siti@student.uir.ac.id',
      'prodi': 'Teknik Informatika',
      'fakultas': 'Fakultas Teknik',
      'angkatan': '2022',
      'ipk': 3.50,
      'statusBayar': true,
      'password': '123',
    },
    {
      'id': 'mhs004',
      'nama': 'Andi Wijaya',
      'nim': '223510112',
      'email': 'andi@student.uir.ac.id',
      'prodi': 'Teknik Informatika',
      'fakultas': 'Fakultas Teknik',
      'angkatan': '2022',
      'ipk': 2.40,
      'statusBayar': true,
      'password': '123',
    },
  ];

  static List<Map<String, dynamic>> dosenList = [
    {
      'id': 'dsn001',
      'nama': 'Dr. Panji Rachmat S.',
      'nidn': '0123456789',
      'email': 'panji@uir.ac.id',
      'prodi': 'Teknik Informatika',
      'fakultas': 'Fakultas Teknik',
      'noHp': '08123456789',
      'password': '123',
    },
    {
      'id': 'dsn002',
      'nama': 'Dr. Ahmad Fauzi',
      'nidn': '0987654321',
      'email': 'ahmad@uir.ac.id',
      'prodi': 'Teknik Informatika',
      'fakultas': 'Fakultas Teknik',
      'noHp': '08198765432',
      'password': '123',
    },
    {
      'id': 'dsn003',
      'nama': 'Ir. Sari Dewi M.T.',
      'nidn': '0112233445',
      'email': 'sari@uir.ac.id',
      'prodi': 'Teknik Informatika',
      'fakultas': 'Fakultas Teknik',
      'noHp': '08112233445',
      'password': '123',
    },
  ];

  // ===================== MATKUL =====================
  static List<Map<String, dynamic>> matkulList = [
    {'id': 'mk001', 'kode': 'TI601', 'nama': 'Pemrograman Mobile', 'sks': 3, 'semester': 6},
    {'id': 'mk002', 'kode': 'TI602', 'nama': 'Kecerdasan Buatan', 'sks': 3, 'semester': 6},
    {'id': 'mk003', 'kode': 'TI603', 'nama': 'Basis Data Terdistribusi', 'sks': 2, 'semester': 6},
    {'id': 'mk004', 'kode': 'TI604', 'nama': 'Jaringan Komputer', 'sks': 3, 'semester': 6},
    {'id': 'mk005', 'kode': 'TI605', 'nama': 'Internet of Things', 'sks': 4, 'semester': 6},
    {'id': 'mk006', 'kode': 'TI606', 'nama': 'Etika Profesi IT', 'sks': 2, 'semester': 6},
    {'id': 'mk007', 'kode': 'TI501', 'nama': 'Rekayasa Perangkat Lunak', 'sks': 3, 'semester': 5},
    {'id': 'mk008', 'kode': 'TI502', 'nama': 'Basis Data', 'sks': 3, 'semester': 5},
  ];

  // ===================== KELAS =====================
  static List<Map<String, dynamic>> kelasList = [
    // Pemrograman Mobile
    {'id': 'kls001', 'matkulId': 'mk001', 'matkulNama': 'Pemrograman Mobile', 'matkulKode': 'TI601', 'matkulSks': 3, 'dosenId': 'dsn001', 'dosenNama': 'Dr. Panji Rachmat S.', 'namaKelas': 'A', 'kapasitas': 40, 'terisi': 35, 'hari': 'Senin', 'jam': '08.00 - 10.30', 'ruangan': 'Lab 1'},
    {'id': 'kls002', 'matkulId': 'mk001', 'matkulNama': 'Pemrograman Mobile', 'matkulKode': 'TI601', 'matkulSks': 3, 'dosenId': 'dsn001', 'dosenNama': 'Dr. Panji Rachmat S.', 'namaKelas': 'B', 'kapasitas': 40, 'terisi': 40, 'hari': 'Senin', 'jam': '13.00 - 15.30', 'ruangan': 'Lab 1'},
    {'id': 'kls003', 'matkulId': 'mk001', 'matkulNama': 'Pemrograman Mobile', 'matkulKode': 'TI601', 'matkulSks': 3, 'dosenId': 'dsn002', 'dosenNama': 'Dr. Ahmad Fauzi', 'namaKelas': 'C', 'kapasitas': 40, 'terisi': 20, 'hari': 'Selasa', 'jam': '08.00 - 10.30', 'ruangan': 'Lab 2'},
    // Kecerdasan Buatan
    {'id': 'kls004', 'matkulId': 'mk002', 'matkulNama': 'Kecerdasan Buatan', 'matkulKode': 'TI602', 'matkulSks': 3, 'dosenId': 'dsn002', 'dosenNama': 'Dr. Ahmad Fauzi', 'namaKelas': 'A', 'kapasitas': 40, 'terisi': 38, 'hari': 'Rabu', 'jam': '08.00 - 10.30', 'ruangan': 'R.101'},
    {'id': 'kls005', 'matkulId': 'mk002', 'matkulNama': 'Kecerdasan Buatan', 'matkulKode': 'TI602', 'matkulSks': 3, 'dosenId': 'dsn003', 'dosenNama': 'Ir. Sari Dewi M.T.', 'namaKelas': 'B', 'kapasitas': 40, 'terisi': 15, 'hari': 'Rabu', 'jam': '13.00 - 15.30', 'ruangan': 'R.102'},
    // Basis Data Terdistribusi
    {'id': 'kls006', 'matkulId': 'mk003', 'matkulNama': 'Basis Data Terdistribusi', 'matkulKode': 'TI603', 'matkulSks': 2, 'dosenId': 'dsn001', 'dosenNama': 'Dr. Panji Rachmat S.', 'namaKelas': 'A', 'kapasitas': 40, 'terisi': 30, 'hari': 'Kamis', 'jam': '08.00 - 09.40', 'ruangan': 'R.201'},
    // Internet of Things
    {'id': 'kls007', 'matkulId': 'mk005', 'matkulNama': 'Internet of Things', 'matkulKode': 'TI605', 'matkulSks': 4, 'dosenId': 'dsn003', 'dosenNama': 'Ir. Sari Dewi M.T.', 'namaKelas': 'A', 'kapasitas': 40, 'terisi': 25, 'hari': 'Jumat', 'jam': '08.00 - 11.20', 'ruangan': 'Lab 3'},
    // Etika Profesi
    {'id': 'kls008', 'matkulId': 'mk006', 'matkulNama': 'Etika Profesi IT', 'matkulKode': 'TI606', 'matkulSks': 2, 'dosenId': 'dsn002', 'dosenNama': 'Dr. Ahmad Fauzi', 'namaKelas': 'A', 'kapasitas': 40, 'terisi': 10, 'hari': 'Sabtu', 'jam': '08.00 - 09.40', 'ruangan': 'R.301'},
  ];

  // ===================== KRS =====================
  // KRS mahasiswa mhs001 (Chikal) sudah mengambil beberapa kelas
  static List<Map<String, dynamic>> krsList = [
    {'id': 'krs001', 'mahasiswaId': 'mhs001', 'kelasId': 'kls001', 'semester': '6', 'tahun': '2024/2025'},
    {'id': 'krs002', 'mahasiswaId': 'mhs001', 'kelasId': 'kls004', 'semester': '6', 'tahun': '2024/2025'},
  ];

  // ===================== NILAI =====================
  static List<Map<String, dynamic>> nilaiList = [
    {'id': 'nil001', 'mahasiswaId': 'mhs001', 'mahasiswaNama': 'Chikal Verguson', 'nim': '223510295', 'kelasId': 'kls001', 'matkulNama': 'Pemrograman Mobile', 'namaKelas': 'A', 'nilaiAkhir': 'A'},
    {'id': 'nil002', 'mahasiswaId': 'mhs002', 'mahasiswaNama': 'Budi Santoso', 'nim': '223510001', 'kelasId': 'kls001', 'matkulNama': 'Pemrograman Mobile', 'namaKelas': 'A', 'nilaiAkhir': 'B+'},
    {'id': 'nil003', 'mahasiswaId': 'mhs003', 'mahasiswaNama': 'Siti Aminah', 'nim': '223510045', 'kelasId': 'kls001', 'matkulNama': 'Pemrograman Mobile', 'namaKelas': 'A', 'nilaiAkhir': 'A-'},
    {'id': 'nil004', 'mahasiswaId': 'mhs004', 'mahasiswaNama': 'Andi Wijaya', 'nim': '223510112', 'kelasId': 'kls001', 'matkulNama': 'Pemrograman Mobile', 'namaKelas': 'A', 'nilaiAkhir': null},
    // KHS Chikal semester lalu
    {'id': 'nil005', 'mahasiswaId': 'mhs001', 'mahasiswaNama': 'Chikal Verguson', 'nim': '223510295', 'kelasId': 'kls_old1', 'matkulNama': 'Algoritma & Pemrograman', 'namaKelas': 'A', 'nilaiAkhir': 'A'},
    {'id': 'nil006', 'mahasiswaId': 'mhs001', 'mahasiswaNama': 'Chikal Verguson', 'nim': '223510295', 'kelasId': 'kls_old2', 'matkulNama': 'Matematika Diskrit', 'namaKelas': 'B', 'nilaiAkhir': 'B+'},
    {'id': 'nil007', 'mahasiswaId': 'mhs001', 'mahasiswaNama': 'Chikal Verguson', 'nim': '223510295', 'kelasId': 'kls_old3', 'matkulNama': 'Struktur Data', 'namaKelas': 'A', 'nilaiAkhir': 'A'},
    {'id': 'nil008', 'mahasiswaId': 'mhs001', 'mahasiswaNama': 'Chikal Verguson', 'nim': '223510295', 'kelasId': 'kls_old4', 'matkulNama': 'Basis Data', 'namaKelas': 'A', 'nilaiAkhir': 'A-'},
    {'id': 'nil009', 'mahasiswaId': 'mhs001', 'mahasiswaNama': 'Chikal Verguson', 'nim': '223510295', 'kelasId': 'kls_old5', 'matkulNama': 'Pemrograman Web', 'namaKelas': 'B', 'nilaiAkhir': 'B'},
  ];

  // ===================== PEMBAYARAN =====================
  static List<Map<String, dynamic>> pembayaranList = [
    {'id': 'pay001', 'mahasiswaId': 'mhs001', 'mahasiswaNama': 'Chikal Verguson', 'nim': '223510295', 'tahap': 1, 'status': true, 'tanggal': '2025-01-15', 'semester': '6'},
    {'id': 'pay002', 'mahasiswaId': 'mhs002', 'mahasiswaNama': 'Budi Santoso', 'nim': '223510001', 'tahap': 1, 'status': false, 'tanggal': null, 'semester': '6'},
    {'id': 'pay003', 'mahasiswaId': 'mhs003', 'mahasiswaNama': 'Siti Aminah', 'nim': '223510045', 'tahap': 1, 'status': true, 'tanggal': '2025-01-20', 'semester': '6'},
    {'id': 'pay004', 'mahasiswaId': 'mhs004', 'mahasiswaNama': 'Andi Wijaya', 'nim': '223510112', 'tahap': 1, 'status': true, 'tanggal': '2025-01-18', 'semester': '6'},
  ];

  // ===================== SEMESTER =====================
  static Map<String, dynamic> semesterAktif = {
    'id': 'sem001',
    'nama': 'Genap 2024/2025',
    'tahun': '2024/2025',
    'semester': '6',
    'statusKrs': true,
    'tanggalMulaiKrs': '2025-01-10',
    'tanggalSelesaiKrs': '2025-01-31',
  };

  // Helper: Max SKS berdasarkan IPK
  static int getMaxSks(double ipk) {
    if (ipk >= 3.00) return 24;
    if (ipk >= 2.50) return 21;
    if (ipk >= 2.00) return 18;
    return 12;
  }

  // Helper: Warna nilai
  static String getNilaiLabel(double ipk) {
    if (ipk >= 3.51) return 'Dengan Pujian';
    if (ipk >= 3.01) return 'Sangat Memuaskan';
    if (ipk >= 2.76) return 'Memuaskan';
    if (ipk >= 2.00) return 'Cukup';
    return 'Kurang';
  }
}