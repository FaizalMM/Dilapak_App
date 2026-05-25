import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dilapak.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nik TEXT,
        no_kk TEXT,
        nama_lengkap TEXT,
        email TEXT,
        no_whatsapp TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        jenis_kelamin TEXT,
        provinsi TEXT,
        kabupaten TEXT,
        kecamatan TEXT,
        kelurahan TEXT,
        is_verified_wa INTEGER DEFAULT 0,
        is_verified_berkas INTEGER DEFAULT 0,
        is_profil_lengkap INTEGER DEFAULT 0,
        kode_verifikasi TEXT,
        status_berkas TEXT DEFAULT 'belum',
        foto_ktp TEXT,
        foto_swafoto TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabel layanan (dummy seed)
    await db.execute('''
      CREATE TABLE layanan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode TEXT NOT NULL UNIQUE,
        nama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        deskripsi TEXT,
        syarat TEXT,
        estimasi_hari INTEGER DEFAULT 3,
        is_aktif INTEGER DEFAULT 1
      )
    ''');

    // Tabel permohonan
    await db.execute('''
      CREATE TABLE permohonan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nomor_resi TEXT NOT NULL UNIQUE,
        layanan_id INTEGER NOT NULL,
        jenis_layanan TEXT NOT NULL,
        nama_pemohon TEXT NOT NULL,
        nik_pemohon TEXT,
        kecamatan TEXT,
        kelurahan TEXT,
        alamat TEXT,
        rt TEXT,
        rw TEXT,
        status TEXT DEFAULT 'menunggu',
        catatan TEXT,
        tanggal_pengajuan TEXT DEFAULT CURRENT_TIMESTAMP,
        tanggal_selesai TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (layanan_id) REFERENCES layanan(id)
      )
    ''');

    // Tabel tracking
    await db.execute('''
      CREATE TABLE tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        permohonan_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        deskripsi TEXT,
        waktu TEXT,
        is_done INTEGER DEFAULT 0,
        urutan INTEGER NOT NULL,
        FOREIGN KEY (permohonan_id) REFERENCES permohonan(id)
      )
    ''');

    // Tabel notifikasi
    await db.execute('''
      CREATE TABLE notifikasi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        tipe TEXT DEFAULT 'info',
        is_read INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Tabel berkas — menyimpan path foto KTP & swafoto yang diupload user
    await db.execute('''
      CREATE TABLE berkas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        permohonan_id INTEGER,
        nama_berkas TEXT NOT NULL,
        tipe_berkas TEXT NOT NULL,
        path_file TEXT NOT NULL,
        status TEXT DEFAULT 'menunggu',
        catatan_petugas TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await _seedLayanan(db);
  }

  Future<void> _seedLayanan(Database db) async {
    final list = [
      {
        'kode': 'KTP-001',
        'nama': 'KTP-el Baru (Rekam)',
        'kategori': 'Kependudukan',
        'deskripsi': 'Pembuatan KTP-el baru untuk pertama kali',
        'syarat': 'Surat pengantar RT/RW, Fotokopi KK, Pas foto 3x4',
        'estimasi_hari': 3
      },
      {
        'kode': 'KTP-002',
        'nama': 'KTP-el Karena Hilang',
        'kategori': 'Kependudukan',
        'deskripsi': 'Penggantian KTP-el yang hilang',
        'syarat': 'Surat kehilangan dari polisi, Fotokopi KK',
        'estimasi_hari': 3
      },
      {
        'kode': 'KTP-003',
        'nama': 'KTP-el Karena Rusak',
        'kategori': 'Kependudukan',
        'deskripsi': 'Penggantian KTP-el yang rusak',
        'syarat': 'KTP-el lama yang rusak, Fotokopi KK',
        'estimasi_hari': 2
      },
      {
        'kode': 'KTP-004',
        'nama': 'KTP-el Perubahan Data',
        'kategori': 'Kependudukan',
        'deskripsi': 'Perubahan data pada KTP-el',
        'syarat': 'Dokumen pendukung perubahan, KTP-el lama',
        'estimasi_hari': 5
      },
      {
        'kode': 'KK-001',
        'nama': 'Penerbitan KK Baru',
        'kategori': 'Kartu Keluarga',
        'deskripsi': 'Pembuatan Kartu Keluarga baru',
        'syarat': 'Surat nikah, KTP kedua orang tua, Surat pengantar',
        'estimasi_hari': 5
      },
      {
        'kode': 'KK-002',
        'nama': 'KK Karena Hilang/Rusak',
        'kategori': 'Kartu Keluarga',
        'deskripsi': 'Penggantian KK yang hilang atau rusak',
        'syarat': 'Surat kehilangan dari polisi atau KK rusak',
        'estimasi_hari': 3
      },
      {
        'kode': 'KK-003',
        'nama': 'KK Perubahan Data',
        'kategori': 'Kartu Keluarga',
        'deskripsi': 'Perubahan data anggota keluarga',
        'syarat': 'KK lama, Dokumen pendukung perubahan',
        'estimasi_hari': 5
      },
      {
        'kode': 'AK-001',
        'nama': 'Akta Kelahiran Baru',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penerbitan akta kelahiran',
        'syarat': 'Surat keterangan lahir, KK, KTP orang tua, Buku nikah',
        'estimasi_hari': 7
      },
      {
        'kode': 'AK-002',
        'nama': 'Akta Kelahiran Hilang',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penggantian akta kelahiran yang hilang',
        'syarat': 'Surat kehilangan dari polisi, Fotokopi akta lama',
        'estimasi_hari': 5
      },
      {
        'kode': 'AK-003',
        'nama': 'Akta Perkawinan',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penerbitan akta perkawinan',
        'syarat': 'Surat nikah dari KUA/gereja, KTP, KK',
        'estimasi_hari': 7
      },
      {
        'kode': 'AK-004',
        'nama': 'Akta Kematian',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penerbitan akta kematian',
        'syarat': 'Surat keterangan kematian, KK, KTP almarhum',
        'estimasi_hari': 3
      },
      {
        'kode': 'KIA-001',
        'nama': 'Kartu Identitas Anak (KIA)',
        'kategori': 'KIA',
        'deskripsi': 'Penerbitan KIA usia 0-17 tahun',
        'syarat': 'Akta kelahiran, KK, KTP orang tua',
        'estimasi_hari': 3
      },
      {
        'kode': 'PD-001',
        'nama': 'Surat Keterangan Pindah WNI',
        'kategori': 'Pindah Datang',
        'deskripsi': 'Surat keterangan pindah dalam negeri',
        'syarat': 'KK, KTP, Surat pengantar RT/RW',
        'estimasi_hari': 3
      },
      {
        'kode': 'PD-002',
        'nama': 'Surat Keterangan Pindah Masuk',
        'kategori': 'Pindah Datang',
        'deskripsi': 'Surat keterangan pindah masuk ke Kota Madiun',
        'syarat': 'Surat keterangan pindah dari daerah asal, KK, KTP',
        'estimasi_hari': 5
      },
      {
        'kode': 'SKD-001',
        'nama': 'Surat Keterangan Domisili',
        'kategori': 'Surat Keterangan',
        'deskripsi': 'Surat keterangan tempat tinggal/domisili',
        'syarat': 'KTP, KK, Surat pengantar RT/RW',
        'estimasi_hari': 2
      },
    ];
    for (final l in list) {
      await db.insert('layanan', l);
    }
  }

  // ═══════════ USER ═══════════

  Future<int> insertUser(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('users', data,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<Map<String, dynamic>?> getUserByWa(String noWa) async {
    final db = await database;
    final res =
        await db.query('users', where: 'no_whatsapp = ?', whereArgs: [noWa]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isWaTaken(String noWa) async {
    final db = await database;
    final res =
        await db.query('users', where: 'no_whatsapp = ?', whereArgs: [noWa]);
    return res.isNotEmpty;
  }

  // ═══════════ LAYANAN ═══════════

  Future<List<Map<String, dynamic>>> getAllLayanan() async {
    final db = await database;
    return await db.query('layanan',
        where: 'is_aktif = 1', orderBy: 'kategori, nama');
  }

  Future<Map<String, dynamic>?> getLayananById(int id) async {
    final db = await database;
    final res = await db.query('layanan', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  // ═══════════ PERMOHONAN ═══════════

  Future<int> insertPermohonan(Map<String, dynamic> data) async {
    final db = await database;
    final id = await db.insert('permohonan', data);
    await _initTracking(db, id);
    return id;
  }

  Future<void> _initTracking(Database db, int permohonanId) async {
    final steps = [
      {
        'judul': 'Permohonan Diterima',
        'deskripsi': 'Permohonan berhasil diterima oleh sistem',
        'is_done': 1,
        'waktu': DateTime.now().toIso8601String(),
        'urutan': 1
      },
      {
        'judul': 'Verifikasi Dokumen',
        'deskripsi': 'Dokumen sedang diverifikasi oleh petugas',
        'is_done': 0,
        'waktu': null,
        'urutan': 2
      },
      {
        'judul': 'Sedang Diproses',
        'deskripsi': 'Permohonan sedang dalam proses penerbitan',
        'is_done': 0,
        'waktu': null,
        'urutan': 3
      },
      {
        'judul': 'Selesai',
        'deskripsi': 'Dokumen siap diambil di kantor Dispendukcapil',
        'is_done': 0,
        'waktu': null,
        'urutan': 4
      },
    ];
    for (final s in steps) {
      await db.insert('tracking', {...s, 'permohonan_id': permohonanId});
    }
  }

  Future<List<Map<String, dynamic>>> getPermohonanByUser(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, l.nama as nama_layanan, l.kategori
      FROM permohonan p
      JOIN layanan l ON p.layanan_id = l.id
      WHERE p.user_id = ?
      ORDER BY p.tanggal_pengajuan DESC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getTrackingByPermohonan(
      int permohonanId) async {
    final db = await database;
    return await db.query('tracking',
        where: 'permohonan_id = ?',
        whereArgs: [permohonanId],
        orderBy: 'urutan');
  }

  Future<Map<String, dynamic>?> getPermohonanById(int id) async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT p.*, l.nama as nama_layanan, l.kategori
      FROM permohonan p JOIN layanan l ON p.layanan_id = l.id
      WHERE p.id = ?
    ''', [id]);
    return res.isNotEmpty ? res.first : null;
  }

  // ═══════════ NOTIFIKASI ═══════════

  Future<List<Map<String, dynamic>>> getNotifikasiByUser(int userId) async {
    final db = await database;
    return await db.query('notifikasi',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
  }

  Future<int> getUnreadCount(int userId) async {
    final db = await database;
    final res = await db.rawQuery(
        'SELECT COUNT(*) as c FROM notifikasi WHERE user_id = ? AND is_read = 0',
        [userId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<void> markRead(int id) async {
    final db = await database;
    await db.update('notifikasi', {'is_read': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllRead(int userId) async {
    final db = await database;
    await db.update('notifikasi', {'is_read': 1},
        where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> insertNotifikasi(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('notifikasi', data);
  }

  // ═══════════ BERKAS ═══════════

  Future<int> insertBerkas(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('berkas', data);
  }

  Future<List<Map<String, dynamic>>> getBerkasByUser(int userId) async {
    final db = await database;
    return await db.query('berkas',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getBerkasByTipe(
      int userId, String tipe) async {
    final db = await database;
    return await db.query('berkas',
        where: 'user_id = ? AND tipe_berkas = ?',
        whereArgs: [userId, tipe],
        orderBy: 'created_at DESC');
  }

  Future<int> updateBerkas(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('berkas', data, where: 'id = ?', whereArgs: [id]);
  }
}
