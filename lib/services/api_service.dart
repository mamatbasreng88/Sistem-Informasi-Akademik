import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ==================== SAKELAR MODE DEMO ====================
  // true  = semua data diambil dari contoh di file ini, TIDAK ada koneksi internet sama sekali.
  //         Pakai ini untuk versi yang di-hosting (Netlify/Vercel/Firebase Hosting).
  // false = kembali ke kondisi asli, wajib backend (Laragon/php artisan serve) menyala.
  //         Pakai ini untuk development/testing seperti biasa.
  static const bool demoMode = true;

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // ==================== AKUN DEMO (dibagikan di kuesioner) ====================
  static final Map<String, Map<String, String>> _demoAccounts = {
    '223510001': {'password': 'demo123', 'role': 'mahasiswa'},
    'dosen@demo.com': {'password': 'demo123', 'role': 'dosen'},
    'ortu@demo.com': {'password': 'demo123', 'role': 'orang_tua'},
    'admin@demo.com': {'password': 'demo123', 'role': 'admin'},
  };

  // ==================== DATA CONTOH (fiktif, bukan data mahasiswa asli) ====================
  static final Map<String, dynamic> _semesterAktif = {
    'id': 1,
    'nama': 'Ganjil 2026/2027',
    'tahun_akademik': '2026/2027',
    'periode': 'Ganjil',
    'is_active': true,
    'status_krs': 1,
  };

  static final List<Map<String, dynamic>> _semesterList = [
    _semesterAktif,
    {'id': 2, 'nama': 'Genap 2025/2026', 'tahun_akademik': '2025/2026', 'periode': 'Genap', 'is_active': false, 'status_krs': 0},
    {'id': 3, 'nama': 'Ganjil 2025/2026', 'tahun_akademik': '2025/2026', 'periode': 'Ganjil', 'is_active': false, 'status_krs': 0},
  ];

  static final List<Map<String, dynamic>> _matkulList = [
    {'id': 1, 'kode': 'TI201', 'nama': 'Pemrograman Web', 'sks': 3, 'semester': 5},
    {'id': 2, 'kode': 'TI202', 'nama': 'Basis Data', 'sks': 3, 'semester': 5},
    {'id': 3, 'kode': 'TI301', 'nama': 'Rekayasa Perangkat Lunak', 'sks': 3, 'semester': 5},
    {'id': 4, 'kode': 'TI204', 'nama': 'Jaringan Komputer', 'sks': 2, 'semester': 5},
  ];

  static final Map<String, dynamic> _dosenSaya = {
    'id': 1,
    'nidn': '1234567890',
    'prodi': 'Teknik Informatika',
    'fakultas': 'Fakultas Teknik',
    'no_hp': '081234567890',
    'user': {'name': 'Dr. Ahmad Fauzi, M.Kom', 'email': 'dosen@demo.com'},
  };

  static final List<Map<String, dynamic>> _kelasDiampu = [
    {'id': 1, 'matkul_id': 1, 'matkul_nama': 'Pemrograman Web', 'matkul_kode': 'TI201', 'nama_kelas': 'A', 'hari': 'Rabu', 'jam': '08.00-10.00', 'ruangan': '2C.3.5', 'kapasitas': 40, 'terisi': 3, 'semester_id': 1},
    {'id': 2, 'matkul_id': 2, 'matkul_nama': 'Basis Data', 'matkul_kode': 'TI202', 'nama_kelas': 'A', 'hari': 'Selasa', 'jam': '13.00-15.00', 'ruangan': '2C.2.5', 'kapasitas': 40, 'terisi': 3, 'semester_id': 1},
  ];

  static final List<Map<String, dynamic>> _kelasTersedia = [
    ..._kelasDiampu.map((k) => {...k, 'dosen_nama': 'Dr. Ahmad Fauzi, M.Kom'}),
    {'id': 3, 'matkul_id': 3, 'matkul_nama': 'Rekayasa Perangkat Lunak', 'matkul_kode': 'TI301', 'nama_kelas': 'B', 'hari': 'Kamis', 'jam': '10.00-12.00', 'ruangan': '1A09', 'kapasitas': 40, 'terisi': 5, 'semester_id': 1, 'dosen_nama': 'Rina Kartika, M.Kom'},
  ];

  // Mahasiswa "aku" (akun demo mahasiswa yang sedang login)
  static final Map<String, dynamic> _mahasiswaSaya = {
    'id': 1,
    'nim': '223510001',
    'prodi': 'Teknik Informatika',
    'fakultas': 'Fakultas Teknik',
    'angkatan': '2023',
    'ipk': 3.42,
    'semester': 5,
    'status_bayar': 1,
    'no_hp': '081200000001',
    'user': {'name': 'Budi Santoso', 'email': '223510001@student.demo.ac.id'},
  };

  // Mahasiswa lain, untuk daftar di kelas Dosen
  static final List<Map<String, dynamic>> _mahasiswaLain = [
    {'id': 2, 'nim': '223510002', 'nama': 'Siti Nurhaliza'},
    {'id': 3, 'nim': '223510003', 'nama': 'Ahmad Rizki'},
    {'id': 4, 'nim': '223510004', 'nama': 'Dewi Lestari'},
  ];

  static final List<Map<String, dynamic>> _krsSaya = [
    {'id': 1, 'kelas_id': 1, 'matkul_nama': 'Pemrograman Web', 'matkul_kode': 'TI201', 'sks': 3, 'nama_kelas': 'A', 'dosen_nama': 'Dr. Ahmad Fauzi, M.Kom', 'hari': 'Rabu', 'jam': '08.00-10.00', 'status': 'approved'},
    {'id': 2, 'kelas_id': 2, 'matkul_nama': 'Basis Data', 'matkul_kode': 'TI202', 'sks': 3, 'nama_kelas': 'A', 'dosen_nama': 'Dr. Ahmad Fauzi, M.Kom', 'hari': 'Selasa', 'jam': '13.00-15.00', 'status': 'approved'},
  ];

  static final List<Map<String, dynamic>> _komponenNilaiSaya = [
    {
      'id': 1, 'matkul_nama': 'Pemrograman Web', 'matkul_kode': 'TI201', 'matkul_sks': 3, 'nama_kelas': 'A',
      'dosen_nama': 'Dr. Ahmad Fauzi, M.Kom', 'nilai_akhir': 'A-',
    },
    {
      'id': 2, 'matkul_nama': 'Basis Data', 'matkul_kode': 'TI202', 'matkul_sks': 3, 'nama_kelas': 'A',
      'dosen_nama': 'Dr. Ahmad Fauzi, M.Kom', 'nilai_akhir': 'B+',
    },
  ];

  static final List<Map<String, dynamic>> _absensiSaya = [
    {'matkul_nama': 'Pemrograman Web', 'nama_kelas': 'A', 'total_pertemuan': 8, 'hadir': 7, 'izin': 1, 'sakit': 0, 'alpha': 0, 'persentase': 87.5, 'ews_kehadiran': false},
    {'matkul_nama': 'Basis Data', 'nama_kelas': 'A', 'total_pertemuan': 8, 'hadir': 6, 'izin': 0, 'sakit': 0, 'alpha': 2, 'persentase': 75.0, 'ews_kehadiran': false},
  ];

  static final Map<String, dynamic> _orangTuaSaya = {
    'id': 1,
    'nama': 'Slamet Riyadi',
    'no_hp': '081300000001',
    'user': {'name': 'Slamet Riyadi', 'email': 'ortu@demo.com'},
    'mahasiswa': _mahasiswaSaya,
  };

  static final List<Map<String, dynamic>> _pembayaranList = [
    {'mahasiswa_id': 1, 'nama': 'Budi Santoso', 'nim': '223510001', 'status': 'Lunas'},
    {'mahasiswa_id': 2, 'nama': 'Siti Nurhaliza', 'nim': '223510002', 'status': 'Lunas'},
    {'mahasiswa_id': 3, 'nama': 'Ahmad Rizki', 'nim': '223510003', 'status': 'Belum Bayar'},
    {'mahasiswa_id': 4, 'nama': 'Dewi Lestari', 'nim': '223510004', 'status': 'Lunas'},
  ];

  static final List<Map<String, dynamic>> _tugasList = [
    {'id': 1, 'kelas_id': 1, 'keterangan': 'Membuat ERD Sistem', 'urutan': 1},
    {'id': 2, 'kelas_id': 1, 'keterangan': 'Membuat Class Diagram', 'urutan': 2},
  ];
  static final List<Map<String, dynamic>> _kuisList = [
    {'id': 1, 'kelas_id': 1, 'keterangan': 'Konsep Dasar OOP', 'urutan': 1},
  ];

  // ==================== HELPER ====================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  static Future<void> saveSession(
      String token, String role, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<Map<String, String>> get _authHeaders async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // jeda kecil supaya terasa seperti memanggil server sungguhan (boleh dihapus)
  static Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  static Map<String, dynamic> _ok([Map<String, dynamic>? extra]) =>
      {'success': true, ...?extra};

  // ==================== AUTH ====================
  static Future<Map<String, dynamic>> login(
      String identifier, String password) async {
    if (demoMode) {
      await _delay();
      final acc = _demoAccounts[identifier];
      if (acc == null || acc['password'] != password) {
        return {'success': false, 'message': 'Username atau password salah!'};
      }
      final role = acc['role']!;
      late Map<String, dynamic> user;
      switch (role) {
        case 'mahasiswa':
          user = {'name': _mahasiswaSaya['user']['name'], 'email': _mahasiswaSaya['user']['email'], 'role': role};
          break;
        case 'dosen':
          user = {'name': _dosenSaya['user']['name'], 'email': _dosenSaya['user']['email'], 'role': role};
          break;
        case 'orang_tua':
          user = {'name': _orangTuaSaya['user']['name'], 'email': _orangTuaSaya['user']['email'], 'role': role};
          break;
        default:
          user = {'name': 'Admin Kampus', 'email': 'admin@demo.com', 'role': role};
      }
      await saveSession('demo-token', role, user);
      return _ok({'token': 'demo-token', 'user': user});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await saveSession(data['token'], data['user']['role'], data['user']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server!'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    if (demoMode) {
      await _delay();
      await clearSession();
      return _ok();
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _authHeaders,
      );
      await clearSession();
      return jsonDecode(response.body);
    } catch (e) {
      await clearSession();
      return {'success': true};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    if (demoMode) {
      await _delay();
      final user = await getUser();
      return _ok({'data': user});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat profil!'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Password berhasil diubah! (mode demo, tidak benar-benar tersimpan)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: await _authHeaders,
        body: jsonEncode({
          'password_lama': oldPassword,
          'password_baru': newPassword,
          'password_baru_confirmation': newPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengubah password!'};
    }
  }

  // ==================== SEMESTER ====================
  static Future<Map<String, dynamic>> getSemesterAktif() async {
    if (demoMode) {
      await _delay();
      return _ok({'data': _semesterAktif});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/semester/aktif'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat semester!'};
    }
  }

  static Future<Map<String, dynamic>> getAllSemester() async {
    if (demoMode) {
      await _delay();
      return _ok({'data': _semesterList});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/semester'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat semester!'};
    }
  }

  static Future<Map<String, dynamic>> createSemester(
      Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Semester berhasil ditambahkan! (mode demo)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/semester'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal membuat semester!'};
    }
  }

  static Future<Map<String, dynamic>> updateSemester(
      int id, Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Semester berhasil diperbarui! (mode demo)'});
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/semester/$id'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update semester!'};
    }
  }

  static Future<Map<String, dynamic>> toggleKRS(int id) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Status KRS berhasil diubah! (mode demo)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/semester/$id/toggle-krs'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal toggle KRS!'};
    }
  }

  // ==================== MAHASISWA (Admin) ====================
  static Future<Map<String, dynamic>> getMahasiswaList({String? search}) async {
    if (demoMode) {
      await _delay();
      final all = [_mahasiswaSaya, ..._mahasiswaLain];
      return _ok({'data': all});
    }
    try {
      String url = '$baseUrl/mahasiswa';
      if (search != null && search.isNotEmpty) url += '?search=$search';
      final response =
          await http.get(Uri.parse(url), headers: await _authHeaders);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat data mahasiswa!'};
    }
  }

  static Future<Map<String, dynamic>> createMahasiswa(
      Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Mahasiswa berhasil ditambahkan! (mode demo)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mahasiswa'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambahkan mahasiswa!'};
    }
  }

  static Future<Map<String, dynamic>> updateMahasiswa(
      int id, Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Data mahasiswa berhasil diperbarui! (mode demo)'});
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/mahasiswa/$id'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update mahasiswa!'};
    }
  }

  static Future<Map<String, dynamic>> deleteMahasiswa(int id) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Mahasiswa berhasil dihapus! (mode demo)'});
    }
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/mahasiswa/$id'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal hapus mahasiswa!'};
    }
  }

  // ==================== DOSEN ====================
  static Future<Map<String, dynamic>> getDosenList({String? search}) async {
    if (demoMode) {
      await _delay();
      return _ok({'data': [_dosenSaya, {'id': 2, 'nidn': '1234567891', 'prodi': 'Teknik Informatika', 'fakultas': 'Fakultas Teknik', 'no_hp': '081234567891', 'user': {'name': 'Rina Kartika, M.Kom', 'email': 'rina@demo.ac.id'}}]});
    }
    try {
      String url = '$baseUrl/dosen';
      if (search != null && search.isNotEmpty) url += '?search=$search';
      final response =
          await http.get(Uri.parse(url), headers: await _authHeaders);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat data dosen!'};
    }
  }

  static Future<Map<String, dynamic>> createDosen(
      Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Dosen berhasil ditambahkan! (mode demo)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dosen'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambahkan dosen!'};
    }
  }

  static Future<Map<String, dynamic>> updateDosen(
      int id, Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Data dosen berhasil diperbarui! (mode demo)'});
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/dosen/$id'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update dosen!'};
    }
  }

  static Future<Map<String, dynamic>> deleteDosen(int id) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Dosen berhasil dihapus! (mode demo)'});
    }
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/dosen/$id'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal hapus dosen!'};
    }
  }

  static Future<Map<String, dynamic>> getKelasDosen() async {
    if (demoMode) {
      await _delay();
      return _ok({'data': _kelasDiampu});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dosen/kelas'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat kelas!'};
    }
  }

  // ==================== MATKUL ====================
  static Future<Map<String, dynamic>> getMatkulList({String? search}) async {
    if (demoMode) {
      await _delay();
      return _ok({'data': _matkulList});
    }
    try {
      String url = '$baseUrl/matkul';
      if (search != null && search.isNotEmpty) url += '?search=$search';
      final response =
          await http.get(Uri.parse(url), headers: await _authHeaders);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat matkul!'};
    }
  }

  static Future<Map<String, dynamic>> createMatkul(
      Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Mata kuliah berhasil ditambahkan! (mode demo)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/matkul'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambahkan matkul!'};
    }
  }

  static Future<Map<String, dynamic>> updateMatkul(
      int id, Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Mata kuliah berhasil diperbarui! (mode demo)'});
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/matkul/$id'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update matkul!'};
    }
  }

  static Future<Map<String, dynamic>> deleteMatkul(int id) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Mata kuliah berhasil dihapus! (mode demo)'});
    }
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/matkul/$id'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal hapus matkul!'};
    }
  }

  // ==================== KELAS ====================
  static Future<Map<String, dynamic>> getKelasList({int? matkulId}) async {
    if (demoMode) {
      await _delay();
      var data = _kelasTersedia;
      if (matkulId != null) {
        data = data.where((k) => k['matkul_id'] == matkulId).toList();
      }
      return _ok({'data': data});
    }
    try {
      String url = '$baseUrl/kelas';
      if (matkulId != null) url += '?matkul_id=$matkulId';
      final response =
          await http.get(Uri.parse(url), headers: await _authHeaders);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat kelas!'};
    }
  }

  static Future<Map<String, dynamic>> getKelasTersedia() async {
    if (demoMode) {
      await _delay();
      return _ok({'data': _kelasTersedia});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kelas/tersedia'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat kelas tersedia!'};
    }
  }

  static Future<Map<String, dynamic>> createKelas(
      Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Kelas berhasil ditambahkan! (mode demo)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kelas'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambahkan kelas!'};
    }
  }

  static Future<Map<String, dynamic>> updateKelas(
      int id, Map<String, dynamic> data) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Kelas berhasil diperbarui! (mode demo)'});
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/kelas/$id'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update kelas!'};
    }
  }

  static Future<Map<String, dynamic>> deleteKelas(int id) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Kelas berhasil dihapus! (mode demo)'});
    }
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/kelas/$id'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal hapus kelas!'};
    }
  }

  static Future<Map<String, dynamic>> getMahasiswaInKelas(int kelasId) async {
    if (demoMode) {
      await _delay();
      final data = _mahasiswaLain
          .map((m) => {'id': m['id'], 'nim': m['nim'], 'nama': m['nama']})
          .toList();
      return _ok({'data': data});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kelas/$kelasId/mahasiswa'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat mahasiswa!'};
    }
  }

  // ==================== KRS ====================
  static Future<Map<String, dynamic>> getMyKRS() async {
    if (demoMode) {
      await _delay();
      return _ok({'data': _krsSaya});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/krs'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat KRS!'};
    }
  }

  static Future<Map<String, dynamic>> simpanKRS(List<int> kelasIds) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'KRS berhasil disimpan! (mode demo, tidak benar-benar tersimpan)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/krs'),
        headers: await _authHeaders,
        body: jsonEncode({'kelas_ids': kelasIds}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menyimpan KRS!'};
    }
  }

  // ==================== NILAI (KHS & Transkrip) ====================
  static Future<Map<String, dynamic>> getMyNilai() async {
    if (demoMode) {
      await _delay();
      return _ok({
        'ipk': _mahasiswaSaya['ipk'],
        'ip_semester': 3.5,
        'total_sks': 6,
        'semester': _semesterAktif['nama'],
        'data': _komponenNilaiSaya,
      });
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nilai'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat nilai!'};
    }
  }

  static Future<Map<String, dynamic>> getTranskrip() async {
    if (demoMode) {
      await _delay();
      return _ok({
        'ipk': _mahasiswaSaya['ipk'],
        'total_sks': 18,
        'semesters': [
          {'semester_id': 0, 'semester_nama': 'Ganjil 2024/2025', 'total_sks': 12, 'ip_semester': 3.30, 'data': [
            {'matkul_nama': 'Algoritma Pemrograman', 'matkul_kode': 'TI101', 'matkul_sks': 3, 'nama_kelas': 'A', 'dosen_nama': 'Dr. Ahmad Fauzi, M.Kom', 'nilai_akhir': 'A-'},
            {'matkul_nama': 'Kalkulus', 'matkul_kode': 'TI102', 'matkul_sks': 3, 'nama_kelas': 'A', 'dosen_nama': 'Rina Kartika, M.Kom', 'nilai_akhir': 'B+'},
          ]},
          {'semester_id': 1, 'semester_nama': _semesterAktif['nama'], 'total_sks': 6, 'ip_semester': 3.5, 'data': _komponenNilaiSaya},
        ],
      });
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transkrip'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat transkrip!'};
    }
  }

  // ==================== KOMPONEN NILAI (Dosen) ====================
  static Future<Map<String, dynamic>> getNilaiByKelas(int kelasId) async {
    if (demoMode) {
      await _delay();
      final kelas = _kelasDiampu.firstWhere((k) => k['id'] == kelasId, orElse: () => _kelasDiampu.first);
      final data = _mahasiswaLain.map((m) {
        final sudah = m['id'] != 4; // 1 mahasiswa sengaja belum dinilai, biar terlihat realistis
        return {
          'mahasiswa_id': m['id'],
          'nama': m['nama'],
          'nim': m['nim'],
          'nilai_tugas': sudah ? 85.0 : 0.0,
          'nilai_kuis': sudah ? 80.0 : 0.0,
          'nilai_uts': sudah ? 78.0 : 0.0,
          'nilai_uas': sudah ? 82.0 : 0.0,
          'nilai_akhir_angka': sudah ? 81.4 : 0.0,
          'nilai_akhir_huruf': sudah ? 'A-' : null,
          'sudah_diinput': sudah,
        };
      }).toList();
      return _ok({
        'semester_aktif': _semesterAktif['nama'],
        'kelas': {'id': kelas['id'], 'matkul_nama': kelas['matkul_nama'], 'matkul_kode': kelas['matkul_kode'], 'nama_kelas': kelas['nama_kelas']},
        'bobot': {'tugas': '20%', 'kuis': '10%', 'uts': '30%', 'uas': '40%'},
        'data': data,
      });
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kelas/$kelasId/komponen-nilai'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat nilai!'};
    }
  }

  static Future<Map<String, dynamic>> inputKomponenNilai({
    required int mahasiswaId,
    required int kelasId,
    required double nilaiUts,
    required double nilaiUas,
  }) async {
    if (demoMode) {
      await _delay();
      return _ok({
        'message': 'Nilai UTS/UAS berhasil disimpan! (mode demo, tidak benar-benar tersimpan)',
        'data': {'nilai_uts': nilaiUts, 'nilai_uas': nilaiUas},
      });
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/nilai/komponen'),
        headers: await _authHeaders,
        body: jsonEncode({
          'mahasiswa_id': mahasiswaId,
          'kelas_id':     kelasId,
          'nilai_uts':    nilaiUts,
          'nilai_uas':    nilaiUas,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal input nilai!'};
    }
  }

  // ==================== TUGAS & KUIS (Dosen) ====================
  static Future<Map<String, dynamic>> getTugasKuis(
      int kelasId, String jenis) async {
    if (demoMode) {
      await _delay();
      return _ok({'data': jenis == 'tugas' ? _tugasList : _kuisList});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kelas/$kelasId/$jenis'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat $jenis!'};
    }
  }

  static Future<Map<String, dynamic>> createTugasKuis(
      int kelasId, String jenis, String keterangan) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': '${jenis[0].toUpperCase()}${jenis.substring(1)} berhasil dibuat! (mode demo)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kelas/$kelasId/$jenis'),
        headers: await _authHeaders,
        body: jsonEncode({'keterangan': keterangan}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal membuat $jenis!'};
    }
  }

  static Future<Map<String, dynamic>> deleteTugasKuis(
      int id, String jenis) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': '${jenis[0].toUpperCase()}${jenis.substring(1)} berhasil dihapus! (mode demo)'});
    }
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$jenis/$id'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghapus $jenis!'};
    }
  }

  static Future<Map<String, dynamic>> getNilaiTugasKuis(
      int id, String jenis) async {
    if (demoMode) {
      await _delay();
      final data = _mahasiswaLain
          .map((m) => {'mahasiswa_id': m['id'], 'nama': m['nama'], 'nim': m['nim'], 'nilai': 80.0})
          .toList();
      return _ok({'data': data});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$jenis/$id/nilai'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat nilai $jenis!'};
    }
  }

  static Future<Map<String, dynamic>> simpanNilaiTugasKuis(
      int id, String jenis, List<Map<String, dynamic>> nilai) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Nilai $jenis berhasil disimpan! (mode demo, tidak benar-benar tersimpan)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$jenis/$id/nilai'),
        headers: await _authHeaders,
        body: jsonEncode({'nilai': nilai}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menyimpan nilai $jenis!'};
    }
  }

  // ==================== PROGRES AKADEMIK (Mahasiswa) ====================
  static Future<Map<String, dynamic>> getProgres() async {
    if (demoMode) {
      await _delay();
      return _ok({
        'ipk': _mahasiswaSaya['ipk'],
        'data': [
          {'semester_id': 0, 'semester_nama': 'Ganjil 2024/2025', 'ip_semester': 3.30, 'ews_ips': false, 'detail_kehadiran': []},
          {'semester_id': 1, 'semester_nama': _semesterAktif['nama'], 'ip_semester': 3.5, 'ews_ips': false, 'detail_kehadiran': _absensiSaya},
        ],
      });
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progres'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat data progres akademik!'
      };
    }
  }

  // ==================== ORANG TUA/WALI ====================
  static Future<Map<String, dynamic>> registerOrangTua(
      String nama, String email, String noHp) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Akun Orang Tua/Wali berhasil dibuat! (mode demo). Gunakan akun ortu@demo.com / demo123 untuk mencobanya.'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orang-tua'),
        headers: await _authHeaders,
        body: jsonEncode({
          'nama':  nama,
          'email': email,
          'no_hp': noHp,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mendaftarkan orang tua/wali!'};
    }
  }

  static Future<Map<String, dynamic>> getProgresAnak() async {
    if (demoMode) {
      await _delay();
      return _ok({
        'anak': _orangTuaSaya['mahasiswa'],
        'ipk': _mahasiswaSaya['ipk'],
        'data': [
          {'semester_id': 0, 'semester_nama': 'Ganjil 2024/2025', 'ip_semester': 3.30, 'ews_ips': false, 'detail_kehadiran': []},
          {'semester_id': 1, 'semester_nama': _semesterAktif['nama'], 'ip_semester': 3.5, 'ews_ips': false, 'detail_kehadiran': _absensiSaya},
        ],
      });
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orang-tua/progres'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat data progres akademik anak!'
      };
    }
  }

  // ==================== PEMBAYARAN (Admin) ====================
  static Future<Map<String, dynamic>> getPembayaranList() async {
    if (demoMode) {
      await _delay();
      return _ok({'data': _pembayaranList});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pembayaran'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat data pembayaran!'};
    }
  }

  static Future<Map<String, dynamic>> togglePembayaran(int mahasiswaId) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Status pembayaran berhasil diubah! (mode demo)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pembayaran/toggle/$mahasiswaId'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengubah status pembayaran!'};
    }
  }

  // ==================== ABSENSI (Dosen) ====================
  static Future<Map<String, dynamic>> getRosterAbsensi(
      int kelasId, int pertemuanKe) async {
    if (demoMode) {
      await _delay();
      final data = _mahasiswaLain
          .map((m) => {'mahasiswa_id': m['id'], 'nama': m['nama'], 'nim': m['nim'], 'status': 'hadir'})
          .toList();
      return _ok({'data': data});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kelas/$kelasId/absensi?pertemuan_ke=$pertemuanKe'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat roster absensi!'};
    }
  }

  static Future<Map<String, dynamic>> simpanAbsensi({
    required int kelasId,
    required String tanggalPertemuan,
    required int pertemuanKe,
    required List<Map<String, dynamic>> kehadiran,
  }) async {
    if (demoMode) {
      await _delay();
      return _ok({'message': 'Absensi berhasil disimpan! (mode demo, tidak benar-benar tersimpan)'});
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/absensi'),
        headers: await _authHeaders,
        body: jsonEncode({
          'kelas_id': kelasId,
          'tanggal_pertemuan': tanggalPertemuan,
          'pertemuan_ke': pertemuanKe,
          'kehadiran': kehadiran,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal menyimpan absensi!'};
    }
  }

  static Future<Map<String, dynamic>> getRekapAbsensiKelas(int kelasId) async {
    if (demoMode) {
      await _delay();
      final data = _mahasiswaLain.map((m) => {
        'mahasiswa_id': m['id'], 'nama': m['nama'], 'nim': m['nim'],
        'total_pertemuan': 8, 'hadir': 7, 'persentase': 87.5,
      }).toList();
      return _ok({'data': data});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kelas/$kelasId/absensi/rekap'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat rekap absensi!'};
    }
  }

  // ==================== ABSENSI (Mahasiswa) ====================
  static Future<Map<String, dynamic>> getMyAbsensi() async {
    if (demoMode) {
      await _delay();
      return _ok({'data': _absensiSaya});
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/absensi'),
        headers: await _authHeaders,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat data kehadiran!'};
    }
  }

  // ==================== FCM NOTIFICATION ====================
  static Future<void> saveFcmToken(String fcmToken) async {
    if (demoMode) return; // tidak perlu apa-apa di mode demo
    try {
      final authToken = await getToken();
      if (authToken == null) return;
      await http.post(
        Uri.parse('$baseUrl/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );
    } catch (e) {
      // silent fail
    }
  }
}