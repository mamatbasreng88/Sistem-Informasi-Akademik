import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main_navigation.dart';
import '../screens/mahasiswa/krs_screen.dart';
import '../screens/mahasiswa/lihat_krs_screen.dart';
import '../screens/mahasiswa/khs_screen.dart';
import '../screens/mahasiswa/transkrip_screen.dart';
import '../screens/mahasiswa/progres_screen.dart';
import '../screens/mahasiswa/absensi_screen.dart';
import '../screens/mahasiswa/ubah_password_screen.dart';
import '../screens/mahasiswa/bantuan_screen.dart';
import '../screens/mahasiswa/tentang_screen.dart';
import '../screens/mahasiswa/daftar_orangtua_screen.dart';
import '../screens/orangtua/orangtua_home.dart';
import '../screens/dosen/daftar_mahasiswa_screen.dart';
import '../screens/dosen/input_nilai_screen.dart';
import '../screens/dosen/input_absensi_screen.dart';
import '../screens/admin/kelola_mahasiswa_screen.dart';
import '../screens/admin/kelola_dosen_screen.dart';
import '../screens/admin/kelola_matkul_screen.dart';
import '../screens/admin/kelola_kelas_screen.dart';
import '../screens/admin/semester_screen.dart';
import '../screens/admin/kelola_pembayaran_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginScreen(),

    '/home_mahasiswa': (context) => const MainNavigation(role: 'mahasiswa'),
    '/home_dosen':     (context) => const MainNavigation(role: 'dosen'),
    '/home_admin':     (context) => const MainNavigation(role: 'admin'),
    '/home_orangtua':  (context) => const OrangTuaHome(),

    '/krs':       (context) => const KRSScreen(),
    '/lihat_krs': (context) => const LihatKRSScreen(),
    '/khs':       (context) => const KHSScreen(),
    '/transkrip': (context) => const TranskripScreen(),
    '/progres':   (context) => const ProgresScreen(),
    '/absensi':   (context) => const AbsensiScreen(),
    '/daftar-orangtua': (context) => const DaftarOrangTuaScreen(),

    '/daftar_mahasiswa': (context) => const DaftarMahasiswaScreen(),
    '/input_nilai':      (context) => const InputNilaiScreen(),
    '/input_absensi':    (context) => const InputAbsensiScreen(),

    '/kelola_mahasiswa':  (context) => const KelolaMahasiswaScreen(),
    '/kelola_dosen':      (context) => const KelolaDosenScreen(),
    '/kelola_matkul':     (context) => const KelolaMatkulScreen(),
    '/kelola_kelas':      (context) => const KelolaKelasScreen(),
    '/semester':          (context) => const SemesterScreen(),
    '/kelola_pembayaran': (context) => const KelolaPembayaranScreen(),
    '/pembayaran':         (context) => const KelolaPembayaranScreen(),

    '/ubah_password': (context) => const UbahPasswordScreen(),
    '/bantuan':       (context) => const BantuanScreen(),
    '/tentang':       (context) => const TentangScreen(),
  };
}