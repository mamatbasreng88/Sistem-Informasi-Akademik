class UserModel {
  final String id;
  final String nama;
  final String identifier;
  final String role;
  final String prodi;
  final String fakultas;
  final String? angkatan;
  final String? email;
  final String? noHp;
  final double? ipk;
  final bool? statusBayar;

  UserModel({
    required this.id,
    required this.nama,
    required this.identifier,
    required this.role,
    required this.prodi,
    required this.fakultas,
    this.angkatan,
    this.email,
    this.noHp,
    this.ipk,
    this.statusBayar,
  });
}

class MatkulModel {
  final String id;
  final String kode;
  final String nama;
  final int sks;
  final int semester;

  MatkulModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.sks,
    required this.semester,
  });
}

class KelasModel {
  final String id;
  final String matkulId;
  final String matkulNama;
  final String matkulKode;
  final int matkulSks;
  final String dosenId;
  final String dosenNama;
  final String namaKelas;
  final int kapasitas;
  int terisi;
  final String hari;
  final String jam;
  final String ruangan;

  KelasModel({
    required this.id,
    required this.matkulId,
    required this.matkulNama,
    required this.matkulKode,
    required this.matkulSks,
    required this.dosenId,
    required this.dosenNama,
    required this.namaKelas,
    required this.kapasitas,
    required this.terisi,
    required this.hari,
    required this.jam,
    required this.ruangan,
  });

  bool get isPenuh => terisi >= kapasitas;
  int get sisaKursi => kapasitas - terisi;
}

class NilaiModel {
  final String id;
  final String mahasiswaId;
  final String mahasiswaNama;
  final String nim;
  final String kelasId;
  final String matkulNama;
  final String namaKelas;
  String? nilaiAkhir;

  NilaiModel({
    required this.id,
    required this.mahasiswaId,
    required this.mahasiswaNama,
    required this.nim,
    required this.kelasId,
    required this.matkulNama,
    required this.namaKelas,
    this.nilaiAkhir,
  });
}